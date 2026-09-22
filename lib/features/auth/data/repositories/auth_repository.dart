import 'package:smart_student_companion/models/user_model.dart';

abstract class AuthRepository {
  Stream<UserModel?> get authStateChanges;
  Future<UserModel?> currentUser();
  Future<UserModel> login(String email, String password);
  Future<UserModel> register({
    required UserRole role,
    required String name,
    required String email,
    required String password,
    required Map<String, String> profile,
  });
  Future<void> logout();
  Future<void> passwordReset(String email);
}
