import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:smart_student_companion/firebase_options.dart';

/// Runs Parent phone verification in a secondary Firebase Auth session. The
/// primary session remains the authenticated Student who approves the link.
class ParentRegistrationService {
  ParentRegistrationService({
    FirebaseAuth? studentAuth,
    FirebaseFunctions? functions,
  }) : _customStudentAuth = studentAuth,
       _customFunctions = functions;

  static const _secondaryAppName = 'parent-registration-phone';
  final FirebaseAuth? _customStudentAuth;
  FirebaseAuth get _studentAuth => _customStudentAuth ?? FirebaseAuth.instance;
  final FirebaseFunctions? _customFunctions;
  FirebaseFunctions get _functions =>
      _customFunctions ?? FirebaseFunctions.instanceFor(region: 'us-central1');
  FirebaseApp? _secondaryApp;
  FirebaseAuth? _phoneAuth;
  String? _verificationId;

  Future<Map<String, dynamic>> validateStudent({
    required String studentName,
    required String rollNumber,
  }) async {
    final student = _studentAuth.currentUser;
    if (student == null) {
      throw StateError(
        'Sign in to the Student account before approving a Parent link.',
      );
    }
    debugPrint(
      '[parent-registration] callable=validateParentRegistrationStudent stage=start',
    );
    late final HttpsCallableResult<dynamic> result;
    try {
      result = await _functions
          .httpsCallable('validateParentRegistrationStudent')
          .call({
            'studentName': studentName.trim(),
            'rollNumber': rollNumber.trim(),
          });
    } on FirebaseFunctionsException catch (error) {
      debugPrint(
        '[parent-registration] callable=validateParentRegistrationStudent stage=failed code=${error.code}',
      );
      rethrow;
    } catch (error) {
      debugPrint(
        '[parent-registration] callable=validateParentRegistrationStudent stage=failed errorType=${error.runtimeType}',
      );
      rethrow;
    }
    debugPrint(
      '[parent-registration] callable=validateParentRegistrationStudent stage=complete',
    );
    return Map<String, dynamic>.from(result.data as Map);
  }

  Future<void> sendCode({
    required String phoneNumber,
    required void Function(String verificationId, int? resendToken) onCodeSent,
    required void Function(PhoneAuthCredential credential) onAutoVerified,
    required void Function(FirebaseAuthException error) onError,
    int? resendToken,
  }) async {
    final phone = _normalizePhone(phoneNumber);
    final secondaryAuth = await _getSecondaryAuth();
    await secondaryAuth.verifyPhoneNumber(
      phoneNumber: phone,
      forceResendingToken: resendToken,
      timeout: const Duration(seconds: 60),
      verificationCompleted: onAutoVerified,
      verificationFailed: onError,
      codeSent: (verificationId, nextResendToken) {
        _verificationId = verificationId;
        onCodeSent(verificationId, nextResendToken);
      },
      codeAutoRetrievalTimeout: (verificationId) =>
          _verificationId = verificationId,
    );
  }

  Future<Map<String, dynamic>> verifyAndRegister({
    required String studentName,
    required String rollNumber,
    String? smsCode,
    PhoneAuthCredential? automaticCredential,
  }) async {
    final student = _studentAuth.currentUser;
    if (student == null) {
      throw StateError(
        'The Student session ended. Sign in again before continuing.',
      );
    }
    final verificationId = _verificationId;
    if (automaticCredential == null &&
        (verificationId == null || (smsCode?.trim().length != 6))) {
      throw StateError('Enter the six-digit code sent to the Parent phone.');
    }
    final phoneAuth = await _getSecondaryAuth();
    final credential =
        automaticCredential ??
        PhoneAuthProvider.credential(
          verificationId: verificationId!,
          smsCode: smsCode!.trim(),
        );
    debugPrint('[parent-registration] stage=phone_credential_verification');
    final result = await phoneAuth.signInWithCredential(credential);
    final parent = result.user;
    if (parent == null || parent.phoneNumber == null) {
      throw StateError('Firebase did not verify the Parent phone identity.');
    }
    final parentIdToken = await parent.getIdToken(true);
    if (parentIdToken == null || parentIdToken.isEmpty) {
      throw StateError('Firebase did not issue a verified Parent phone token.');
    }

    // The callable uses the primary Firebase Auth session, which is still the
    // approving Student. The separately verified phone token proves consent.
    debugPrint('[parent-registration] callable=registerParentLink stage=start');
    late final HttpsCallableResult<dynamic> response;
    try {
      response = await _functions.httpsCallable('registerParentLink').call({
        'studentName': studentName.trim(),
        'rollNumber': rollNumber.trim(),
        'parentIdToken': parentIdToken,
      });
    } on FirebaseFunctionsException catch (error) {
      debugPrint(
        '[parent-registration] callable=registerParentLink stage=failed code=${error.code}',
      );
      rethrow;
    } catch (error) {
      debugPrint(
        '[parent-registration] callable=registerParentLink stage=failed errorType=${error.runtimeType}',
      );
      rethrow;
    }
    debugPrint('[parent-registration] callable=registerParentLink stage=complete');
    return Map<String, dynamic>.from(response.data as Map);
  }

  Future<void> cancel() async {
    final auth = _phoneAuth;
    final app = _secondaryApp;
    _phoneAuth = null;
    _secondaryApp = null;
    _verificationId = null;
    if (auth != null) {
      try {
        await auth.signOut();
      } catch (error) {
        debugPrint('[parent-registration] secondary sign-out failed: $error');
      }
    }
    if (app != null) {
      try {
        await app.delete();
      } catch (error) {
        debugPrint(
          '[parent-registration] secondary app cleanup failed: $error',
        );
      }
    }
  }

  Future<FirebaseAuth> _getSecondaryAuth() async {
    if (_phoneAuth != null) return _phoneAuth!;
    FirebaseApp app;
    try {
      app = Firebase.app(_secondaryAppName);
    } on FirebaseException {
      app = await Firebase.initializeApp(
        name: _secondaryAppName,
        options: DefaultFirebaseOptions.currentPlatform,
      );
    }
    _secondaryApp = app;
    return _phoneAuth = FirebaseAuth.instanceFor(app: app);
  }

  static String _normalizePhone(String input) {
    final trimmed = input.trim().replaceAll(RegExp(r'[\s()-]'), '');
    final digits = trimmed.replaceAll(RegExp(r'\D'), '');
    final normalized = trimmed.startsWith('+')
        ? '+$digits'
        : digits.length == 10
        ? '+91$digits'
        : '+$digits';
    if (!RegExp(r'^\+[1-9]\d{7,14}$').hasMatch(normalized)) {
      throw FormatException(
        'Enter a valid international phone number, such as +919876543210.',
      );
    }
    return normalized;
  }
}
