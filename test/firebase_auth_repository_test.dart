import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:smart_student_companion/features/auth/data/repositories/firebase_auth_repository.dart';
import 'package:smart_student_companion/models/user_model.dart';

class _MockFirebaseAuth extends Mock implements FirebaseAuth {
  User? activeUser;
  UserCredential? nextCredential;

  @override
  User? get currentUser => activeUser;

  @override
  Future<UserCredential> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    final credential = nextCredential!;
    activeUser = credential.user;
    return credential;
  }

  @override
  Future<void> signOut() async {
    activeUser = null;
  }
}

class _MockUser extends Mock implements User {}

class _MockUserCredential extends Mock implements UserCredential {}

class _MockIdTokenResult extends Mock implements IdTokenResult {}

void main() {
  late _MockFirebaseAuth auth;
  late Map<String, Map<String, dynamic>> profiles;
  late FirebaseAuthRepository repository;

  setUp(() {
    auth = _MockFirebaseAuth();
    profiles = {};
    repository = FirebaseAuthRepository(
      auth: auth,
      profileReader: (uid) async => profiles[uid],
    );
  });

  test('Faculty logout followed by trusted Admin login succeeds', () async {
    final faculty = _makeUser('faculty-1');
    final admin = _makeUser('admin-1');
    final facultyCredential = _credential(faculty);
    final adminCredential = _credential(admin);
    profiles['faculty-1'] = _profile('faculty');
    profiles['admin-1'] = _profile('admin');
    final token = _MockIdTokenResult();
    when(() => token.claims).thenReturn({'admin': true});
    when(() => admin.getIdTokenResult(true)).thenAnswer((_) async => token);
    auth.nextCredential = facultyCredential;

    final facultyProfile = await repository.login('faculty@test.edu', 'pw');
    expect(facultyProfile.role, UserRole.faculty);
    await repository.logout();
    expect(auth.currentUser, isNull);

    auth.nextCredential = adminCredential;
    final adminProfile = await repository.login('admin@amrita.edu', 'pw');
    expect(adminProfile.role, UserRole.admin);
    expect(auth.currentUser?.uid, 'admin-1');
    verify(() => admin.getIdTokenResult(true)).called(1);
  });

  test(
    'Admin without the server custom claim is signed out and rejected',
    () async {
      final admin = _makeUser('admin-no-claim');
      auth.nextCredential = _credential(admin);
      profiles['admin-no-claim'] = _profile('admin');
      final token = _MockIdTokenResult();
      when(() => token.claims).thenReturn(const {});
      when(() => admin.getIdTokenResult(true)).thenAnswer((_) async => token);

      await expectLater(
        repository.login('admin@amrita.edu', 'pw'),
        throwsA(isA<StateError>()),
      );
      expect(auth.currentUser, isNull);
    },
  );

  test(
    'missing Admin profile is rejected and the user is signed out',
    () async {
      final admin = _makeUser('missing-admin-profile');
      auth.nextCredential = _credential(admin);
      await expectLater(
        repository.login('admin@amrita.edu', 'pw'),
        throwsA(isA<Exception>()),
      );
      expect(auth.currentUser, isNull);
    },
  );

  test(
    'no-current-user during claim refresh is reported as a session race',
    () async {
      final admin = _makeUser('admin-session-race');
      auth.nextCredential = _credential(admin);
      profiles['admin-session-race'] = _profile('admin');
      when(() => admin.getIdTokenResult(true)).thenAnswer((_) async {
        auth.activeUser = null;
        throw FirebaseAuthException(
          code: 'no-current-user',
          message: 'No user currently signed in.',
        );
      });

      await expectLater(
        repository.login('admin@amrita.edu', 'pw'),
        throwsA(
          isA<StateError>().having(
            (error) => error.message,
            'message',
            contains('session changed'),
          ),
        ),
      );
    },
  );

  test('null Firebase currentUser resolves to unauthenticated state', () async {
    expect(await repository.currentUser(), isNull);
  });
}

_MockUser _makeUser(String uid) {
  final user = _MockUser();
  when(() => user.uid).thenReturn(uid);
  return user;
}

_MockUserCredential _credential(User user) {
  final credential = _MockUserCredential();
  when(() => credential.user).thenReturn(user);
  return credential;
}

Map<String, dynamic> _profile(String role) => {
  'name': role,
  'email': '$role@test.edu',
  'role': role,
  'department': '',
  'semester': 0,
  'createdAt': DateTime(2024),
  'rollNumber': '',
};
