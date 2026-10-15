import { HttpsError } from 'firebase-functions/v2/https';

export interface StudentRecord {
  uid: string;
  role?: unknown;
  name?: unknown;
  email?: unknown;
  rollNumber?: unknown;
  department?: unknown;
  semester?: unknown;
  createdAt?: unknown;
}

export function normalizeRollNumber(value: string): string {
  return value.normalize('NFKC').trim().replace(/\s+/g, '').toUpperCase();
}

export function normalizePersonName(value: string): string {
  return value.normalize('NFKC').trim().replace(/\s+/g, ' ').toLocaleLowerCase('en-US');
}

export function assertApprovingStudent(resolvedStudentUid: string, callerUid: string): void {
  if (!callerUid || resolvedStudentUid !== callerUid) {
    throw new HttpsError('permission-denied', 'The authenticated Student account can approve links only to its own profile.');
  }
}

export function resolveStudent(
  records: StudentRecord[],
  rollNumber: string,
  fullName: string,
): StudentRecord {
  const roll = normalizeRollNumber(rollNumber);
  const name = normalizePersonName(fullName);
  if (!roll || !name) {
    throw new HttpsError('invalid-argument', 'Enter the student name and roll number.');
  }
  const rollMatches = records.filter((record) =>
    record.role === 'student' &&
    typeof record.rollNumber === 'string' &&
    normalizeRollNumber(record.rollNumber) === roll,
  );
  if (rollMatches.length === 0) {
    throw new HttpsError('not-found', 'The student name and roll number did not match an active student profile.');
  }
  if (rollMatches.length !== 1) {
    throw new HttpsError('failed-precondition', 'More than one student profile matches those details. Contact the institution.');
  }
  const student = rollMatches[0];
  if (typeof student.name !== 'string' || !student.name.trim() ||
      typeof student.rollNumber !== 'string' || !student.rollNumber.trim() ||
      typeof student.email !== 'string' || !student.email.trim() ||
      typeof student.department !== 'string' || !student.department.trim() ||
      typeof student.semester !== 'number' || student.semester < 1 ||
      student.createdAt === undefined || student.createdAt === null ||
      !student.uid.trim()) {
    throw new HttpsError('failed-precondition', 'The matching Student profile is incomplete. Contact the institution.');
  }
  if (normalizePersonName(student.name) !== name) {
    throw new HttpsError('not-found', 'The student name and roll number did not match an active student profile.');
  }
  return student;
}

export function parentClaims(
  existing: Record<string, unknown> | undefined,
  childStudentId: string,
): Record<string, unknown> {
  const claims = existing ?? {};
  if (claims.admin === true || ['admin', 'student', 'faculty', 'teacher'].includes(String(claims.role ?? ''))) {
    throw new HttpsError('already-exists', 'This phone identity already has a different privileged role.');
  }
  const currentChild = claims.childStudentId;
  if (claims.role === 'parent' && currentChild !== undefined && currentChild !== childStudentId) {
    throw new HttpsError('already-exists', 'This Parent phone identity is already linked to another student.');
  }
  return { ...claims, role: 'parent', childStudentId };
}

export function assertParentProfileMayLink(
  profile: Record<string, unknown> | undefined,
  childStudentId: string,
  phoneNumber: string,
): 'create' | 'repair' | 'complete' {
  if (!profile) return 'create';
  if (profile.role !== 'parent') {
    throw new HttpsError('already-exists', 'This Firebase account already belongs to another role.');
  }
  if (profile.childStudentId !== childStudentId) {
    throw new HttpsError('already-exists', 'This Parent account is already linked to another student.');
  }
  if (profile.parentPhone !== phoneNumber) {
    throw new HttpsError('failed-precondition', 'The registered Parent phone does not match the verified phone identity.');
  }
  return profile.linkStatus === 'active' ? 'complete' : 'repair';
}

export function assertReservationMayContinue(
  reservation: Record<string, unknown> | undefined,
  childStudentId: string,
  phoneNumber: string,
): 'create' | 'continue' {
  if (!reservation) return 'create';
  if (reservation.childStudentId !== childStudentId || reservation.parentPhone !== phoneNumber) {
    throw new HttpsError('already-exists', 'A Parent registration for this phone is already reserved for another student.');
  }
  return 'continue';
}
