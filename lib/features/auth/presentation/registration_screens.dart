import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:smart_student_companion/app/app_providers.dart';
import 'package:smart_student_companion/core/theme/app_colors.dart';
import 'package:smart_student_companion/core/widgets/app_button.dart';
import 'package:smart_student_companion/core/widgets/app_text_field.dart';
import 'package:smart_student_companion/features/parent/data/parent_registration_service.dart';
import 'package:smart_student_companion/features/parent/data/parent_demo_mode.dart';
import 'package:smart_student_companion/models/user_model.dart';

class RoleSelectionScreen extends StatelessWidget {
  const RoleSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final roles = [
      (
        UserRole.student,
        Icons.school_outlined,
        'Student',
        'Access academics, attendance, timetable and campus services.',
        '/register/student',
      ),
      (
        UserRole.faculty,
        Icons.person_outline,
        'Faculty',
        'Manage classes, attendance, assignments and academic activities.',
        '/register/faculty',
      ),
      (
        UserRole.parent,
        Icons.family_restroom_outlined,
        'Parent',
        'Monitor your child\'s academics, attendance and progress.',
        '/register/parent',
      ),
    ];
    return _PortalPage(
      title: 'Create Your Account',
      subtitle: 'Select the role that best describes your account.',
      child: Column(
        children: roles
            .map(
              (role) => Padding(
                padding: const EdgeInsets.only(bottom: 14),
                child: _RoleCard(
                  icon: role.$2,
                  title: role.$3,
                  description: role.$4,
                  onTap: () => context.go(role.$5),
                ),
              ),
            )
            .toList(),
      ),
    );
  }
}

class RegistrationScreen extends ConsumerStatefulWidget {
  const RegistrationScreen({required this.role, super.key});
  final UserRole role;

