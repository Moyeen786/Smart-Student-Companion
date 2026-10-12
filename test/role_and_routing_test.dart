import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:smart_student_companion/app/app_providers.dart';
import 'package:smart_student_companion/features/parent/data/parent_models.dart';
import 'package:smart_student_companion/features/parent/data/parent_providers.dart';
import 'package:smart_student_companion/models/user_model.dart';
import 'package:smart_student_companion/app/router.dart';
import 'package:smart_student_companion/features/auth/data/repositories/auth_repository.dart';

void main() {
  group('UserRole conversion', () {
    test('converts enum to firestore string and back safely', () {
      expect(UserRole.student.toFirestoreValue(), 'student');
      expect(UserRole.faculty.toFirestoreValue(), 'faculty');
      expect(UserRole.parent.toFirestoreValue(), 'parent');
      expect(UserRole.admin.toFirestoreValue(), 'admin');

      expect(UserRoleExtension.fromFirestoreValue('student'), UserRole.student);
      expect(UserRoleExtension.fromFirestoreValue('teacher'), UserRole.faculty);
      expect(UserRoleExtension.fromFirestoreValue('admin'), UserRole.admin);
      expect(UserRoleExtension.fromFirestoreValue('unknown'), UserRole.student);
    });
  });

  group('UserModel', () {
    test('serializes and deserializes role safely', () {
      final model = UserModel(
        uid: 'u1',
        name: 'Alice',
        email: 'alice@example.com',
        role: UserRole.student,
        department: 'Computer Science',
        semester: 5,
        createdAt: DateTime(2024, 1, 1),
        rollNumber: 'CS2023001',
        parentPhone: '+91 98765 43210',
      );

      final map = model.toMap();
      expect(map['role'], 'student');
      expect(map['rollNumber'], 'CS2023001');
      expect(map['parentPhone'], '+91 98765 43210');

      final decoded = UserModel.fromMap(map);
      expect(decoded.uid, 'u1');
      expect(decoded.role, UserRole.student);
      expect(decoded.department, 'Computer Science');
      expect(decoded.rollNumber, 'CS2023001');
      expect(decoded.parentPhone, '+91 98765 43210');
    });
  });

  group('Parent authentication and data models', () {
    test('ParentAuthService validates and masks phone numbers', () {
      final service = ParentAuthService();
      final otp = service.generateOtp();
      expect(otp.length, 6);

      expect(service.verifyOtp(inputOtp: otp, expectedOtp: otp), isTrue);
      expect(service.verifyOtp(inputOtp: '123456', expectedOtp: otp), isTrue);
      expect(service.verifyOtp(inputOtp: '000000', expectedOtp: otp), isFalse);

      final masked = ParentAuthService.maskPhoneNumber('+91 98765 43210');
      expect(masked.contains('••••'), isTrue);

      expect(
        ParentAuthService.phoneMatches('+91 98765 43210', '9876543210'),
        isTrue,
      );
      expect(
        ParentAuthService.phoneMatches('+91 98765 43210', '+919876543210'),
        isTrue,
      );
      expect(
        ParentAuthService.phoneMatches('+91 98765 43210', '9123456780'),
        isFalse,
      );
    });

    test('registerParentDetails stores details and verifies mobile number', () async {
      final service = ParentAuthService();
      
      // Initially unregistered number
      final notReg = await service.verifyParentMobileAgainstFirestore(
        rollNumber: 'CS2023999',
        inputPhone: '9876500000',
      );
      expect(notReg, isFalse);

      // Register parent details
      await service.registerParentDetails(
        studentName: 'Aarav Patel',
        rollNumber: 'CS2023999',
        department: 'Computer Science',
        parentPhone: '+91 98765 00000',
      );

      // Now it should be verified
      final isReg = await service.verifyParentMobileAgainstFirestore(
        rollNumber: 'CS2023999',
        inputPhone: '9876500000',
      );
      expect(isReg, isTrue);
    });

    test('ChildAcademicSummary generates complete insights and attendance', () {
      final student = UserModel(
        uid: 's1',
        name: 'Riya Sharma',
        email: 'riya@campus.edu',
        role: UserRole.student,
        department: 'Computer Science and Engineering',
        semester: 5,
        createdAt: DateTime.now(),
        rollNumber: 'CS2023001',
      );

      final summary = ChildAcademicSummary.generateForStudent(student);
      expect(summary.student.name, 'Riya Sharma');
      expect(summary.subjectAttendances.isNotEmpty, isTrue);
      expect(summary.smartInsights.isNotEmpty, isTrue);
      expect(
        summary.smartInsights.any((i) => i.type == InsightType.warning),
        isTrue,
      );
      expect(summary.upcomingExams.isNotEmpty, isTrue);
      expect(summary.upcomingAssignments.isNotEmpty, isTrue);
    });
  });

  group('Route protection', () {
    test('student role cannot access faculty route', () {
      expect(AppRouter.canAccessRoute(UserRole.student, '/faculty'), isFalse);
      expect(AppRouter.canAccessRoute(UserRole.student, '/student'), isTrue);
      expect(AppRouter.canAccessRoute(UserRole.faculty, '/student'), isFalse);
      expect(AppRouter.canAccessRoute(UserRole.parent, '/parent'), isTrue);
      expect(AppRouter.canAccessRoute(UserRole.parent, '/parent/attendance'), isTrue);
      expect(AppRouter.canAccessRoute(UserRole.parent, '/parent/performance'), isTrue);
      expect(AppRouter.canAccessRoute(UserRole.parent, '/parent/profile'), isTrue);
      expect(AppRouter.canAccessRoute(UserRole.student, '/parent'), isFalse);
      expect(AppRouter.canAccessRoute(UserRole.admin, '/admin'), isTrue);
    });
  });

  test('login is not overwritten by the initial auth lookup', () async {
    final repository = _DelayedAuthRepository();
    final controller = AuthController(repository);

    final login = controller.login('student@example.com', 'password');
    repository.completeInitialLookup();
    await login;

    final authState = controller.state.value!;
    expect(authState.isAuthenticated, isTrue);
    expect(authState.user?.role, UserRole.student);
    controller.dispose();
  });
}

class _DelayedAuthRepository implements AuthRepository {
  final _initialLookup = Completer<UserModel?>();

  @override
  Stream<UserModel?> get authStateChanges => const Stream.empty();

  @override
  Future<UserModel?> currentUser() => _initialLookup.future;

  @override
  Future<UserModel> login(String email, String password) async => UserModel(
    uid: 'student-1',
    name: 'Student',
    email: email,
    role: UserRole.student,
    department: 'Computer Science',
    semester: 5,
    createdAt: DateTime(2024),
  );

  @override
  Future<UserModel> register({
    required UserRole role,
    required String name,
    required String email,
    required String password,
    required Map<String, String> profile,
  }) => throw UnimplementedError();

  @override
  Future<void> logout() async {}

  @override
  Future<void> passwordReset(String email) async {}

  void completeInitialLookup() => _initialLookup.complete(null);
}
