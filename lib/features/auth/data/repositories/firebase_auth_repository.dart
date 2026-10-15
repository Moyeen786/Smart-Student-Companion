import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:smart_student_companion/features/auth/data/repositories/auth_repository.dart';
import 'package:smart_student_companion/models/user_model.dart';

class FirebaseAuthRepository implements AuthRepository {
  FirebaseAuthRepository({
    FirebaseAuth? auth,
    this.firestore,
    this.profileReader,
  }) : _auth = auth ?? FirebaseAuth.instance;

  final FirebaseAuth _auth;
  final FirebaseFirestore? firestore;
  FirebaseFirestore get _db => firestore ?? FirebaseFirestore.instance;
  final Future<Map<String, dynamic>?> Function(String uid)? profileReader;
  final Map<String, Future<UserModel>> _profileChecks = {};

  @override
  Stream<UserModel?> get authStateChanges =>
      _auth.idTokenChanges().asyncExpand(_resolveAuthEvent);

  Stream<UserModel?> _resolveAuthEvent(User? firebaseUser) async* {
    // An earlier auth event can finish profile resolution after a newer login
    // or sign-out. Ignore that stale result instead of replacing the new state.
    if (!_isCurrentUser(firebaseUser)) return;
    if (firebaseUser == null) {
      yield null;
      return;
    }

    try {
      final user = await _profileOrSignOut(firebaseUser);
      if (_isCurrentUser(firebaseUser)) yield user;
    } catch (_) {
      if (_isCurrentUser(firebaseUser)) rethrow;
    }
  }

  bool _isCurrentUser(User? user) => _auth.currentUser?.uid == user?.uid;

  @override
  Future<UserModel?> currentUser() async {
    final firebaseUser = _auth.currentUser;
    if (firebaseUser == null) return null;
    return _profileOrSignOut(firebaseUser);
  }

  @override
  Future<UserModel> login(String email, String password) async {
    String resolvedEmail = email.trim();
    if (!resolvedEmail.contains('@')) {
      try {
        final snap = await _db
            .collection('users')
            .where('rollNumber', isEqualTo: resolvedEmail.toUpperCase())
            .limit(1)
            .get();
        if (snap.docs.isNotEmpty && snap.docs.first.data()['email'] != null) {
          resolvedEmail = snap.docs.first.data()['email'] as String;
        } else {
          resolvedEmail = '$resolvedEmail@campus.edu';
        }
      } catch (_) {
        resolvedEmail = '$resolvedEmail@campus.edu';
      }
    }
    late final UserCredential credential;
    try {
      credential = await _auth.signInWithEmailAndPassword(
        email: resolvedEmail,
        password: password,
      );
    } on FirebaseAuthException catch (error) {
      debugPrint('[auth] stage=signIn errorCode=${error.code}');
      rethrow;
    }
    final firebaseUser = credential.user;
    if (firebaseUser == null) throw Exception('Unable to sign in.');
    return _profileOrSignOut(firebaseUser);
  }

  @override
  Future<UserModel> register({
    required UserRole role,
    required String name,
    required String email,
    required String password,
    required Map<String, String> profile,
  }) async {
    if (role == UserRole.admin || role == UserRole.parent) {
      throw StateError(
        '${role.name} accounts must be created by trusted provisioning.',
      );
    }

    final credential = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    final firebaseUser = credential.user;
    if (firebaseUser == null) throw Exception('Unable to create account.');
    final user = UserModel(
      uid: firebaseUser.uid,
      name: name,
      email: email,
      role: role,
      department: profile['department'] ?? '',
      semester: int.tryParse(profile['semester'] ?? '') ?? 0,
      createdAt: DateTime.now(),
      rollNumber: profile['rollNumber'] ?? profile['accountId'] ?? '',
    );
    final userProfileData = user.toMap()
      ..remove('parentName')
      ..remove('parentPhone')
      ..remove('childStudentId')
      ..remove('cgpa')
      ..remove('overallAttendance');
    await _db.collection('users').doc(user.uid).set(userProfileData);
    return user;
  }

