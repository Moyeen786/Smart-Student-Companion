import assert from 'node:assert/strict';
import test from 'node:test';
import { HttpsError } from 'firebase-functions/v2/https';
import {
  assertApprovingStudent,
  assertParentProfileMayLink,
  assertReservationMayContinue,
  normalizePersonName,
  normalizeRollNumber,
  parentClaims,
  resolveStudent,
} from './parent_registration';

function makeStudent(uid: string, name: string, rollNumber: string) {
  return {
    uid, role: 'student', name, rollNumber,
    email: `${uid}@campus.edu`, department: 'Computer Science',
    semester: 5, createdAt: new Date('2026-01-01'),
  };
}

test('normalizes roll numbers and names consistently', () => {
  assert.equal(normalizeRollNumber(' cs 2025 01 '), 'CS202501');
  assert.equal(normalizePersonName('  Asha   Rao '), 'asha rao');
});

test('resolves a single Student record by role, roll number, and normalized name', () => {
  const resolved = resolveStudent([
    { uid: 'faculty-1', role: 'faculty', name: 'Asha Rao', rollNumber: 'CS202501' },
    makeStudent('student-1', 'Asha Rao', ' cs 2025 01 '),
  ], 'CS202501', 'asha  rao');
  assert.equal(resolved.uid, 'student-1');
});

test('only the authenticated Student who owns the matching UID may approve the link', () => {
  assert.doesNotThrow(() => assertApprovingStudent('student-1', 'student-1'));
  assert.throws(() => assertApprovingStudent('student-1', 'student-2'), (error) => error instanceof HttpsError && error.code === 'permission-denied');
});

test('rejects mismatched, missing, and ambiguous student records', () => {
  const records = [
    makeStudent('s1', 'Asha Rao', 'CS1'),
    makeStudent('s2', 'Asha Rao', ' CS1 '),
  ];
  assert.throws(() => resolveStudent(records.slice(0, 1), 'CS1', 'Other Name'), (error) => error instanceof HttpsError && error.code === 'not-found');
  assert.throws(() => resolveStudent(records, 'CS1', 'Asha Rao'), (error) => error instanceof HttpsError && error.code === 'failed-precondition');
  assert.throws(() => resolveStudent([], '', 'Asha'), (error) => error instanceof HttpsError && error.code === 'invalid-argument');
  assert.throws(() => resolveStudent([
    makeStudent('s1', 'Asha Rao', 'CS1'),
    makeStudent('s2', 'Other Name', 'cs 1'),
  ], 'CS1', 'Asha Rao'), (error) => error instanceof HttpsError && error.code === 'failed-precondition');
  assert.throws(() => resolveStudent([
    makeStudent('', 'Asha Rao', 'CS1'),
  ], 'CS1', 'Asha Rao'), (error) => error instanceof HttpsError && error.code === 'failed-precondition');
  assert.throws(() => resolveStudent([
    { ...makeStudent('s1', 'Asha Rao', 'CS1'), department: '' },
  ], 'CS1', 'Asha Rao'), (error) => error instanceof HttpsError && error.code === 'failed-precondition');
});

test('preserves existing unrelated claims and refuses role escalation or relinking', () => {
  assert.deepEqual(parentClaims({ feature: true }, 'student-1'), {
    feature: true, role: 'parent', childStudentId: 'student-1',
  });
  assert.throws(() => parentClaims({ admin: true }, 'student-1'), HttpsError);
  assert.throws(() => parentClaims({ role: 'parent', childStudentId: 'student-2' }, 'student-1'), HttpsError);
});

test('parent profile linking is retry-safe but rejects a different child or phone', () => {
  assert.equal(assertParentProfileMayLink(undefined, 's1', '+14155550100'), 'create');
  assert.equal(assertParentProfileMayLink({ role: 'parent', childStudentId: 's1', parentPhone: '+14155550100', linkStatus: 'pendingClaims' }, 's1', '+14155550100'), 'repair');
  assert.equal(assertParentProfileMayLink({ role: 'parent', childStudentId: 's1', parentPhone: '+14155550100', linkStatus: 'active' }, 's1', '+14155550100'), 'complete');
  assert.throws(() => assertParentProfileMayLink({ role: 'parent', childStudentId: 's2', parentPhone: '+14155550100' }, 's1', '+14155550100'), HttpsError);
  assert.throws(() => assertParentProfileMayLink({ role: 'parent', childStudentId: 's1', parentPhone: '+14155550101' }, 's1', '+14155550100'), HttpsError);
});

test('registration reservation retries only for the same child and verified phone', () => {
  assert.equal(assertReservationMayContinue(undefined, 's1', '+14155550100'), 'create');
  assert.equal(assertReservationMayContinue({ childStudentId: 's1', parentPhone: '+14155550100' }, 's1', '+14155550100'), 'continue');
  assert.throws(() => assertReservationMayContinue({ childStudentId: 's2', parentPhone: '+14155550100' }, 's1', '+14155550100'), HttpsError);
  assert.throws(() => assertReservationMayContinue({ childStudentId: 's1', parentPhone: '+14155550101' }, 's1', '+14155550100'), HttpsError);
});
