import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:smart_student_companion/app/app_providers.dart';
import 'package:smart_student_companion/core/theme/app_colors.dart';
import 'package:smart_student_companion/core/constants/app_constants.dart';
import 'package:smart_student_companion/core/widgets/app_button.dart';
import 'package:smart_student_companion/core/widgets/app_text_field.dart';
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
      ),
      (
        UserRole.faculty,
        Icons.person_outline,
        'Faculty',
        'Manage classes, attendance, assignments and academic activities.',
      ),
      (
        UserRole.admin,
        Icons.admin_panel_settings_outlined,
        'Administrator',
        'Manage users, announcements and institutional information.',
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
                  onTap: () => context.go('/register/${role.$1.name}'),
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
  final _inviteCode = TextEditingController();
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
      _inviteCode,
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
    if (widget.role == UserRole.admin &&
        _inviteCode.text.trim() != AppConstants.demoAdminAuthorizationCode) {
      return;
    }
    if (widget.role == UserRole.admin && _inviteCode.text.trim().isEmpty) {
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
            'invitationCode': _inviteCode.text.trim(),
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
    final isAdmin = widget.role == UserRole.admin;
    return _PortalPage(
      title: 'Create $_roleLabel Account',
      subtitle: isAdmin
          ? 'Administrator registration requires secure authorization.'
          : 'Enter your institutional details to get started.',
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
              label: isAdmin
                  ? 'Administrator ID'
                  : widget.role == UserRole.student
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
            if (isAdmin) ...[
              const SizedBox(height: 14),
              const Card(
                color: AppColors.surface,
                child: Padding(
                  padding: EdgeInsets.all(14),
                  child: Text(
                    'Demo mode: use authorization code 4057 to create an administrator account.',
                  ),
                ),
              ),
              const SizedBox(height: 14),
              AppTextField(
                label: 'Invitation / Authorization Code',
                controller: _inviteCode,
                prefixIcon: Icons.verified_user_outlined,
                validator: (v) {
                  if (_required(v, 'Authorization code') != null) {
                    return _required(v, 'Authorization code');
                  }
                  return v!.trim() == AppConstants.demoAdminAuthorizationCode
                      ? null
                      : 'Invalid demo authorization code.';
                },
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
