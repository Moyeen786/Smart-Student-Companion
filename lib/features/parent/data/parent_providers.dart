import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smart_student_companion/features/parent/data/parent_models.dart';
import 'package:smart_student_companion/models/user_model.dart';
import 'package:smart_student_companion/features/parent/data/parent_demo_mode.dart';

/// Holds the candidate student account identified after login.
final parentCandidateStudentProvider = StateProvider<UserModel?>((ref) => null);

/// Holds the verified parent phone number.
final parentVerifiedPhoneProvider = StateProvider<String>((ref) => '');

/// Holds the Firebase Phone Auth verification ID.
final parentVerificationIdProvider = StateProvider<String?>((ref) => null);

/// Holds the Firebase Phone Auth resend token.
final parentResendTokenProvider = StateProvider<int?>((ref) => null);

/// Holds the active child's academic data summary for the parent dashboard.
final parentActiveChildSummaryProvider = StateProvider<ChildAcademicSummary?>(
  (ref) => null,
);

/// Loads the linked student's actual profile. Firestore rules validate the
/// parent claim and child UID on this read.
final parentChildProfileProvider = FutureProvider<ChildAcademicSummary>((
  ref,
) async {
  final user = FirebaseAuth.instance.currentUser;
  if (user == null) throw StateError('Sign in to your Parent account first.');
  final token = await user.getIdTokenResult(true);
  final claims = token.claims ?? const <String, dynamic>{};
  final childUid = claims['childStudentId'] as String? ?? '';
  if (claims['role'] != 'parent' || childUid.isEmpty) {
    throw StateError('This Parent account has no trusted child link.');
  }
  final snapshot = await FirebaseFirestore.instance
      .collection('users')
      .doc(childUid)
      .get();
  final data = snapshot.data();
  if (data == null || data['role'] != 'student') {
    throw StateError('The linked student profile is unavailable.');
  }
  final student = UserModel.fromMap({...data, 'uid': snapshot.id});
  return ChildAcademicSummary(
    student: student,
    cgpa: student.cgpa,
    overallAttendance: student.overallAttendance,
    totalClasses: 0,
    attendedClasses: 0,
    attendanceStatus: '',
    subjectAttendances: const [],
    subjectPerformances: const [],
    upcomingExams: const [],
    upcomingAssignments: const [],
    smartInsights: const [],
    announcements: const [],
    recentActivities: const [],
  );
});

/// Fictional dashboard data for the isolated development demo route only.
/// Never use this provider to satisfy authentication, claims, or Firestore access.
final parentDemoSummaryProvider = Provider<ChildAcademicSummary>((ref) {
  if (!ref.watch(parentDemoModeProvider)) {
    throw StateError('Parent demo mode is disabled.');
  }
  final sampleStudent = UserModel(
    uid: 'demo-student-only',
    name: 'Aarav Sample',
    email: 'aarav.sample@example.invalid',
    role: UserRole.student,
    department: 'Computer Science',
    semester: 5,
    createdAt: DateTime.utc(2025, 1, 1),
    rollNumber: 'DEMO-5001',
  );
  return ChildAcademicSummary.generateForStudent(sampleStudent);
});

class ParentAuthService {
  ParentAuthService({FirebaseFirestore? firestore, FirebaseAuth? auth})
    : _customFirestore = firestore,
      _customAuth = auth;

  final FirebaseFirestore? _customFirestore;
  final FirebaseAuth? _customAuth;

  FirebaseFirestore get _firestore =>
      _customFirestore ?? FirebaseFirestore.instance;
  FirebaseAuth get _auth => _customAuth ?? FirebaseAuth.instance;

  /// Helper to extract numeric digits from phone string.
  static String extractDigits(String phone) =>
      phone.replaceAll(RegExp(r'\D'), '');

  /// Checks if two phone numbers match (checking exact or last 10 digits).
  static bool phoneMatches(String stored, String input) {
    final sDigits = extractDigits(stored);
    final iDigits = extractDigits(input);
    if (sDigits.isEmpty || iDigits.isEmpty) return false;
    if (sDigits == iDigits) return true;
    final s10 = sDigits.length >= 10
        ? sDigits.substring(sDigits.length - 10)
        : sDigits;
    final i10 = iDigits.length >= 10
        ? iDigits.substring(iDigits.length - 10)
        : iDigits;
    return s10 == i10;
  }

  /// Format phone to E.164 (`+<country_code><number>`).
  static String formatToE164(String phone) {
    final trimmed = phone.trim().replaceAll(' ', '');
    if (trimmed.startsWith('+')) return trimmed;
    final digits = extractDigits(trimmed);
    if (digits.length == 10) return '+91$digits';
    return '+$digits';
  }

  /// This client has no trusted parent-link provisioning endpoint.
  /// Never report a client-side registration as persisted when no write is allowed.
  Future<void> registerParentDetails({
    required String studentName,
    required String rollNumber,
    required String department,
    required String parentPhone,
  }) async {
    throw StateError(
      'Parent linking is not configured for client-side registration. '
      'Ask the institution to provision the verified parent account and child link.',
    );
  }

  /// Checks the phone stored on the authenticated student's own profile.
  Future<bool> verifyParentMobileAgainstFirestore({
    required String studentUid,
    required String inputPhone,
  }) async {
    if (_auth.currentUser?.uid != studentUid) {
      throw StateError(
        'Sign in to the student account before parent verification.',
      );
    }
    final user = await _firestore.collection('users').doc(studentUid).get();
    if (!user.exists || user.data()?['role'] != 'student') return false;
    final registeredPhone = user.data()?['parentPhone'] as String? ?? '';
    return registeredPhone.isNotEmpty &&
        phoneMatches(registeredPhone, inputPhone);
  }

