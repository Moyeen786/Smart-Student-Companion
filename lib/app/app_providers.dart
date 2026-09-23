import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smart_student_companion/features/auth/data/repositories/auth_repository.dart';
import 'package:smart_student_companion/features/auth/data/repositories/firebase_auth_repository.dart';
import 'package:smart_student_companion/models/user_model.dart';

class AuthState {
  const AuthState({required this.isAuthenticated, this.user});

  final bool isAuthenticated;
  final UserModel? user;

  factory AuthState.initial() => const AuthState(isAuthenticated: false);
}

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return FirebaseAuthRepository();
});

final authStateProvider =
    StateNotifierProvider<AuthController, AsyncValue<AuthState>>((ref) {
      final repository = ref.watch(authRepositoryProvider);
      return AuthController(repository);
    });

class AuthController extends StateNotifier<AsyncValue<AuthState>> {
  AuthController(this._repository) : super(const AsyncLoading()) {
    _initialization = _init();
    _authSubscription = _repository.authStateChanges.listen(_onAuthChanged);
  }

  final AuthRepository _repository;
  late final Future<void> _initialization;
  late final StreamSubscription<UserModel?> _authSubscription;

  void _onAuthChanged(UserModel? user) {
    state = AsyncData(AuthState(isAuthenticated: user != null, user: user));
  }

  Future<void> _init() async {
    try {
      final user = await _repository.currentUser();
      state = AsyncData(AuthState(isAuthenticated: user != null, user: user));
    } catch (error, stackTrace) {
      state = AsyncError(error, stackTrace);
    }
  }

  Future<void> login(String email, String password) async {
    await _initialization;
    state = const AsyncLoading();
    try {
      final user = await _repository.login(email, password);
      state = AsyncData(AuthState(isAuthenticated: true, user: user));
    } catch (error, stackTrace) {
      state = AsyncError(error, stackTrace);
    }
  }

  Future<void> register({
    required UserRole role,
    required String name,
    required String email,
    required String password,
    required Map<String, String> profile,
  }) async {
    state = const AsyncLoading();
    try {
      final user = await _repository.register(
        role: role,
        name: name,
        email: email,
        password: password,
        profile: profile,
      );
      state = AsyncData(AuthState(isAuthenticated: false, user: user));
    } catch (error, stackTrace) {
      state = AsyncError(error, stackTrace);
    }
  }

  Future<void> passwordReset(String email) async {
    await _repository.passwordReset(email);
  }

  Future<void> logout() async {
    state = const AsyncLoading();
    try {
      await _repository.logout();
      state = const AsyncData(AuthState(isAuthenticated: false));
    } catch (error, stackTrace) {
      state = AsyncError(error, stackTrace);
    }
  }

  @override
  void dispose() {
    _authSubscription.cancel();
    super.dispose();
  }
}
