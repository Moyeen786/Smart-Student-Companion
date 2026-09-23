import 'package:smart_student_companion/features/auth/data/repositories/auth_repository.dart';
import 'package:smart_student_companion/models/user_model.dart';

class MockAuthRepository implements AuthRepository {
  final Map<String, ({UserModel user, String password})> _accounts = {};

  @override
  Stream<UserModel?> get authStateChanges => const Stream.empty();

  @override
  Future<UserModel?> currentUser() async {
    return null;
  }

  @override
  Future<UserModel> login(String email, String password) async {
    if (email.isEmpty || password.isEmpty) {
      throw Exception('Please enter your email and password.');
    }

    final savedAccount = _accounts[email];
    if (savedAccount != null) {
      if (savedAccount.password != password) {
        throw Exception('Incorrect email or password.');
      }
      return savedAccount.user;
    }

    final role = email.contains('faculty')
        ? UserRole.faculty
        : email.contains('parent')
        ? UserRole.parent
        : email.contains('admin')
        ? UserRole.admin
        : UserRole.student;

    return UserModel(
      uid: 'demo-${role.name}',
      name: email.contains('faculty')
          ? 'Dr. S. Mehta'
          : email.contains('parent')
          ? 'Ananya Sharma'
          : email.contains('admin')
          ? 'Amit Verma'
          : 'Riya Sharma',
      email: email,
      role: role,
      department: role == UserRole.student
          ? 'Computer Science and Engineering'
          : role == UserRole.faculty
          ? 'Department of Mathematics'
          : role == UserRole.parent
          ? 'Parent Access'
          : 'Administration',
      semester: role == UserRole.student ? 5 : 0,
      createdAt: DateTime.now(),
    );
  }

  @override
  Future<UserModel> register({
    required UserRole role,
    required String name,
    required String email,
    required String password,
    required Map<String, String> profile,
  }) async {
    if (_accounts.containsKey(email)) {
      throw Exception('An account with this email already exists.');
    }
    final user = UserModel(
      uid: 'demo-${DateTime.now().microsecondsSinceEpoch}',
      name: name,
      email: email,
      role: role,
      department: profile['department'] ?? 'General Administration',
      semester: int.tryParse(profile['semester'] ?? '') ?? 0,
      createdAt: DateTime.now(),
      rollNumber: profile['rollNumber'] ?? profile['accountId'] ?? '',
    );
    _accounts[email] = (user: user, password: password);
    return user;
  }

  @override
  Future<void> logout() async {}

  @override
  Future<void> passwordReset(String email) async {
    if (email.isEmpty) {
      throw Exception('Enter a valid email to reset your password.');
    }
  }
}
