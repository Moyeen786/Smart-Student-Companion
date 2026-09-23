import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:smart_student_companion/app/app_providers.dart';
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
      );

      final map = model.toMap();
      expect(map['role'], 'student');

      final decoded = UserModel.fromMap(map);
      expect(decoded.uid, 'u1');
      expect(decoded.role, UserRole.student);
      expect(decoded.department, 'Computer Science');
    });
  });

  group('Route protection', () {
    test('student role cannot access faculty route', () {
      expect(AppRouter.canAccessRoute(UserRole.student, '/faculty'), isFalse);
      expect(AppRouter.canAccessRoute(UserRole.student, '/student'), isTrue);
      expect(AppRouter.canAccessRoute(UserRole.faculty, '/student'), isFalse);
      expect(AppRouter.canAccessRoute(UserRole.parent, '/parent'), isTrue);
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
