import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:smart_student_companion/core/theme/app_colors.dart';
import 'package:smart_student_companion/core/widgets/app_card.dart';
import 'package:smart_student_companion/core/widgets/section_header.dart';
import 'package:smart_student_companion/features/parent/data/parent_providers.dart';
import 'package:smart_student_companion/features/parent/presentation/parent_dashboard.dart';

class ChildAttendance extends ConsumerWidget {
  const ChildAttendance({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final summary = ref.watch(parentActiveChildSummaryProvider);

    if (summary == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Child Attendance'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => context.go('/parent'),
          ),
        ),
        bottomNavigationBar: const ParentBottomNav(currentIndex: 1),
        body: const SafeArea(child: ParentAcademicDataUnavailable()),
      );
    }

    final isSafe = summary.overallAttendance >= 75;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Child Attendance'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/parent'),
        ),
      ),
      bottomNavigationBar: const ParentBottomNav(currentIndex: 1),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
          children: [
            // Top Summary Card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: isSafe
                      ? [const Color(0xFF1E4E9A), const Color(0xFF2E6FD0)]
                      : [const Color(0xFFB91C1C), const Color(0xFFDC2626)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: (isSafe ? AppColors.primary : AppColors.danger)
                        .withValues(alpha: 0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Overall Attendance',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 13,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${summary.overallAttendance.toStringAsFixed(1)}%',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 32,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              isSafe
                                  ? Icons.check_circle_rounded
                                  : Icons.warning_rounded,
                              color: Colors.white,
                              size: 16,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              isSafe ? 'Good Standing' : 'Below 75%',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Divider(color: Colors.white24, height: 1),
                  const SizedBox(height: 14),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _StatColumn(
                        label: 'Attended',
                        value: '${summary.attendedClasses}',
                      ),
                      Container(width: 1, height: 28, color: Colors.white24),
                      _StatColumn(
                        label: 'Missed',
                        value:
                            '${summary.totalClasses - summary.attendedClasses}',
                      ),
                      Container(width: 1, height: 28, color: Colors.white24),
                      _StatColumn(
                        label: 'Total Held',
                        value: '${summary.totalClasses}',
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // University Attendance Policy Note
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFFEFF6FF),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFBFDBFE)),
              ),
              child: const Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.policy_outlined,
                    size: 20,
                    color: Color(0xFF1D4ED8),
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'University Regulation: Minimum 75% attendance is required in each subject to be eligible for end-semester examinations.',
                      style: TextStyle(
                        fontSize: 12,
                        color: Color(0xFF1E40AF),
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 26),

            // Subject-by-Subject Detailed Breakdown
            const SectionHeader(title: 'Subject Breakdown'),
            const SizedBox(height: 12),
            ...summary.subjectAttendances.map((sub) {
              final isSubjectLow = sub.percentage < 75;
              final color = isSubjectLow
                  ? AppColors.danger
                  : sub.percentage < 85
                  ? AppColors.warning
                  : AppColors.success;

              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: AppCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  sub.subjectName,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 15,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  '${sub.subjectCode} • ${sub.teacherName}',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: color.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              '${sub.percentage.toStringAsFixed(1)}%',
                              style: TextStyle(
                                fontWeight: FontWeight.w800,
                                fontSize: 14,
                                color: color,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(6),
                        child: LinearProgressIndicator(
                          value: sub.percentage / 100,
                          minHeight: 7,
                          backgroundColor: AppColors.border,
                          valueColor: AlwaysStoppedAnimation<Color>(color),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Attended: ${sub.attended} / ${sub.total} classes',
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.textSecondary,
                            ),
                          ),
                          Text(
                            isSubjectLow
                                ? 'Needs 3 classes to reach 75%'
                                : 'Can miss 4 classes safely',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: isSubjectLow
                                  ? AppColors.danger
                                  : AppColors.success,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            }),
            const SizedBox(height: 20),

            // Recent Daily Attendance Log
            const SectionHeader(title: 'Recent Daily Logs'),
            const SizedBox(height: 10),
            AppCard(
              child: Column(
                children: const [
                  _DailyLogTile(
                    date: 'Yesterday (Sep 23)',
                    subject: 'Computer Networks',
                    time: '09:00 AM',
                    status: 'Present',
                    isPresent: true,
                  ),
                  Divider(height: 1),
                  _DailyLogTile(
                    date: 'Yesterday (Sep 23)',
                    subject: 'Data Structures Lab',
                    time: '02:00 PM',
                    status: 'Absent',
                    isPresent: false,
                  ),
                  Divider(height: 1),
                  _DailyLogTile(
                    date: 'Sep 22, 2026',
                    subject: 'Operating Systems',
                    time: '11:00 AM',
                    status: 'Present',
                    isPresent: true,
                  ),
                  Divider(height: 1),
                  _DailyLogTile(
                    date: 'Sep 22, 2026',
                    subject: 'Database Systems',
                    time: '03:00 PM',
                    status: 'Present',
                    isPresent: true,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatColumn extends StatelessWidget {
  const _StatColumn({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: const TextStyle(color: Colors.white70, fontSize: 11),
        ),
      ],
    );
  }
}

class _DailyLogTile extends StatelessWidget {
  const _DailyLogTile({
    required this.date,
    required this.subject,
    required this.time,
    required this.status,
    required this.isPresent,
  });

  final String date;
  final String subject;
  final String time;
  final String status;
  final bool isPresent;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: CircleAvatar(
        radius: 16,
        backgroundColor: (isPresent ? AppColors.success : AppColors.danger)
            .withValues(alpha: 0.12),
        child: Icon(
          isPresent ? Icons.check_rounded : Icons.close_rounded,
          size: 16,
          color: isPresent ? AppColors.success : AppColors.danger,
        ),
      ),
      title: Text(
        subject,
        style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
      ),
      subtitle: Text(
        '$date • $time',
        style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
      ),
      trailing: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(
          color: (isPresent ? AppColors.success : AppColors.danger).withValues(
            alpha: 0.1,
          ),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Text(
          status,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: isPresent ? AppColors.success : AppColors.danger,
          ),
        ),
      ),
    );
  }
}
