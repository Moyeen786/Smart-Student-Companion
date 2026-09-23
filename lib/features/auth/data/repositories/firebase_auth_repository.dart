import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:smart_student_companion/features/auth/data/repositories/auth_repository.dart';
import 'package:smart_student_companion/models/user_model.dart';

class FirebaseAuthRepository implements AuthRepository {
  FirebaseAuthRepository({FirebaseAuth? auth, FirebaseFirestore? firestore})
    : _auth = auth ?? FirebaseAuth.instance,
      _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;

  @override
  Stream<UserModel?> get authStateChanges => _auth.authStateChanges().asyncMap(
    (firebaseUser) => firebaseUser == null ? null : _profileFor(firebaseUser),
  );

  @override
  Future<UserModel?> currentUser() async {
    final firebaseUser = _auth.currentUser;
    if (firebaseUser == null) return null;
    return _profileFor(firebaseUser);
  }

  @override
  Future<UserModel> login(String email, String password) async {
    final credential = await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    final firebaseUser = credential.user;
    if (firebaseUser == null) throw Exception('Unable to sign in.');
    return _profileFor(firebaseUser);
  }

  @override
  Future<UserModel> register({
    required UserRole role,
    required String name,
    required String email,
    required String password,
    required Map<String, String> profile,
  }) async {
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
    await _firestore.collection('users').doc(user.uid).set(user.toMap());
    return user;
  }

  @override
  Future<void> logout() => _auth.signOut();

  @override
  Future<void> passwordReset(String email) =>
      _auth.sendPasswordResetEmail(email: email);

  Future<UserModel> _profileFor(User firebaseUser) async {
    final snapshot = await _firestore
        .collection('users')
        .doc(firebaseUser.uid)
        .get();
    if (!snapshot.exists || snapshot.data() == null) {
      throw Exception('Your account profile could not be found.');
    }
    final data = snapshot.data()!;
    if (data['role'] == null) {
      throw Exception('Your account role has not been configured.');
    }
    final createdAt = data['createdAt'];
    return UserModel.fromMap({
      ...data,
      'uid': firebaseUser.uid,
      'createdAt': createdAt is Timestamp ? createdAt.toDate() : createdAt,
    });
  }
}
