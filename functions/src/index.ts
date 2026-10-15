import { initializeApp } from 'firebase-admin/app';
import { getAuth } from 'firebase-admin/auth';
import { FieldValue, getFirestore } from 'firebase-admin/firestore';
import * as logger from 'firebase-functions/logger';
import { CallableRequest, HttpsError, onCall } from 'firebase-functions/v2/https';
import {
  assertApprovingStudent,
  assertParentProfileMayLink,
  assertReservationMayContinue,
  parentClaims,
  resolveStudent,
  StudentRecord,
} from './parent_registration';

initializeApp();
const db = getFirestore();
const region = 'us-central1';

function requireStudentCaller(request: CallableRequest<Record<string, unknown>>): string {
  const uid = request.auth?.uid;
  if (!uid) throw new HttpsError('unauthenticated', 'Sign in to the Student account to approve this Parent link.');
  return uid;
}

function requiredString(value: unknown, field: string): string {
  if (typeof value !== 'string' || !value.trim()) {
    throw new HttpsError('invalid-argument', `A valid ${field} is required.`);
  }
  return value.trim();
}

async function resolveAuthenticatedStudent(
  uid: string,
  rollNumber: string,
  fullName: string,
): Promise<StudentRecord> {
  const snapshot = await db.collection('users').where('role', '==', 'student').get();
  const student = resolveStudent(
    snapshot.docs.map((doc) => ({ ...doc.data(), uid: doc.id })),
    rollNumber,
    fullName,
  );
  assertApprovingStudent(student.uid, uid);
  return student;
}

export const validateParentRegistrationStudent = onCall<Record<string, unknown>>({ region }, async (request) => {
 try {
  logger.info('parent_registration.stage', { callable: 'validateParentRegistrationStudent', stage: 'authentication' });
  const uid = requireStudentCaller(request);
  logger.info('parent_registration.stage', { callable: 'validateParentRegistrationStudent', stage: 'payload_validation' });
  const rollNumber = requiredString(request.data?.rollNumber, 'roll number');
  const fullName = requiredString(request.data?.studentName, 'student name');
  logger.info('parent_registration.stage', { callable: 'validateParentRegistrationStudent', stage: 'student_profile_lookup_and_approval' });
  const student = await resolveAuthenticatedStudent(uid, rollNumber, fullName);
  return {
    uid: student.uid,
    name: student.name,
    rollNumber: student.rollNumber,
    department: typeof student.department === 'string' ? student.department : '',
  };
 } catch (error) {
   logger.error('parent_registration.callable_failed', {
     callable: 'validateParentRegistrationStudent',
     code: error instanceof HttpsError ? error.code : 'internal',
     errorType: error instanceof Error ? error.name : typeof error,
   });
   throw error;
 }
});

export const registerParentLink = onCall<Record<string, unknown>>({ region }, async (request) => {
 try {
  logger.info('parent_registration.stage', { callable: 'registerParentLink', stage: 'student_authentication' });
  const studentUid = requireStudentCaller(request);
  logger.info('parent_registration.stage', { callable: 'registerParentLink', stage: 'payload_validation' });
  const rollNumber = requiredString(request.data?.rollNumber, 'roll number');
  const fullName = requiredString(request.data?.studentName, 'student name');
  const parentIdToken = requiredString(request.data?.parentIdToken, 'verified Parent phone identity');
  logger.info('parent_registration.stage', { callable: 'registerParentLink', stage: 'student_profile_lookup_and_approval' });
  const student = await resolveAuthenticatedStudent(studentUid, rollNumber, fullName);

  logger.info('parent_registration.stage', { callable: 'registerParentLink', stage: 'parent_phone_token_verification' });
  let verifiedParent;
  try {
    verifiedParent = await getAuth().verifyIdToken(parentIdToken, true);
  } catch {
    throw new HttpsError('unauthenticated', 'Verify the Parent phone by SMS before submitting registration.');
  }
  const parentUid = verifiedParent.uid;
  const phoneNumber = verifiedParent.phone_number;
  if (!phoneNumber || !/^\+[1-9]\d{7,14}$/.test(phoneNumber)) {
    throw new HttpsError('failed-precondition', 'Firebase did not provide a verified E.164 phone identity.');
  }

  const parentAuth = await getAuth().getUser(parentUid);
  if (parentAuth.phoneNumber !== phoneNumber) {
    throw new HttpsError('unauthenticated', 'The verified phone identity does not match the Firebase account.');
  }
  const claims = parentClaims(parentAuth.customClaims, student.uid);
  const parentRef = db.collection('users').doc(parentUid);
  const reservationRef = db.collection('parent_registration_reservations').doc(parentUid);
  logger.info('parent_registration.stage', { callable: 'registerParentLink', stage: 'registration_reservation' });
  await db.runTransaction(async (transaction) => {
    const profileSnapshot = await transaction.get(parentRef);
    const profile = profileSnapshot.data();
    const state = assertParentProfileMayLink(profile, student.uid, phoneNumber);
    if (state !== 'create') return;
    const reservationSnapshot = await transaction.get(reservationRef);
    const reservationState = assertReservationMayContinue(
      reservationSnapshot.data(),
      student.uid,
      phoneNumber,
    );
    if (reservationState === 'create') {
      transaction.create(reservationRef, {
        parentUid,
        parentPhone: phoneNumber,
        childStudentId: student.uid,
        createdAt: FieldValue.serverTimestamp(),
      });
    } else {
      transaction.update(reservationRef, { updatedAt: FieldValue.serverTimestamp() });
    }
  });

  logger.info('parent_registration.stage', { callable: 'registerParentLink', stage: 'parent_claim_assignment' });
  await getAuth().setCustomUserClaims(parentUid, claims);

  logger.info('parent_registration.stage', { callable: 'registerParentLink', stage: 'parent_profile_link' });
  await db.runTransaction(async (transaction) => {
    const profileSnapshot = await transaction.get(parentRef);
    const profile = profileSnapshot.data();
    const reservationSnapshot = await transaction.get(reservationRef);
    if (profile) {
      assertParentProfileMayLink(profile, student.uid, phoneNumber);
    } else {
      if (
        assertReservationMayContinue(reservationSnapshot.data(), student.uid, phoneNumber) !==
        'continue'
      ) {
        throw new HttpsError(
          'failed-precondition',
          'The Parent registration reservation expired. Retry registration.',
        );
      }
      transaction.create(parentRef, {
        uid: parentUid,
        name: 'Parent',
        email: '',
        role: 'parent',
        department: '',
        semester: 0,
        createdAt: FieldValue.serverTimestamp(),
        parentPhone: phoneNumber,
        childStudentId: student.uid,
        linkStatus: 'active',
        linkedAt: FieldValue.serverTimestamp(),
        verifiedAt: FieldValue.serverTimestamp(),
      });
    }
    if (profile && profile.linkStatus !== 'active') {
      transaction.update(parentRef, {
        linkStatus: 'active',
        verifiedAt: FieldValue.serverTimestamp(),
      });
    }
    if (reservationSnapshot.exists) transaction.delete(reservationRef);
  });

  return { status: 'linked', parentUid, studentUid: student.uid };
 } catch (error) {
   logger.error('parent_registration.callable_failed', {
     callable: 'registerParentLink',
     code: error instanceof HttpsError ? error.code : 'internal',
     errorType: error instanceof Error ? error.name : typeof error,
   });
   throw error;
 }
});