  @override
  Future<void> logout() => _auth.signOut();

  @override
  Future<void> passwordReset(String email) =>
      _auth.sendPasswordResetEmail(email: email);

  Future<UserModel> _profileFor(User firebaseUser) async {
    final data = await _readProfile(firebaseUser.uid);
    if (data == null) {
      debugPrint('[auth] stage=profileLookup outcome=missing');
      throw Exception('Your account profile could not be found.');
    }
    if (data['role'] == null) {
      debugPrint('[auth] stage=profileValidation outcome=missing-role');
      throw Exception('Your account role has not been configured.');
    }
    final createdAt = data['createdAt'];
    final user = UserModel.fromMap({
      ...data,
      'uid': firebaseUser.uid,
      'createdAt': createdAt is Timestamp ? createdAt.toDate() : createdAt,
    });
    if (user.role == UserRole.admin || user.role == UserRole.parent) {
      // User objects captured from auth streams may outlive the active session.
      // Check the current session before asking Firebase for a token so a
      // sign-out race is reported as a session change, not no-current-user.
      if (!_isCurrentUser(firebaseUser)) {
        debugPrint('[auth] stage=privilegedClaimRefresh outcome=stale-session');
        throw StateError('The authentication session changed during login.');
      }
      late final IdTokenResult token;
      try {
        token = await firebaseUser.getIdTokenResult(true);
      } on FirebaseAuthException catch (error) {
        debugPrint(
          '[auth] stage=privilegedClaimRefresh errorCode=${error.code}',
        );
        if (error.code == 'no-current-user' && !_isCurrentUser(firebaseUser)) {
          throw StateError(
            'The authentication session changed during claim validation.',
          );
        }
        rethrow;
      }
      final claims = token.claims ?? const <String, dynamic>{};
      final isTrustedAdmin =
          user.role == UserRole.admin && claims['admin'] == true;
      final isTrustedParent =
          user.role == UserRole.parent &&
          claims['role'] == 'parent' &&
          claims['childStudentId'] == user.childStudentId;
      if (!isTrustedAdmin && !isTrustedParent) {
        debugPrint(
          '[auth] stage=privilegedClaimValidation outcome=claim-missing-or-mismatch',
        );
        throw StateError(
          'This privileged account has not been trusted by provisioning.',
        );
      }
      debugPrint('[auth] stage=privilegedClaimValidation outcome=verified');
    }
    return user;
  }

  Future<Map<String, dynamic>?> _readProfile(String uid) async {
    final reader = profileReader;
    if (reader != null) return reader(uid);
    try {
      final snapshot = await _db.collection('users').doc(uid).get();
      return snapshot.data();
    } on FirebaseException catch (error) {
      debugPrint('[auth] stage=profileLookup errorCode=${error.code}');
      rethrow;
    }
  }

  Future<UserModel> _profileOrSignOut(User firebaseUser) {
    final existing = _profileChecks[firebaseUser.uid];
    if (existing != null) return existing;

    late final Future<UserModel> check;
    check = _validateProfileOrSignOut(firebaseUser).whenComplete(() {
      if (identical(_profileChecks[firebaseUser.uid], check)) {
        _profileChecks.remove(firebaseUser.uid);
      }
    });
    _profileChecks[firebaseUser.uid] = check;
    return check;
  }

  Future<UserModel> _validateProfileOrSignOut(User firebaseUser) async {
    try {
      return await _profileFor(firebaseUser);
    } catch (error, stackTrace) {
      if (_auth.currentUser?.uid == firebaseUser.uid) {
        // Preserve the profile/claim failure if another auth transition races
        // with cleanup. The original validation error is actionable to login.
        try {
          await _auth.signOut();
        } catch (_) {
          Error.throwWithStackTrace(error, stackTrace);
        }
      }
      Error.throwWithStackTrace(error, stackTrace);
    }
  }
}