  @override
  ConsumerState<RegistrationScreen> createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends ConsumerState<RegistrationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _id = TextEditingController();
  final _department = TextEditingController();
  final _semester = TextEditingController();
  final _designation = TextEditingController();
  final _password = TextEditingController();
  final _confirmPassword = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    for (final controller in [
      _name,
      _email,
      _id,
      _department,
      _semester,
      _designation,
      _password,
      _confirmPassword,
    ]) {
      controller.dispose();
    }
    super.dispose();
  }

  String get _roleLabel => widget.role == UserRole.admin
      ? 'Administrator'
      : widget.role.name[0].toUpperCase() + widget.role.name.substring(1);

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (widget.role == UserRole.admin || widget.role == UserRole.parent) {
      return;
    }
    await ref
        .read(authStateProvider.notifier)
        .register(
          role: widget.role,
          name: _name.text.trim(),
          email: _email.text.trim(),
          password: _password.text,
          profile: {
            'department': _department.text.trim(),
            'semester': _semester.text.trim(),
            'designation': _designation.text.trim(),
            'rollNumber': _id.text.trim(),
          },
        );
    if (!mounted) return;
    final state = ref.read(authStateProvider);
    if (!state.hasError) {
      context.go('/account-created', extra: widget.role);
    }
  }

  String? _required(String? value, String label) =>
      value == null || value.trim().isEmpty ? '$label is required.' : null;

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(authStateProvider);
    if (widget.role == UserRole.admin || widget.role == UserRole.parent) {
      return _PortalPage(
        title: '${_roleLabel} accounts are provisioned',
        subtitle: widget.role == UserRole.admin
            ? 'Administrator accounts must be created by an authorized server-side provisioning process.'
            : 'Parent accounts must be linked to a student by the authorized provisioning process before phone verification.',
        child: AppButton(
          label: 'RETURN TO LOGIN',
          onPressed: () => context.go('/login'),
        ),
      );
    }
    return _PortalPage(
      title: 'Create $_roleLabel Account',
      subtitle: 'Enter your institutional details to get started.',
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            AppTextField(
              label: 'Full Name',
              controller: _name,
              prefixIcon: Icons.person_outline,
              validator: (v) => _required(v, 'Full name'),
            ),
            const SizedBox(height: 14),
            AppTextField(
              label: widget.role == UserRole.student
                  ? 'University Email'
                  : 'Official Email',
              controller: _email,
              keyboardType: TextInputType.emailAddress,
              prefixIcon: Icons.email_outlined,
              validator: (v) {
                if (_required(v, 'Email') != null) return _required(v, 'Email');
                return RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(v!.trim())
                    ? null
                    : 'Enter a valid email address.';
              },
            ),
            const SizedBox(height: 14),
            AppTextField(
              label: widget.role == UserRole.student
                  ? 'Roll Number'
                  : 'Faculty ID',
              controller: _id,
              prefixIcon: Icons.badge_outlined,
              validator: (v) => _required(
                v,
                widget.role == UserRole.student ? 'Roll number' : 'ID',
              ),
            ),
            const SizedBox(height: 14),
            AppTextField(
              label: 'Department',
              controller: _department,
              prefixIcon: Icons.account_balance_outlined,
              validator: (v) => _required(v, 'Department'),
            ),
            if (widget.role == UserRole.student) ...[
              const SizedBox(height: 14),
              AppTextField(
                label: 'Semester',
                controller: _semester,
                keyboardType: TextInputType.number,
                prefixIcon: Icons.calendar_month_outlined,
                validator: (v) => _required(v, 'Semester'),
              ),
            ],
            if (widget.role == UserRole.faculty) ...[
              const SizedBox(height: 14),
              AppTextField(
                label: 'Designation',
                controller: _designation,
                prefixIcon: Icons.work_outline,
                validator: (v) => _required(v, 'Designation'),
              ),
            ],
            const SizedBox(height: 14),
            AppTextField(
              label: 'Password',
              controller: _password,
              obscureText: _obscurePassword,
              prefixIcon: Icons.lock_outline,
              suffix: IconButton(
                onPressed: () =>
                    setState(() => _obscurePassword = !_obscurePassword),
                icon: Icon(
                  _obscurePassword
                      ? Icons.visibility_outlined
                      : Icons.visibility_off_outlined,
                ),
              ),
              validator: (v) => v == null || v.length < 8
                  ? 'Use at least 8 characters.'
                  : null,
            ),
            const SizedBox(height: 14),
            AppTextField(
              label: 'Confirm Password',
              controller: _confirmPassword,
              obscureText: true,
              prefixIcon: Icons.lock_reset_outlined,
              validator: (v) =>
                  v != _password.text ? 'Passwords do not match.' : null,
            ),
            if (state.hasError)
              Padding(
                padding: const EdgeInsets.only(top: 12),
                child: Text(
                  state.error.toString().replaceFirst('Exception: ', ''),
                  style: const TextStyle(color: AppColors.danger),
                ),
              ),
            const SizedBox(height: 20),
            AppButton(
              label: 'CREATE $_roleLabel ACCOUNT',
              onPressed: _submit,
              isLoading: state.isLoading,
            ),
            TextButton(
              onPressed: () => context.go('/login'),
              child: const Text('Already have an account? Sign in'),
            ),
          ],
        ),
      ),
    );
  }
}

class ForgotPasswordScreen extends ConsumerStatefulWidget {
  const ForgotPasswordScreen({super.key});
  @override
  ConsumerState<ForgotPasswordScreen> createState() =>
      _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends ConsumerState<ForgotPasswordScreen> {
  final _email = TextEditingController();
  bool _sent = false;
  @override
  void dispose() {
    _email.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    if (_email.text.trim().isEmpty) return;
    await ref
        .read(authStateProvider.notifier)
        .passwordReset(_email.text.trim());
    if (mounted) setState(() => _sent = true);
  }

  @override
  Widget build(BuildContext context) => _PortalPage(
    title: 'Reset Password',
    subtitle: 'Enter your registered email address.',
    child: Column(
      children: [
        AppTextField(
          label: 'Email',
          controller: _email,
          keyboardType: TextInputType.emailAddress,
          prefixIcon: Icons.email_outlined,
        ),
        const SizedBox(height: 20),
        if (_sent)
          const Padding(
            padding: EdgeInsets.only(bottom: 16),
            child: Text(
              'Password reset instructions have been sent to your email.',
            ),
          ),
        AppButton(label: 'SEND RESET LINK', onPressed: _send),
        TextButton(
          onPressed: () => context.go('/login'),
          child: const Text('Return to login'),
        ),
      ],
    ),
  );
}

class _PortalPage extends StatelessWidget {
  const _PortalPage({
    required this.title,
    required this.subtitle,
    required this.child,
  });
  final String title;
  final String subtitle;
  final Widget child;
  @override
  Widget build(BuildContext context) => Scaffold(
    body: SafeArea(
      child: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 560),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'SMART STUDENT COMPANION',
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: AppColors.primary,
                    letterSpacing: 1.2,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 28),
                Text(title, style: Theme.of(context).textTheme.headlineMedium),
                const SizedBox(height: 8),
                Text(subtitle),
                const SizedBox(height: 28),
                child,
              ],
            ),
          ),
        ),
      ),
    ),
  );
}

