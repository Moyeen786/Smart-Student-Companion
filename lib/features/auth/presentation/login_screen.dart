import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:smart_student_companion/app/app_providers.dart';
import 'package:smart_student_companion/core/theme/app_colors.dart';
import 'package:smart_student_companion/core/widgets/app_button.dart';
import 'package:smart_student_companion/core/widgets/app_text_field.dart';
import 'package:smart_student_companion/models/user_model.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});
  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    await ref
        .read(authStateProvider.notifier)
        .login(_emailController.text.trim(), _passwordController.text);
    if (!mounted) return;
    final user = ref.read(authStateProvider).valueOrNull?.user;
    if (user != null) context.go(_dashboardFor(user.role));
  }

  String _dashboardFor(UserRole role) => switch (role) {
    UserRole.student => '/student',
    UserRole.faculty => '/faculty',
    UserRole.parent => '/parent',
    UserRole.admin => '/admin',
  };

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authStateProvider);
    final form = _loginForm(
      context,
      authState.isLoading,
      authState.hasError
          ? authState.error.toString().replaceFirst('Exception: ', '')
          : null,
    );
    return Scaffold(
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final wide = constraints.maxWidth >= 820;
            return SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: constraints.maxHeight - 48,
                ),
                child: wide
                    ? Row(
                        children: [
                          Expanded(child: _brandPanel(context)),
                          const SizedBox(width: 64),
                          SizedBox(width: 420, child: form),
                        ],
                      )
                    : Column(
                        children: [
                          _brandPanel(context, compact: true),
                          const SizedBox(height: 28),
                          form,
                        ],
                      ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _brandPanel(BuildContext context, {bool compact = false}) => Padding(
    padding: EdgeInsets.symmetric(vertical: compact ? 8 : 48),
    child: Column(
      crossAxisAlignment: compact
          ? CrossAxisAlignment.center
          : CrossAxisAlignment.start,
      children: [
        Icon(
          Icons.school_outlined,
          size: compact ? 48 : 64,
          color: AppColors.primary,
        ),
        const SizedBox(height: 18),
        Text(
          'SMART STUDENT\nCOMPANION',
          textAlign: compact ? TextAlign.center : TextAlign.left,
          style: Theme.of(context).textTheme.displaySmall?.copyWith(
            fontWeight: FontWeight.w800,
            color: AppColors.primary,
            height: 1.05,
          ),
        ),
        const SizedBox(height: 14),
        Text(
          'Your Campus. Your Academics.\nOne Smart Companion.',
          textAlign: compact ? TextAlign.center : TextAlign.left,
          style: Theme.of(context).textTheme.titleLarge,
        ),
        if (!compact) ...[
          const SizedBox(height: 30),
          const Text('One platform for your entire academic journey.'),
          const SizedBox(height: 18),
          const _Feature(text: 'Academic Management'),
          const _Feature(text: 'Attendance & Performance'),
          const _Feature(text: 'Campus Services'),
        ],
      ],
    ),
  );

  Widget _loginForm(BuildContext context, bool isLoading, String? error) =>
      Card(
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Welcome Back',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 8),
                const Text('Sign in to continue to your academic portal.'),
                const SizedBox(height: 26),
                AppTextField(
                  label: 'University Email',
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  prefixIcon: Icons.email_outlined,
                  onSubmitted: (_) => _submit(),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter your university email.';
                    }
                    return RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$')
                            .hasMatch(value.trim())
                        ? null
                        : 'Enter a valid email address.';
                  },
                ),
                const SizedBox(height: 16),
                AppTextField(
                  label: 'Password',
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  prefixIcon: Icons.lock_outline,
                  onSubmitted: (_) => _submit(),
                  suffix: IconButton(
                    onPressed: () =>
                        setState(() => _obscurePassword = !_obscurePassword),
                    icon: Icon(
                      _obscurePassword
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined,
                    ),
                  ),
                  validator: (value) => value == null || value.isEmpty
                      ? 'Password is required.'
                      : null,
                ),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () => context.go('/forgot-password'),
                    child: const Text('Forgot Password?'),
                  ),
                ),
                if (error != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Text(
                      error,
                      style: const TextStyle(color: AppColors.danger),
                    ),
                  ),
                AppButton(
                  label: 'LOGIN',
                  onPressed: _submit,
                  isLoading: isLoading,
                ),
                const SizedBox(height: 20),
                const Row(
                  children: [
                    Expanded(child: Divider()),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 12),
                      child: Text('OR'),
                    ),
                    Expanded(child: Divider()),
                  ],
                ),
                const SizedBox(height: 16),
                const Center(child: Text('New Member?')),
                Center(
                  child: TextButton(
                    onPressed: () => context.go('/register/select-role'),
                    child: const Text('REGISTER NOW'),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
}

class _Feature extends StatelessWidget {
  const _Feature({required this.text});
  final String text;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 10),
    child: Row(
      children: [
        const Icon(Icons.check_circle_outline, color: AppColors.accent),
        const SizedBox(width: 10),
        Text(text),
      ],
    ),
  );
}