  /// Sends OTP using Firebase Phone Authentication.
  Future<void> sendFirebasePhoneOtp({
    required String phoneNumber,
    required void Function(String verificationId, int? resendToken) onCodeSent,
    required void Function(String error) onError,
    required void Function(PhoneAuthCredential credential) onAutoVerified,
    required void Function(String verificationId) onTimeout,
    int? forceResendingToken,
  }) async {
    final formatted = formatToE164(phoneNumber);

    try {
      await _auth.verifyPhoneNumber(
        phoneNumber: formatted,
        forceResendingToken: forceResendingToken,
        timeout: const Duration(seconds: 60),
        verificationCompleted: (PhoneAuthCredential credential) async {
          onAutoVerified(credential);
        },
        verificationFailed: (FirebaseAuthException e) {
          onError(e.message ?? 'Firebase Phone Authentication failed.');
        },
        codeSent: (String verificationId, int? resendToken) {
          onCodeSent(verificationId, resendToken);
        },
        codeAutoRetrievalTimeout: (String verificationId) {
          onTimeout(verificationId);
        },
      );
    } catch (e) {
      onError(e.toString().replaceFirst('Exception: ', ''));
    }
  }

  /// Sign in with the verified phone and require a trusted Parent profile link.
  Future<UserModel> signInParentWithOtp({
    required String otp,
    required String verificationId,
    String? studentUid,
    required String verifiedPhone,
    PhoneAuthCredential? automaticCredential,
  }) async {
    final cleaned = otp.trim();
    if (automaticCredential == null &&
        (cleaned.length != 6 || verificationId.isEmpty)) {
      throw StateError('Enter the six-digit code sent by Firebase.');
    }

    final phoneCredential =
        automaticCredential ??
        PhoneAuthProvider.credential(
          verificationId: verificationId,
          smsCode: cleaned,
        );
    final result = await _auth.signInWithCredential(phoneCredential);
    final firebaseUser = result.user;
    if (firebaseUser == null) {
      throw StateError('Firebase did not return a verified phone account.');
    }

    late final DocumentSnapshot<Map<String, dynamic>> profile;
    try {
      profile = await _firestore
          .collection('users')
          .doc(firebaseUser.uid)
          .get();
    } catch (_) {
      await _auth.signOut();
      rethrow;
    }
    final data = profile.data();
    late final Map<String, dynamic> claims;
    try {
      claims =
          (await firebaseUser.getIdTokenResult(true)).claims ??
          const <String, dynamic>{};
    } catch (_) {
      await _auth.signOut();
      rethrow;
    }
    final linkedStudentId = data?['childStudentId'] as String? ?? '';
    if (data == null ||
        data['role'] != 'parent' ||
        linkedStudentId.isEmpty ||
        (studentUid != null && linkedStudentId != studentUid) ||
        claims['role'] != 'parent' ||
        claims['childStudentId'] != linkedStudentId ||
        !phoneMatches(firebaseUser.phoneNumber ?? '', verifiedPhone)) {
      try {
        if (result.additionalUserInfo?.isNewUser == true) {
          await firebaseUser.delete();
        }
      } finally {
        if (_auth.currentUser?.uid == firebaseUser.uid) {
          await _auth.signOut();
        }
      }
      throw StateError(
        'This verified phone is not linked to this student by the institution.',
      );
    }
    return UserModel.fromMap({...data, 'uid': firebaseUser.uid});
  }

  Future<void> cancelPhoneSignIn() => _auth.signOut();

  /// Look up a student by Student ID (roll number), university email, or document UID.
  Future<UserModel> lookupStudentAccount(String identifier) async {
    final query = identifier.trim();
    if (query.isEmpty) {
      throw Exception('Please enter a valid Student ID or account identifier.');
    }

    final rollSnap = await _firestore
        .collection('users')
        .where('role', isEqualTo: 'student')
        .where('rollNumber', isEqualTo: query)
        .limit(1)
        .get();

    if (rollSnap.docs.isNotEmpty) {
      final data = rollSnap.docs.first.data();
      return UserModel.fromMap({
        ...data,
        'uid': rollSnap.docs.first.id,
        'rollNumber': data['rollNumber'] ?? query,
      });
    }

    final emailSnap = await _firestore
        .collection('users')
        .where('role', isEqualTo: 'student')
        .where('email', isEqualTo: query.toLowerCase())
        .limit(1)
        .get();

    if (emailSnap.docs.isNotEmpty) {
      final data = emailSnap.docs.first.data();
      return UserModel.fromMap({
        ...data,
        'uid': emailSnap.docs.first.id,
        'rollNumber': data['rollNumber'] ?? query,
      });
    }

    final docSnap = await _firestore.collection('users').doc(query).get();
    if (docSnap.exists && docSnap.data()?['role'] == 'student') {
      return UserModel.fromMap({...docSnap.data()!, 'uid': docSnap.id});
    }
    throw StateError('No student account was found for that identifier.');
  }

  /// Mask a phone number for privacy display (e.g. +91 98•••• ••10).
  static String maskPhoneNumber(String phone) {
    if (phone.isEmpty) return '+91 98•••• ••210';
    if (phone.length <= 4) return '•••• $phone';
    final start = phone.substring(0, min(6, phone.length - 4));
    final end = phone.substring(phone.length - 2);
    return '$start•••• ••$end';
  }
}

final parentAuthServiceProvider = Provider<ParentAuthService>((ref) {
  return ParentAuthService();
});