class _RoleCard extends StatelessWidget {
  const _RoleCard({
    required this.icon,
    required this.title,
    required this.description,
    required this.onTap,
  });
  final IconData icon;
  final String title;
  final String description;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) => Card(
    child: InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Row(
          children: [
            Icon(icon, size: 32, color: AppColors.primary),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 4),
                  Text(description),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios, size: 16),
          ],
        ),
      ),
    ),
  );
}

class ParentRegistrationScreen extends ConsumerStatefulWidget {
  const ParentRegistrationScreen({super.key});

  @override
  ConsumerState<ParentRegistrationScreen> createState() =>
      _ParentRegistrationScreenState();
}

class _ParentRegistrationScreenState
    extends ConsumerState<ParentRegistrationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _studentName = TextEditingController();
  final _rollNumber = TextEditingController();
  final _parentPhone = TextEditingController();
  final _otp = TextEditingController();
  final _service = ParentRegistrationService();
  Timer? _resendTimer;
  bool _consent = false;
  bool _otpSent = false;
  bool _loading = false;
  bool _approved = false;
  String? _error;
  String? _studentDisplay;
  String? _verificationId;
  int? _resendToken;
  int _resendSeconds = 0;
  int _generation = 0;

  @override
  void dispose() {
    _generation++;
    _resendTimer?.cancel();
    _studentName.dispose();
    _rollNumber.dispose();
    _parentPhone.dispose();
    _otp.dispose();
    unawaited(_service.cancel());
    super.dispose();
  }

  void _startResendTimer() {
    _resendTimer?.cancel();
    setState(() => _resendSeconds = 45);
    _resendTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return timer.cancel();
      if (_resendSeconds <= 1) {
        timer.cancel();
        setState(() => _resendSeconds = 0);
      } else {
        setState(() => _resendSeconds--);
      }
    });
  }

  Future<void> _beginRegistration({int? resendToken}) async {
    if (_loading) return;
    if (!_otpSent && !_formKey.currentState!.validate()) return;
    if (!_otpSent && !_consent) {
      setState(
        () => _error = 'Confirm that the student approves this Parent link.',
      );
      return;
    }
    final generation = ++_generation;
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final demoMode = ref.read(parentDemoModeProvider);
      if (!_otpSent && !demoMode) {
        final match = await _service.validateStudent(
          studentName: _studentName.text,
          rollNumber: _rollNumber.text,
        );
        if (match['uid'] != FirebaseAuth.instance.currentUser?.uid) {
          throw StateError(
            'Sign in to the matching Student account to approve this Parent link.',
          );
        }
        _studentDisplay = '${match['name']} • ${match['rollNumber']}';
      }
      if (demoMode) {
        final signedInStudent = ref.read(authStateProvider).valueOrNull?.user;
        if (signedInStudent == null ||
            signedInStudent.role != UserRole.student ||
            signedInStudent.name.trim().toLowerCase() !=
                _studentName.text.trim().toLowerCase() ||
            signedInStudent.rollNumber.trim().toLowerCase() !=
                _rollNumber.text.trim().toLowerCase()) {
          throw StateError('Enter the signed-in Student name and roll number.');
        }
        _studentDisplay =
            '${signedInStudent.name} • ${signedInStudent.rollNumber} (sample)';
        if (!mounted || generation != _generation) return;
        setState(() {
          _verificationId = 'DEMO_ONLY';
          _otpSent = true;
          _loading = false;
        });
        _startResendTimer();
        return;
      }
      await _service.sendCode(
        phoneNumber: _parentPhone.text,
        resendToken: resendToken,
        onCodeSent: (id, token) {
          if (!mounted || generation != _generation) return;
          setState(() {
            _verificationId = id;
            _resendToken = token;
            _otpSent = true;
            _loading = false;
            _error = null;
          });
          _startResendTimer();
        },
        onAutoVerified: (credential) => unawaited(
          _finishRegistration(
            generation: generation,
            automaticCredential: credential,
          ),
        ),
        onError: (error) {
          if (!mounted || generation != _generation) return;
          setState(() {
            _loading = false;
            _error = _phoneError(error);
          });
        },
      );
    } catch (error) {
      if (mounted && generation == _generation) {
        setState(() {
          _loading = false;
          _error = _message(error);
        });
      }
    }
  }

  Future<void> _finishRegistration({
    int? generation,
    PhoneAuthCredential? automaticCredential,
  }) async {
    if (_loading && automaticCredential == null) return;
    final activeGeneration = generation ?? _generation;
    if (automaticCredential == null &&
        (_verificationId == null || _otp.text.trim().length != 6)) {
      setState(() => _error = 'Enter the complete six-digit SMS code.');
      return;
    }
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      if (ref.read(parentDemoModeProvider)) {
        if (_otp.text.trim() != parentDemoOtp) {
          throw StateError(
            'Use sample demo code $parentDemoOtp. No SMS was sent.',
          );
        }
        if (!mounted || activeGeneration != _generation) return;
        setState(() {
          _loading = false;
          _approved = true;
        });
        if (mounted) context.go('/parent-demo');
        return;
      }
      await _service.verifyAndRegister(
        studentName: _studentName.text,
        rollNumber: _rollNumber.text,
        smsCode: _otp.text,
        automaticCredential: automaticCredential,
      );
      if (!mounted || activeGeneration != _generation) return;
      setState(() {
        _loading = false;
        _approved = true;
      });
      await _service.cancel();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Parent phone verified and link approved. The Parent can now sign in.',
            ),
          ),
        );
        context.go('/student');
      }
    } on FirebaseAuthException catch (error) {
      if (mounted && activeGeneration == _generation) {
        setState(() {
          _loading = false;
          _error = _phoneError(error);
        });
      }
    } on FirebaseFunctionsException catch (error) {
      if (mounted && activeGeneration == _generation) {
        setState(() {
          _loading = false;
          _error =
              error.message ?? 'Parent linking failed. You can retry safely.';
        });
      }
    } catch (error) {
      if (mounted && activeGeneration == _generation) {
        setState(() {
          _loading = false;
          _error = _message(error);
        });
      }
    }
  }

  String _message(Object error) => error.toString().replaceFirst(
    RegExp(r'^(Bad state|FormatException): '),
    '',
  );

  String _phoneError(FirebaseAuthException error) => switch (error.code) {
    'invalid-verification-code' =>
      'That SMS code is incorrect. Check the code and try again.',
    'session-expired' ||
    'code-expired' => 'That SMS code expired. Request a new code.',
    'network-request-failed' =>
      'Network error. Check your connection and retry.',
    'too-many-requests' || 'quota-exceeded' =>
      'Too many attempts. Wait before requesting another code.',
    'invalid-phone-number' => 'Enter a valid international phone number.',
    _ => error.message ?? 'Phone verification failed. Please try again.',
  };

  @override
  Widget build(BuildContext context) {
    final demoMode = ref.watch(parentDemoModeProvider);
    final authState = ref.watch(authStateProvider);
    final student = authState.valueOrNull?.user;
    final isStudent =
        authState.valueOrNull?.isAuthenticated == true &&
        student?.role == UserRole.student;
    if (authState.isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    if (!isStudent) {
      return _PortalPage(
        title: 'Parent Registration',
        subtitle:
            'A Student must sign in and approve access before a Parent link can be created.',
        child: Column(
          children: [
            const Icon(
              Icons.verified_user_outlined,
              size: 42,
              color: AppColors.primary,
            ),
            const SizedBox(height: 12),
            const Text(
              'Sign in to the Student account for the student whose profile will be linked. The Parent will verify their own mobile number by SMS.',
            ),
            const SizedBox(height: 18),
            FilledButton.icon(
              onPressed: () => context.go('/login'),
              icon: const Icon(Icons.login),
              label: const Text('Student Sign In'),
            ),
            TextButton(
              onPressed: () => context.go('/parent-login'),
              child: const Text('Parent Sign In'),
            ),
          ],
        ),
      );
    }

    return _PortalPage(
      title: demoMode
          ? (_approved ? 'Demo Steps Complete' : 'Parent Registration Demo')
          : _approved
          ? 'Parent Link Approved'
          : 'Register Parent Access',
      subtitle: demoMode
          ? 'Try the Parent registration screens with sample steps and data. No phone verification or link is created.'
          : _otpSent
          ? 'Enter the OTP sent to the Parent mobile number to confirm their phone identity.'
          : 'Verify the student profile, then have the Parent verify their phone. Student sign-in and Parent SMS verification are both required.',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (demoMode) ...[
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.amber.shade100,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Text(
                parentDemoDisclaimer,
                style: TextStyle(fontWeight: FontWeight.w700),
              ),
            ),
            const SizedBox(height: 12),
          ],
          TextButton.icon(
            onPressed: () {
              if (_otpSent) {
                _generation++;
                _resendTimer?.cancel();
                unawaited(_service.cancel());
                setState(() {
                  _otpSent = false;
                  _loading = false;
                  _otp.clear();
                  _error = null;
                });
              } else {
                context.go('/student');
              }
            },
            icon: const Icon(Icons.arrow_back),
            label: Text(
              _otpSent ? 'Back to details' : 'Back to Student Dashboard',
            ),
          ),
          const SizedBox(height: 12),
          if (!_otpSent) ...[
            Form(
              key: _formKey,
              child: Column(
                children: [
                  AppTextField(
                    label: 'Student full name',
                    controller: _studentName,
                    prefixIcon: Icons.person_outline,
                    validator: _required,
                  ),
                  const SizedBox(height: 14),
                  AppTextField(
                    label: 'Student roll number',
                    controller: _rollNumber,
                    prefixIcon: Icons.badge_outlined,
                    validator: _required,
                  ),
                  const SizedBox(height: 14),
                  AppTextField(
                    label: 'Parent mobile number',
                    controller: _parentPhone,
                    hintText: '+91 98765 43210',
                    keyboardType: TextInputType.phone,
                    prefixIcon: Icons.phone_android_outlined,
                    validator: _required,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            CheckboxListTile(
              value: _consent,
              contentPadding: EdgeInsets.zero,
              controlAffinity: ListTileControlAffinity.leading,
              onChanged: _loading
                  ? null
                  : (value) => setState(() {
                      _consent = value ?? false;
                      _error = null;
                    }),
              title: const Text(
                'I approve linking a Parent account to my Student profile.',
              ),
            ),
          ] else ...[
            Text(
              'Student: ${_studentDisplay ?? '${student!.name} • ${student.rollNumber}'}',
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            Text('Parent phone: ${_parentPhone.text.trim()}'),
            const SizedBox(height: 16),
            AppTextField(
              label: demoMode ? 'Sample demo code' : 'Six-digit SMS code',
              controller: _otp,
              keyboardType: TextInputType.number,
              prefixIcon: Icons.password,
              onChanged: (_) {
                if (_error != null) setState(() => _error = null);
              },
            ),
            if (demoMode) ...[
              const SizedBox(height: 8),
              const Text(
                'Sample code: 123456. No SMS is sent and the phone is not verified.',
              ),
            ],
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: _resendSeconds == 0 && !_loading
                    ? () => _beginRegistration(resendToken: _resendToken)
                    : null,
                child: Text(
                  _resendSeconds > 0
                      ? 'Resend in ${_resendSeconds}s'
                      : 'Resend code',
                ),
              ),
            ),
          ],
          if (_error != null) ...[
            const SizedBox(height: 8),
            Text(_error!, style: const TextStyle(color: AppColors.danger)),
          ],
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: _loading
                  ? null
                  : _otpSent
                  ? () => _finishRegistration()
                  : () => _beginRegistration(),
              icon: _loading
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Icon(
                      _otpSent
                          ? Icons.verified_user_outlined
                          : Icons.sms_outlined,
                    ),
              label: Text(
                _loading
                    ? 'Please wait…'
                    : _otpSent
                    ? demoMode
                          ? 'Continue Demo'
                          : 'Verify OTP and Link Parent'
                    : demoMode
                    ? 'Simulate Student Check'
                    : 'Verify Student and Send OTP',
              ),
            ),
          ),
          Center(
            child: TextButton(
              onPressed: () {
                unawaited(_service.cancel());
                context.go('/login');
              },
              child: const Text('Cancel and return to sign in'),
            ),
          ),
        ],
      ),
    );
  }

  String? _required(String? value) =>
      value == null || value.trim().isEmpty ? 'This field is required.' : null;
}
