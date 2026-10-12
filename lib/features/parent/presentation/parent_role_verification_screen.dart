import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:smart_student_companion/app/app_providers.dart';
import 'package:smart_student_companion/core/theme/app_colors.dart';
import 'package:smart_student_companion/core/widgets/app_card.dart';
import 'package:smart_student_companion/features/parent/data/parent_providers.dart';
import 'package:smart_student_companion/models/user_model.dart';

class ParentRoleVerificationScreen extends ConsumerWidget {
  const ParentRoleVerificationScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final candidateStudent = ref.watch(parentCandidateStudentProvider) ??
        ref.watch(authStateProvider).valueOrNull?.user;

    // If candidate student is somehow null, redirect back to login
    if (candidateStudent == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        context.go('/login');
      });
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

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
                        onPressed: () => context.go('/login'),
                        icon: const Icon(Icons.arrow_back),
                        tooltip: 'Back to login',
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
                    'Who are you?',
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Confirm your identity to proceed with this account.',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Identified Student Profile Summary Card
                  AppCard(
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 26,
                          backgroundColor: AppColors.primary.withOpacity(0.1),
                          child: const Icon(
                            Icons.school_rounded,
                            color: AppColors.primary,
                            size: 28,
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
                                  fontSize: 16,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'ID: ${candidateStudent.rollNumber.isNotEmpty ? candidateStudent.rollNumber : candidateStudent.uid}',
                                style: const TextStyle(
                                  color: AppColors.textSecondary,
                                  fontSize: 13,
                                ),
                              ),
                              Text(
                                '${candidateStudent.department} • Sem ${candidateStudent.semester}',
                                style: const TextStyle(
                                  color: AppColors.textSecondary,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                        TextButton(
                          onPressed: () => context.go('/login'),
                          child: const Text('Change'),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  // Option 1: Student
                  _IdentityCard(
                    icon: Icons.school_outlined,
                    title: 'Student',
                    description: 'Continue to your student dashboard',
                    badge: 'Student Flow',
                    onTap: () {
                      // Student option: authenticate and navigate to existing Student Dashboard
                      final studentUser = candidateStudent.copyWith(
                        role: UserRole.student,
                      );
                      ref
                          .read(authStateProvider.notifier)
                          .setAuthenticatedUser(studentUser);
                      context.go('/student');
                    },
                  ),
                  const SizedBox(height: 16),
                  // Option 2: Parent
                  _IdentityCard(
                    icon: Icons.family_restroom_outlined,
                    title: 'Parent',
                    description: "Access your child's academic dashboard",
                    badge: 'Phone & OTP Verified',
                    isHighlight: true,
                    onTap: () {
                      context.go('/parent-phone-verify');
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _IdentityCard extends StatelessWidget {
  const _IdentityCard({
    required this.icon,
    required this.title,
    required this.description,
    required this.onTap,
    this.badge,
    this.isHighlight = false,
  });

  final IconData icon;
  final String title;
  final String description;
  final VoidCallback onTap;
  final String? badge;
  final bool isHighlight;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: isHighlight ? 2 : 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(
          color: isHighlight
              ? AppColors.primary.withOpacity(0.5)
              : AppColors.border,
          width: isHighlight ? 1.5 : 1,
        ),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isHighlight
                      ? AppColors.primary.withOpacity(0.1)
                      : AppColors.surface,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  size: 32,
                  color: isHighlight ? AppColors.primary : AppColors.textPrimary,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          title,
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(
                                fontWeight: FontWeight.w700,
                              ),
                        ),
                        if (badge != null) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: isHighlight
                                  ? AppColors.primary.withOpacity(0.12)
                                  : AppColors.border,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              badge!,
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                color: isHighlight
                                    ? AppColors.primary
                                    : AppColors.textSecondary,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: AppColors.muted,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
