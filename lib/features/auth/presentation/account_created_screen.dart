import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:smart_student_companion/core/theme/app_colors.dart';
import 'package:smart_student_companion/core/widgets/app_button.dart';
import 'package:smart_student_companion/models/user_model.dart';

class AccountCreatedScreen extends StatelessWidget {
  const AccountCreatedScreen({required this.role, super.key});

  final UserRole role;

  String get _roleLabel => switch (role) {
    UserRole.student => 'student',
    UserRole.faculty => 'faculty',
    UserRole.parent => 'parent',
    UserRole.admin => 'administrator',
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 460),
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: Column(
                    children: [
                      const CircleAvatar(
                        radius: 34,
                        backgroundColor: AppColors.surface,
                        child: Icon(
                          Icons.check_rounded,
                          size: 40,
                          color: AppColors.primary,
                        ),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        '${_roleLabel.toUpperCase()} ACCOUNT CREATED',
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Your $_roleLabel account has been created successfully. Sign in to continue to your academic portal.',
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 28),
                      AppButton(
                        label: 'GO TO LOGIN',
                        onPressed: () => context.go('/login'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
