import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:smart_student_companion/app/app_providers.dart';
import 'package:smart_student_companion/core/theme/app_colors.dart';
import 'package:smart_student_companion/core/widgets/app_button.dart';
import 'package:smart_student_companion/core/widgets/app_card.dart';
import 'package:smart_student_companion/core/widgets/app_text_field.dart';
import 'package:smart_student_companion/features/parent/data/parent_providers.dart';
import 'package:smart_student_companion/models/user_model.dart';

class ParentPhoneVerificationScreen extends ConsumerStatefulWidget {
  const ParentPhoneVerificationScreen({
    super.key,
    this.parentLoginOnly = false,
  });

  final bool parentLoginOnly;

  @override
  ConsumerState<ParentPhoneVerificationScreen> createState() =>
      _ParentPhoneVerificationScreenState();
}

class _ParentPhoneVerificationScreenState
    extends ConsumerState<ParentPhoneVerificationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController();
  bool _isLoading = false;
  String? _errorMessage;
  bool _isNotRegistered = false;

  // OTP Verification state on the same flow/page
  bool _otpSent = false;
  final List<TextEditingController> _otpControllers = List.generate(
    6,
    (_) => TextEditingController(),
  );
  final List<FocusNode> _focusNodes = List.generate(6, (_) => FocusNode());
  int _resendCountdown = 45;
  Timer? _timer;
  bool _isVerifying = false;
  String? _otpErrorMessage;
  int _otpRequestGeneration = 0;

  @override
  void dispose() {
    _timer?.cancel();
    _phoneController.dispose();
    for (final c in _otpControllers) {
      c.dispose();
    }
    for (final f in _focusNodes) {
      f.dispose();
    }
    super.dispose();
  }

  void _startCountdown() {
    _timer?.cancel();
    setState(() => _resendCountdown = 45);
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_resendCountdown > 0) {
        setState(() => _resendCountdown--);
      } else {
        timer.cancel();
      }
    });
  }

  String get _currentOtp => _otpControllers.map((c) => c.text).join();

  void _onDigitChanged(int index, String value) {
    setState(() => _otpErrorMessage = null);

    if (value.isNotEmpty) {
      if (index < 5) {
        _focusNodes[index + 1].requestFocus();
      } else {
        _focusNodes[index].unfocus();
        if (_currentOtp.length == 6) {
          _handleVerifyOtp();
        }
      }
    }
  }

  Future<void> _handleGetOtp() async {
    if (!_formKey.currentState!.validate()) return;

    final candidateStudent = _candidateStudent;

    if (!widget.parentLoginOnly && candidateStudent == null) {
      context.go('/login');
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _isNotRegistered = false;
    });

    final inputPhone = _phoneController.text.trim();
    final authService = ref.read(parentAuthServiceProvider);

    try {
      // Student-initiated linking is only available for a phone already
      // registered on the authenticated student's profile. Parent sign-in
      // sends an OTP first; the signed-in token/profile are checked after it.
      final isRegistered = widget.parentLoginOnly
          ? true
          : await authService.verifyParentMobileAgainstFirestore(
              studentUid: candidateStudent!.uid,
              inputPhone: inputPhone,
            );

      if (!isRegistered) {
        if (mounted) {
          setState(() {
            _isLoading = false;
            _isNotRegistered = true;
            _errorMessage = 'Mobile number not registered.';
          });
        }
        return;
      }

      // If registered: save verified phone and send OTP via Firebase Phone Auth
      ref.read(parentVerifiedPhoneProvider.notifier).state = inputPhone;
      final requestGeneration = ++_otpRequestGeneration;

      await authService.sendFirebasePhoneOtp(
        phoneNumber: inputPhone,
        onCodeSent: (verificationId, resendToken) {
          if (!mounted || requestGeneration != _otpRequestGeneration) return;
          ref.read(parentVerificationIdProvider.notifier).state =
              verificationId;
          ref.read(parentResendTokenProvider.notifier).state = resendToken;
          setState(() {
            _isLoading = false;
            _otpSent = true;
            _errorMessage = null;
            _isNotRegistered = false;
          });
          _startCountdown();
        },
        onError: (error) {
          if (!mounted || requestGeneration != _otpRequestGeneration) return;
          setState(() {
            _isLoading = false;
            _otpSent = false;
            _errorMessage = error;
            _isNotRegistered = false;
          });
        },
        onAutoVerified: (credential) {
          if (requestGeneration != _otpRequestGeneration) return;
          unawaited(
            _completeParentSignIn(
              authService: authService,
              candidateStudent: candidateStudent,
              verifiedPhone: inputPhone,
              requestGeneration: requestGeneration,
              automaticCredential: credential,
            ),
          );
        },
        onTimeout: (verificationId) {
          if (!mounted || requestGeneration != _otpRequestGeneration) return;
          ref.read(parentVerificationIdProvider.notifier).state =
              verificationId;
          setState(() {
            _isLoading = false;
            _otpErrorMessage =
                'Automatic code retrieval timed out. Enter the SMS code or resend it.';
          });
        },
      );
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = e.toString().replaceFirst('Exception: ', '');
        });
      }
    }
  }

  Future<void> _handleResendOtp() async {
    if (_resendCountdown > 0) return;

    final verifiedPhone = ref.read(parentVerifiedPhoneProvider);
    final resendToken = ref.read(parentResendTokenProvider);
    final authService = ref.read(parentAuthServiceProvider);

    if (verifiedPhone.isEmpty) {
      _cancelOtp();
      return;
    }

    for (final c in _otpControllers) {
      c.clear();
    }
    _focusNodes[0].requestFocus();
    _startCountdown();
    final requestGeneration = ++_otpRequestGeneration;

    await authService.sendFirebasePhoneOtp(
      phoneNumber: verifiedPhone,
      forceResendingToken: resendToken,
      onCodeSent: (newVerificationId, newResendToken) {
        if (!mounted || requestGeneration != _otpRequestGeneration) return;
        ref.read(parentVerificationIdProvider.notifier).state =
            newVerificationId;
        ref.read(parentResendTokenProvider.notifier).state = newResendToken;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            backgroundColor: AppColors.primary,
            behavior: SnackBarBehavior.floating,
            content: Text('A new OTP has been sent to your mobile number.'),
            duration: Duration(seconds: 4),
          ),
        );
      },
      onError: (err) {
        if (!mounted || requestGeneration != _otpRequestGeneration) return;
        _timer?.cancel();
        setState(() {
          _resendCountdown = 0;
          _otpErrorMessage = err;
        });
      },
      onAutoVerified: (credential) {
        if (requestGeneration != _otpRequestGeneration) return;
        final candidateStudent = _candidateStudent;
        if (!widget.parentLoginOnly && candidateStudent == null) return;
        unawaited(
          _completeParentSignIn(
            authService: authService,
            candidateStudent: candidateStudent,
            verifiedPhone: verifiedPhone,
            requestGeneration: requestGeneration,
            automaticCredential: credential,
          ),
        );
      },
      onTimeout: (verificationId) {
        if (!mounted || requestGeneration != _otpRequestGeneration) return;
        ref.read(parentVerificationIdProvider.notifier).state = verificationId;
        setState(() {
          _otpErrorMessage =
              'Automatic code retrieval timed out. Enter the SMS code or resend it.';
        });
      },
    );
  }

  Future<void> _handleVerifyOtp() async {
    if (_isVerifying) return;
    final candidateStudent = _candidateStudent;
    if (!widget.parentLoginOnly && candidateStudent == null) {
      context.go('/login');
      return;
    }

    final otp = _currentOtp;
    if (otp.length != 6) {
      setState(() => _otpErrorMessage = 'Please enter complete 6-digit OTP.');
      return;
    }

    setState(() {
      _isVerifying = true;
      _otpErrorMessage = null;
    });

    final verificationId = ref.read(parentVerificationIdProvider);
    final authService = ref.read(parentAuthServiceProvider);
    final requestGeneration = _otpRequestGeneration;

    final verifiedPhone = ref.read(parentVerifiedPhoneProvider);
    try {
      final parentUser = await authService.signInParentWithOtp(
        otp: otp,
        verificationId: verificationId ?? '',
        studentUid: candidateStudent?.uid,
        verifiedPhone: verifiedPhone,
      );
      if (!mounted || requestGeneration != _otpRequestGeneration) {
        await authService.cancelPhoneSignIn();
        return;
      }
      _finishParentSession(candidateStudent, parentUser);
    } on FirebaseAuthException catch (error) {
      if (mounted && requestGeneration == _otpRequestGeneration) {
        setState(() {
          _isVerifying = false;
          _otpErrorMessage = _phoneAuthErrorMessage(error);
        });
      }
    } catch (error) {
      if (mounted && requestGeneration == _otpRequestGeneration) {
        setState(() {
          _isVerifying = false;
          _otpErrorMessage = error.toString().replaceFirst('Bad state: ', '');
        });
      }
    }
  }

  Future<void> _completeParentSignIn({
    required ParentAuthService authService,
    required UserModel? candidateStudent,
    required String verifiedPhone,
    required int requestGeneration,
    PhoneAuthCredential? automaticCredential,
  }) async {
    if (!mounted || requestGeneration != _otpRequestGeneration) return;
    setState(() {
      _isVerifying = true;
      _otpErrorMessage = null;
    });
    try {
      final parentUser = await authService.signInParentWithOtp(
        otp: '',
        verificationId: '',
        studentUid: candidateStudent?.uid,
        verifiedPhone: verifiedPhone,
        automaticCredential: automaticCredential,
      );
      if (!mounted || requestGeneration != _otpRequestGeneration) {
        await authService.cancelPhoneSignIn();
        return;
      }
      _finishParentSession(candidateStudent, parentUser);
    } on FirebaseAuthException catch (error) {
      if (mounted && requestGeneration == _otpRequestGeneration) {
        setState(() {
          _isVerifying = false;
          _otpErrorMessage = _phoneAuthErrorMessage(error);
        });
      }
    } catch (error) {
      if (mounted && requestGeneration == _otpRequestGeneration) {
        setState(() {
          _isVerifying = false;
          _otpErrorMessage = error.toString().replaceFirst('Bad state: ', '');
        });
      }
    }
  }

  void _finishParentSession(UserModel? candidateStudent, UserModel parentUser) {
    // Do not manufacture academic records from the student's profile. The
    // linked data provider will populate this when an authorized data source
    // is configured.
    ref.read(parentActiveChildSummaryProvider.notifier).state = null;
    ref.read(authStateProvider.notifier).setAuthenticatedUser(parentUser);
    if (mounted) context.go('/parent');
  }

  UserModel? get _candidateStudent {
    final cached = ref.read(parentCandidateStudentProvider);
    final authenticated = ref.read(authStateProvider).valueOrNull;
    final user = cached ?? authenticated?.user;
    if (authenticated?.isAuthenticated != true ||
        user?.role != UserRole.student) {
      return null;
    }
    if (cached != null && cached.uid != authenticated?.user?.uid) return null;
    return user;
  }

  String _phoneAuthErrorMessage(FirebaseAuthException error) {
    switch (error.code) {
      case 'invalid-verification-code':
        return 'The verification code is invalid. Check the SMS and try again.';
      case 'session-expired':
      case 'code-expired':
        return 'The verification code expired. Request a new code.';
      case 'network-request-failed':
        return 'Network error. Check your connection and try again.';
      case 'too-many-requests':
      case 'quota-exceeded':
        return 'Too many verification attempts. Wait before requesting another code.';
      case 'invalid-phone-number':
        return 'The phone number is invalid. Enter a valid number and try again.';
      default:
        return error.message ?? 'Phone verification failed. Please try again.';
    }
  }

  void _cancelOtp() {
    _otpRequestGeneration++;
    _timer?.cancel();
    ref.read(parentVerificationIdProvider.notifier).state = null;
    ref.read(parentResendTokenProvider.notifier).state = null;
    ref.read(parentVerifiedPhoneProvider.notifier).state = '';
    for (final controller in _otpControllers) {
      controller.clear();
    }
    setState(() {
      _otpSent = false;
      _isLoading = false;
      _isVerifying = false;
      _otpErrorMessage = null;
      _resendCountdown = 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    final candidateStudent = _candidateStudent;

    if (!widget.parentLoginOnly && candidateStudent == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        context.go('/login');
      });
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final verifiedPhone = ref.watch(parentVerifiedPhoneProvider);
    final displayPhone = verifiedPhone.isNotEmpty
        ? verifiedPhone
        : _phoneController.text.trim();
    final maskedPhone = ParentAuthService.maskPhoneNumber(displayPhone);

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 560),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      IconButton(
                        onPressed: () {
                          if (_otpSent) {
                            _cancelOtp();
                          } else {
                            _cancelOtp();
                            context.go(
                              widget.parentLoginOnly
                                  ? '/login'
                                  : '/who-are-you',
                            );
                          }
                        },
                        icon: const Icon(Icons.arrow_back),
                        tooltip: _otpSent
                            ? 'Back to mobile number'
                            : 'Back to role verification',
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'SMART STUDENT COMPANION',
                        style: Theme.of(context).textTheme.labelLarge?.copyWith(
                          color: AppColors.primary,
                          letterSpacing: 1.2,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Text(
                    widget.parentLoginOnly
                        ? 'Parent Sign In'
                        : 'Parent Verification',
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    widget.parentLoginOnly
                        ? (_otpSent
                              ? 'Enter the verification code sent to your registered phone.'
                              : 'Sign in with the phone number registered to your Parent account.')
                        : _otpSent
                        ? "We've sent a verification code to your registered mobile number."
                        : 'Enter your registered mobile number',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Show student context only in the student-authorized flow.
                  if (!widget.parentLoginOnly)
                    AppCard(
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 22,
                            backgroundColor: AppColors.primary.withOpacity(0.1),
                            child: const Icon(
                              Icons.school_rounded,
                              color: AppColors.primary,
                              size: 24,
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  candidateStudent!.name,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 15,
                                  ),
                                ),
                                Text(
                                  'Roll No: ${candidateStudent!.rollNumber} • ${candidateStudent.department}',
                                  style: const TextStyle(
                                    color: AppColors.textSecondary,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  if (!widget.parentLoginOnly) const SizedBox(height: 24),

                  // PHASE 1: MOBILE NUMBER ENTRY
                  if (!_otpSent) ...[
                    Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          AppTextField(
                            label: 'Registered Mobile Number',
                            hintText: '+91 98765 43210',
                            controller: _phoneController,
                            keyboardType: TextInputType.phone,
                            prefixIcon: Icons.phone_android_outlined,
                            onChanged: (_) {
                              if (_isNotRegistered || _errorMessage != null) {
                                setState(() {
                                  _isNotRegistered = false;
                                  _errorMessage = null;
                                });
                              }
                            },
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Please enter your registered mobile number.';
                              }
                              if (ParentAuthService.extractDigits(
                                    value,
                                  ).length <
                                  8) {
                                return 'Enter a valid mobile number with at least 8 digits.';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 8),
                          Padding(
                            padding: const EdgeInsets.only(left: 4),
                            child: Text(
                              'An OTP will be dispatched via Firebase Phone Authentication.',
                              style: Theme.of(context).textTheme.bodySmall
                                  ?.copyWith(color: AppColors.textSecondary),
                            ),
                          ),
                          // Inline error/warning message
                          if (_errorMessage != null) ...[
                            const SizedBox(height: 14),
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: AppColors.danger.withOpacity(0.08),
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color: AppColors.danger.withOpacity(0.2),
                                ),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      const Icon(
                                        Icons.warning_amber_rounded,
                                        color: AppColors.danger,
                                        size: 20,
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          _errorMessage!,
                                          style: const TextStyle(
                                            color: AppColors.danger,
                                            fontWeight: FontWeight.w600,
                                            fontSize: 13,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  if (_isNotRegistered) ...[
                                    const SizedBox(height: 8),
                                    InkWell(
                                      onTap: () =>
                                          context.go('/register/select-role'),
                                      child: const Text(
                                        "Don't have a registered account? Register here",
                                        style: TextStyle(
                                          color: AppColors.primary,
                                          fontWeight: FontWeight.w600,
                                          fontSize: 13,
                                          decoration: TextDecoration.underline,
                                        ),
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ],
                          const SizedBox(height: 24),
                          AppButton(
                            label: 'GET OTP',
                            isLoading: _isLoading,
                            onPressed: _handleGetOtp,
                          ),
                          const SizedBox(height: 16),
                          Center(
                            child: TextButton.icon(
                              onPressed: () => context.go(
                                widget.parentLoginOnly
                                    ? '/login'
                                    : '/who-are-you',
                              ),
                              icon: const Icon(Icons.arrow_back, size: 16),
                              label: Text(
                                widget.parentLoginOnly
                                    ? 'Back to Sign In'
                                    : 'Back to Identity Selection',
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],

                  // PHASE 2: OTP INPUT ON THE SAME FLOW/PAGE
                  if (_otpSent) ...[
                    // Masked phone display chip
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.phone_android_rounded,
                            size: 18,
                            color: AppColors.primary,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            maskedPhone,
                            style: const TextStyle(
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.5,
                            ),
                          ),
                          const Spacer(),
                          TextButton(
                            onPressed: _cancelOtp,
                            child: const Text('Change Number'),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    // 6-Digit OTP Boxes
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: List.generate(6, (index) {
                        final hasError = _otpErrorMessage != null;
                        return SizedBox(
                          width: 48,
                          height: 56,
                          child: KeyboardListener(
                            focusNode: FocusNode(),
                            onKeyEvent: (event) {
                              if (event is KeyDownEvent &&
                                  event.logicalKey ==
                                      LogicalKeyboardKey.backspace &&
                                  _otpControllers[index].text.isEmpty &&
                                  index > 0) {
                                _focusNodes[index - 1].requestFocus();
                              }
                            },
                            child: TextField(
                              controller: _otpControllers[index],
                              focusNode: _focusNodes[index],
                              keyboardType: TextInputType.number,
                              textAlign: TextAlign.center,
                              maxLength: 1,
                              style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textPrimary,
                              ),
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly,
                              ],
                              decoration: InputDecoration(
                                counterText: '',
                                contentPadding: EdgeInsets.zero,
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(
                                    color: hasError
                                        ? AppColors.danger
                                        : AppColors.border,
                                    width: hasError ? 1.5 : 1,
                                  ),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(
                                    color: hasError
                                        ? AppColors.danger
                                        : AppColors.primary,
                                    width: 2,
                                  ),
                                ),
                                filled: true,
                                fillColor: AppColors.card,
                              ),
                              onChanged: (val) => _onDigitChanged(index, val),
                            ),
                          ),
                        );
                      }),
                    ),
                    if (_otpErrorMessage != null) ...[
                      const SizedBox(height: 14),
                      Row(
                        children: [
                          const Icon(
                            Icons.error_outline_rounded,
                            color: AppColors.danger,
                            size: 18,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              _otpErrorMessage!,
                              style: const TextStyle(
                                color: AppColors.danger,
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                    const SizedBox(height: 28),
                    AppButton(
                      label: 'VERIFY OTP',
                      isLoading: _isVerifying,
                      onPressed: _handleVerifyOtp,
                    ),
                    const SizedBox(height: 20),
                    Center(
                      child: _resendCountdown > 0
                          ? Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.timer_outlined,
                                  size: 16,
                                  color: AppColors.textSecondary,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  'Resend code in 00:${_resendCountdown.toString().padLeft(2, '0')}',
                                  style: const TextStyle(
                                    color: AppColors.textSecondary,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            )
                          : TextButton.icon(
                              onPressed: _handleResendOtp,
                              icon: const Icon(Icons.refresh_rounded, size: 18),
                              label: const Text(
                                'Resend OTP',
                                style: TextStyle(fontWeight: FontWeight.w700),
                              ),
                            ),
                    ),
                    const SizedBox(height: 8),
                    Center(
                      child: TextButton(
                        onPressed: _cancelOtp,
                        child: const Text('Change mobile number'),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
