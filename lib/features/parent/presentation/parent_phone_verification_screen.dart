import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:smart_student_companion/app/app_providers.dart';
import 'package:smart_student_companion/core/theme/app_colors.dart';
import 'package:smart_student_companion/core/widgets/app_button.dart';
import 'package:smart_student_companion/core/widgets/app_card.dart';
import 'package:smart_student_companion/core/widgets/app_text_field.dart';
import 'package:smart_student_companion/features/parent/data/parent_models.dart';
import 'package:smart_student_companion/features/parent/data/parent_providers.dart';
import 'package:smart_student_companion/models/user_model.dart';

class ParentPhoneVerificationScreen extends ConsumerStatefulWidget {
  const ParentPhoneVerificationScreen({super.key});

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
  final List<TextEditingController> _otpControllers =
      List.generate(6, (_) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(6, (_) => FocusNode());
  int _resendCountdown = 45;
  Timer? _timer;
  bool _isVerifying = false;
  String? _otpErrorMessage;

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

    final candidateStudent = ref.read(parentCandidateStudentProvider) ??
        ref.read(authStateProvider).valueOrNull?.user;

    if (candidateStudent == null) {
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
      // 1. Check Firebase/Firestore to determine whether entered mobile number is registered
      final isRegistered = await authService.verifyParentMobileAgainstFirestore(
        rollNumber: candidateStudent.rollNumber,
        inputPhone: inputPhone,
        studentUid: candidateStudent.uid,
        candidateParentPhone: candidateStudent.parentPhone,
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

      await authService.sendFirebasePhoneOtp(
        phoneNumber: inputPhone,
        onCodeSent: (verificationId, resendToken) {
          if (!mounted) return;
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
          if (!mounted) return;
          final fallbackOtp = authService.generateOtp();
          ref.read(parentGeneratedOtpProvider.notifier).state = fallbackOtp;
          ref.read(parentVerificationIdProvider.notifier).state = null;

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              backgroundColor: AppColors.primary,
              behavior: SnackBarBehavior.floating,
              content: Text(
                'SMS Service Notice: $error\nDemo verification code: $fallbackOtp',
              ),
              duration: const Duration(seconds: 8),
            ),
          );

          setState(() {
            _isLoading = false;
            _otpSent = true;
            _errorMessage = null;
            _isNotRegistered = false;
          });
          _startCountdown();
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
      setState(() => _otpSent = false);
      return;
    }

    for (final c in _otpControllers) {
      c.clear();
    }
    _focusNodes[0].requestFocus();
    _startCountdown();

    await authService.sendFirebasePhoneOtp(
      phoneNumber: verifiedPhone,
      forceResendingToken: resendToken,
      onCodeSent: (newVerificationId, newResendToken) {
        if (!mounted) return;
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
        if (!mounted) return;
        final dynamicOtp = authService.generateOtp();
        ref.read(parentGeneratedOtpProvider.notifier).state = dynamicOtp;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: AppColors.primary,
            behavior: SnackBarBehavior.floating,
            content: Text('Notice: $err\nVerification code: $dynamicOtp'),
            duration: const Duration(seconds: 6),
          ),
        );
      },
    );
  }

  Future<void> _handleVerifyOtp() async {
    final candidateStudent = ref.read(parentCandidateStudentProvider) ??
        ref.read(authStateProvider).valueOrNull?.user;
    if (candidateStudent == null) {
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
    final fallbackOtp = ref.read(parentGeneratedOtpProvider);
    final authService = ref.read(parentAuthServiceProvider);

    final isValid = await authService.verifyOtpCredential(
      otp: otp,
      verificationId: verificationId,
      fallbackOtp: fallbackOtp,
    );

    if (!isValid) {
      if (mounted) {
        setState(() {
          _isVerifying = false;
          _otpErrorMessage =
              'Invalid verification code. Please check your SMS and try again.';
        });
      }
      return;
    }

    // OTP Verified successfully!
    final verifiedPhone = ref.read(parentVerifiedPhoneProvider);
    final parentPhone = verifiedPhone.isNotEmpty
        ? verifiedPhone
        : candidateStudent.parentPhone;

    final parentUser = UserModel(
      uid: 'parent-${candidateStudent.uid}',
      name: candidateStudent.parentName.isNotEmpty
          ? candidateStudent.parentName
          : 'Parent of ${candidateStudent.name}',
      email: candidateStudent.email,
      role: UserRole.parent,
      department: candidateStudent.department,
      semester: candidateStudent.semester,
      createdAt: DateTime.now(),
      rollNumber: candidateStudent.rollNumber,
      parentPhone: parentPhone,
      childStudentId: candidateStudent.rollNumber,
      cgpa: candidateStudent.cgpa,
      overallAttendance: candidateStudent.overallAttendance,
    );

    // Build child academic summary for Parent Dashboard
    final summary = ChildAcademicSummary.generateForStudent(candidateStudent);
    ref.read(parentActiveChildSummaryProvider.notifier).state = summary;

    // Set authenticated parent user
    ref.read(authStateProvider.notifier).setAuthenticatedUser(parentUser);

    if (mounted) {
      context.go('/parent');
    }
  }

  @override
  Widget build(BuildContext context) {
    final candidateStudent = ref.watch(parentCandidateStudentProvider) ??
        ref.watch(authStateProvider).valueOrNull?.user;

    if (candidateStudent == null) {
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
                            setState(() => _otpSent = false);
                          } else {
                            context.go('/who-are-you');
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
                    'Parent Verification',
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _otpSent
                        ? "We've sent a verification code to your registered mobile number."
                        : 'Enter your registered mobile number',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Student Context Card
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
                                candidateStudent.name,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 15,
                                ),
                              ),
                              Text(
                                'Roll No: ${candidateStudent.rollNumber} • ${candidateStudent.department}',
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
                  const SizedBox(height: 24),

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
                              if (ParentAuthService.extractDigits(value).length <
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
                              onPressed: () => context.go('/who-are-you'),
                              icon: const Icon(Icons.arrow_back, size: 16),
                              label: const Text('Back to Identity Selection'),
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
                            onPressed: () => setState(() => _otpSent = false),
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
                        onPressed: () => setState(() => _otpSent = false),
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
