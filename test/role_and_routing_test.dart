import 'package:flutter_test/flutter_test.dart';
import 'package:smart_student_companion/models/user_model.dart';
import 'package:smart_student_companion/app/router.dart';

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
}
