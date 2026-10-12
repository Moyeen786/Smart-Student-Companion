import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:smart_student_companion/app/app_providers.dart';
import 'package:smart_student_companion/core/theme/app_colors.dart';
import 'package:smart_student_companion/core/widgets/app_button.dart';
import 'package:smart_student_companion/core/widgets/app_card.dart';
import 'package:smart_student_companion/core/widgets/section_header.dart';
import 'package:smart_student_companion/features/parent/data/parent_models.dart';
import 'package:smart_student_companion/features/parent/data/parent_providers.dart';
import 'package:smart_student_companion/features/parent/presentation/parent_dashboard.dart';
import 'package:smart_student_companion/models/user_model.dart';

class ParentProfileScreen extends ConsumerWidget {
  const ParentProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);
    final user = authState.valueOrNull?.user;

    final summary =
        ref.watch(parentActiveChildSummaryProvider) ??
        ChildAcademicSummary.generateForStudent(
          user ??
              const UserModel(
                uid: 'demo',
                name: 'Student Account',
                email: 'student@campus.edu',
                role: UserRole.student,
                department: 'Computer Science and Engineering',
                semester: 5,
                rollNumber: 'CS2023001',
              ),
        );

    final student = summary.student;
    final parentPhone = user?.parentPhone.isNotEmpty == true
        ? user!.parentPhone
        : '+91 98765 43210';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Parent Profile'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/parent'),
        ),
        actions: [
          IconButton(
            tooltip: 'Sign out',
            onPressed: () async {
              await ref.read(authStateProvider.notifier).logout();
              if (context.mounted) context.go('/login');
            },
            icon: const Icon(Icons.logout_outlined),
          ),
        ],
      ),
      bottomNavigationBar: const ParentBottomNav(currentIndex: 3),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
          children: [
            // Parent Header Card
            AppCard(
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 32,
                    backgroundColor: AppColors.primary.withOpacity(0.12),
                    child: const Icon(
                      Icons.family_restroom_rounded,
                      size: 34,
                      color: AppColors.primary,
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
                              user?.name ?? 'Registered Parent',
                              style: const TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Mobile: $parentPhone',
                          style: const TextStyle(
                            fontSize: 13,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Container(
                          margin: const EdgeInsets.only(top: 4),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.success.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Text(
                            'Active Parent Session',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: AppColors.success,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Linked Student Details
            const SectionHeader(title: "Linked Student Information"),
            const SizedBox(height: 10),
            AppCard(
              child: Column(
                children: [
                  _InfoRow(
                    label: "Student's Full Name",
                    value: student.name,
                    icon: Icons.person_outline,
                  ),
                  const Divider(height: 1),
                  _InfoRow(
                    label: 'Student ID / Roll Number',
                    value: student.rollNumber.isNotEmpty
                        ? student.rollNumber
                        : 'CS2023001',
                    icon: Icons.badge_outlined,
                  ),
                  const Divider(height: 1),
                  _InfoRow(
                    label: 'Department',
                    value: student.department.isNotEmpty
                        ? student.department
                        : 'Computer Science and Engineering',
                    icon: Icons.account_balance_outlined,
                  ),
                  const Divider(height: 1),
                  _InfoRow(
                    label: 'Current Semester',
                    value: 'Semester ${student.semester > 0 ? student.semester : 5}',
                    icon: Icons.calendar_month_outlined,
                  ),
                  const Divider(height: 1),
                  _InfoRow(
                    label: 'University Email',
                    value: student.email,
                    icon: Icons.email_outlined,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Notification & Alerts Preferences
            const SectionHeader(title: 'Alert Preferences'),
            const SizedBox(height: 10),
            AppCard(
              child: Column(
                children: [
                  SwitchListTile(
                    value: true,
                    onChanged: (val) {},
                    contentPadding: EdgeInsets.zero,
                    title: const Text(
                      'SMS Attendance Alerts',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    subtitle: const Text(
                      'Receive instant SMS if attendance dips below 75%',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                  const Divider(height: 1),
                  SwitchListTile(
                    value: true,
                    onChanged: (val) {},
                    contentPadding: EdgeInsets.zero,
                    title: const Text(
                      'Exam & Internal Test Reminders',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    subtitle: const Text(
                      'Notifications 3 days before exam dates',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                  const Divider(height: 1),
                  SwitchListTile(
                    value: false,
                    onChanged: (val) {},
                    contentPadding: EdgeInsets.zero,
                    title: const Text(
                      'Weekly Performance Digest',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    subtitle: const Text(
                      'Summary email sent every Saturday',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Institutional Helpline
            const SectionHeader(title: 'Campus & Academic Help Desk'),
            const SizedBox(height: 10),
            AppCard(
              child: Column(
                children: const [
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: Icon(
                      Icons.headset_mic_outlined,
                      color: AppColors.primary,
                    ),
                    title: Text(
                      'Academic Office Helpdesk',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    subtitle: Text(
                      '+91 11 2345 6789 • helpdesk@campus.edu',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                  Divider(height: 1),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: Icon(
                      Icons.contact_phone_outlined,
                      color: AppColors.primary,
                    ),
                    title: Text(
                      'Department HOD Office',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    subtitle: Text(
                      'hod.cse@campus.edu • Room AB-101',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // Sign Out Button
            AppButton(
              label: 'LOG OUT OF PARENT ACCESS',
              onPressed: () async {
                await ref.read(authStateProvider.notifier).logout();
                if (context.mounted) context.go('/login');
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.label,
    required this.value,
    required this.icon,
  });

  final String label;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          Icon(icon, size: 20, color: AppColors.primary),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
