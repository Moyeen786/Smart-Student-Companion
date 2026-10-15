import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:smart_student_companion/app/app_providers.dart';
import 'package:smart_student_companion/core/theme/app_colors.dart';
import 'package:smart_student_companion/core/widgets/app_card.dart';
import 'package:smart_student_companion/core/widgets/section_header.dart';
import 'package:smart_student_companion/core/widgets/stat_card.dart';
import 'package:smart_student_companion/core/widgets/responsive_grid.dart';
import 'package:smart_student_companion/features/parent/data/parent_models.dart';
import 'package:smart_student_companion/features/parent/data/parent_providers.dart';
import 'package:smart_student_companion/features/parent/data/parent_demo_mode.dart';

class ParentDashboard extends ConsumerWidget {
  const ParentDashboard({super.key, this.demoMode = false});

  final bool demoMode;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDemo = demoMode && ref.watch(parentDemoModeProvider);
    // Parent data is rendered only when loaded from an authorized source.
    final summaryState = isDemo
        ? AsyncValue.data(ref.watch(parentDemoSummaryProvider))
        : ref.watch(parentChildProfileProvider);

    if (summaryState.isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: Text(isDemo ? 'Parent Demo Dashboard' : 'Parent Dashboard'),
        ),
        bottomNavigationBar: isDemo
            ? null
            : const ParentBottomNav(currentIndex: 0),
        body: const SafeArea(child: Center(child: CircularProgressIndicator())),
      );
    }

    if (summaryState.hasError) {
      final error = summaryState.error;
      return Scaffold(
        appBar: AppBar(
          title: Text(isDemo ? 'Parent Demo Dashboard' : 'Parent Dashboard'),
        ),
        bottomNavigationBar: isDemo
            ? null
            : const ParentBottomNav(currentIndex: 0),
        body: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.lock_outline, size: 40),
                  const SizedBox(height: 12),
                  Text(
                    error.toString().replaceFirst('Bad state: ', ''),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  FilledButton(
                    onPressed: () => ref.invalidate(parentChildProfileProvider),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    final summary = summaryState.requireValue;

    final student = summary.student;

    return Scaffold(
      appBar: AppBar(
        title: Text(isDemo ? 'Parent Demo Dashboard' : 'Parent Dashboard'),
        actions: isDemo
            ? []
            : [
                IconButton(
                  tooltip: 'Parent Profile',
                  onPressed: () => context.push('/parent/profile'),
                  icon: const Icon(Icons.account_circle_outlined),
                ),
                IconButton(
                  tooltip: 'Sign out',
                  onPressed: () async {
                    final loggedOut = await ref
                        .read(authStateProvider.notifier)
                        .logout();
                    if (loggedOut && context.mounted) context.go('/login');
                  },
                  icon: const Icon(Icons.logout_outlined),
                ),
              ],
      ),
      bottomNavigationBar: isDemo
          ? null
          : const ParentBottomNav(currentIndex: 0),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
          children: [
            if (isDemo) ...[
              Container(
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
              const SizedBox(height: 16),
            ],
            // Child Info Banner Header
            _ChildProfileCard(
              name: student.name,
              rollNumber: student.rollNumber.isNotEmpty
                  ? student.rollNumber
                  : 'Not provided',
              department: student.department.isNotEmpty
                  ? student.department
                  : 'Department not provided',
              semester: student.semester,
              onViewProfile: () => context.push('/parent/profile'),
            ),
            const SizedBox(height: 20),

            // Top Key Academic Statistics Grid
            ResponsiveGrid(
              tileHeight: isDemo ? 160 : 140,
              children: [
                StatCard(
                  label: 'Attendance',
                  value: '${summary.overallAttendance.toStringAsFixed(1)}%',
                  icon: Icons.check_circle_outline_rounded,
                  color: summary.overallAttendance >= 75
                      ? const Color(0xFFEAF6EE)
                      : const Color(0xFFFDECEC),
                ),
                StatCard(
                  label: 'Current CGPA',
                  value: summary.cgpa.toStringAsFixed(2),
                  icon: Icons.trending_up_rounded,
                  color: const Color(0xFFE9F1FF),
                ),
                StatCard(
                  label: 'Total Subjects',
                  value: summary.subjectAttendances.length.toString().padLeft(
                    2,
                    '0',
                  ),
                  icon: Icons.menu_book_rounded,
                  color: const Color(0xFFFFF3E7),
                ),
                StatCard(
                  label: 'Active Alerts',
                  value: summary.smartInsights.length.toString().padLeft(
                    2,
                    '0',
                  ),
                  icon: Icons.notification_important_rounded,
                  color: const Color(0xFFF1E8FF),
                ),
              ],
            ),
            const SizedBox(height: 26),

            // SMART INSIGHTS SECTION (Dynamic Warnings, Reminders, Trends)
            Row(
              children: [
                const Icon(
                  Icons.auto_awesome,
                  size: 20,
                  color: AppColors.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  'Smart Insights',
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Column(
              children: summary.smartInsights
                  .map((insight) => _SmartInsightCard(insight: insight))
                  .toList(),
            ),
            const SizedBox(height: 26),

            // ATTENDANCE OVERVIEW WITH STATUS & PROGRESS
            SectionHeader(
              title: 'Attendance Status',
              action: TextButton.icon(
                onPressed: () => context.go('/parent/attendance'),
                icon: const Icon(Icons.arrow_forward, size: 16),
                label: const Text('Full Report'),
              ),
            ),
            const SizedBox(height: 10),
            AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Cumulative Attendance',
                            style: TextStyle(
                              fontSize: 13,
                              color: AppColors.textSecondary,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${summary.attendedClasses} / ${summary.totalClasses} Classes',
                            style: const TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 15,
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
                          color: summary.overallAttendance >= 75
                              ? AppColors.success.withOpacity(0.12)
                              : AppColors.danger.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              summary.overallAttendance >= 75
                                  ? Icons.check_circle_rounded
                                  : Icons.warning_rounded,
                              size: 14,
                              color: summary.overallAttendance >= 75
                                  ? AppColors.success
                                  : AppColors.danger,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              summary.attendanceStatus,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: summary.overallAttendance >= 75
                                    ? AppColors.success
                                    : AppColors.danger,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  const Divider(height: 1),
                  const SizedBox(height: 16),
                  ...summary.subjectAttendances.map(
                    (sub) => _SubjectAttendanceRow(item: sub),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 26),

            // RECENT MARKS & ACADEMIC PERFORMANCE
            SectionHeader(
              title: 'Recent Marks & Performance',
              action: TextButton.icon(
                onPressed: () => context.go('/parent/performance'),
                icon: const Icon(Icons.arrow_forward, size: 16),
                label: const Text('View Grades'),
              ),
            ),
            const SizedBox(height: 10),
            AppCard(
              child: Column(
                children: [
                  ...summary.subjectPerformances.take(4).map((perf) {
                    final isPositive = perf.trend.startsWith('+');
                    return Column(
                      children: [
                        ListTile(
                          contentPadding: EdgeInsets.zero,
                          title: Text(
                            perf.subjectName,
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                            ),
                          ),
                          subtitle: Text(
                            'Internal Score: ${perf.internalScore}/${perf.maxInternal} • Credits: ${perf.credits}',
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.textSecondary,
                            ),
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.primary.withOpacity(0.08),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  perf.grade,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.primary,
                                    fontSize: 13,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                perf.trend,
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 12,
                                  color: isPositive
                                      ? AppColors.success
                                      : AppColors.danger,
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (perf != summary.subjectPerformances[3])
                          const Divider(height: 1),
                      ],
                    );
                  }),
                ],
              ),
            ),
            const SizedBox(height: 26),

            // UPCOMING EXAMS & ASSIGNMENTS
            const SectionHeader(title: 'Upcoming Exams & Deadlines'),
            const SizedBox(height: 10),
            AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'EXAMINATIONS',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textSecondary,
                      letterSpacing: 0.8,
                    ),
                  ),
                  const SizedBox(height: 8),
                  ...summary.upcomingExams.map(
                    (exam) => ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.event_available_rounded,
                          color: AppColors.primary,
                          size: 20,
                        ),
                      ),
                      title: Text(
                        exam.title,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                      subtitle: Text(
                        '${exam.subject} • ${exam.dateString} (${exam.time})',
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      trailing: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE9F1FF),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          '${exam.daysLeft}d left',
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Divider(height: 1),
                  const SizedBox(height: 12),
                  const Text(
                    'ASSIGNMENTS',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textSecondary,
                      letterSpacing: 0.8,
                    ),
                  ),
                  const SizedBox(height: 8),
                  ...summary.upcomingAssignments.map(
                    (assign) => ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: assign.isUrgent
                              ? AppColors.warning.withOpacity(0.15)
                              : AppColors.surface,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          Icons.assignment_outlined,
                          color: assign.isUrgent
                              ? AppColors.warning
                              : AppColors.textSecondary,
                          size: 20,
                        ),
                      ),
                      title: Text(
                        assign.title,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                      subtitle: Text(
                        '${assign.subject} • ${assign.dueDateString}',
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      trailing: Text(
                        assign.status,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: assign.isUrgent
                              ? AppColors.danger
                              : assign.status == 'Submitted'
                              ? AppColors.success
                              : AppColors.primary,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 26),

            // IMPORTANT ANNOUNCEMENTS
            const SectionHeader(title: 'Important Announcements'),
            const SizedBox(height: 10),
            AppCard(
              child: Column(
                children: summary.announcements.map((announcement) {
                  return Column(
                    children: [
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: announcement.isUrgent
                                ? AppColors.danger.withOpacity(0.1)
                                : AppColors.surface,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            announcement.isUrgent
                                ? Icons.campaign_rounded
                                : Icons.info_outline_rounded,
                            color: announcement.isUrgent
                                ? AppColors.danger
                                : AppColors.primary,
                            size: 22,
                          ),
                        ),
                        title: Row(
                          children: [
                            Expanded(
                              child: Text(
                                announcement.title,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                            if (announcement.isUrgent)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 6,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.danger.withOpacity(0.12),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: const Text(
                                  'Important',
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.danger,
                                  ),
                                ),
                              ),
                          ],
                        ),
                        subtitle: Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Text(
                            '${announcement.category} • ${announcement.date}\n${announcement.summary}',
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.textSecondary,
                              height: 1.35,
                            ),
                          ),
                        ),
                      ),
                      if (announcement != summary.announcements.last)
                        const Divider(height: 16),
                    ],
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 26),

            // RECENT ACADEMIC ACTIVITY
            const SectionHeader(title: 'Recent Academic Activity'),
            const SizedBox(height: 10),
            AppCard(
              child: Column(
                children: summary.recentActivities.map((act) {
                  return Column(
                    children: [
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: CircleAvatar(
                          radius: 18,
                          backgroundColor: act.color.withOpacity(0.12),
                          child: Icon(act.icon, size: 18, color: act.color),
                        ),
                        title: Text(
                          act.title,
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                          ),
                        ),
                        subtitle: Text(
                          act.description,
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        trailing: Text(
                          act.timeAgo,
                          style: const TextStyle(
                            fontSize: 11,
                            color: AppColors.muted,
                          ),
                        ),
                      ),
                      if (act != summary.recentActivities.last)
                        const Divider(height: 1),
                    ],
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ChildProfileCard extends StatelessWidget {
  const _ChildProfileCard({
    required this.name,
    required this.rollNumber,
    required this.department,
    required this.semester,
    required this.onViewProfile,
  });

  final String name;
  final String rollNumber;
  final String department;
  final int semester;
  final VoidCallback onViewProfile;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.25),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 28,
            backgroundColor: Colors.white,
            child: Text(
              name.isNotEmpty ? name[0] : 'S',
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: AppColors.primary,
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        name,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.verified_rounded,
                            size: 12,
                            color: Colors.white,
                          ),
                          SizedBox(width: 4),
                          Text(
                            'Verified Parent',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  'Student ID: $rollNumber',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  '$department • Semester $semester',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.8),
                    fontSize: 12,
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

class _SmartInsightCard extends StatelessWidget {
  const _SmartInsightCard({required this.insight});

  final SmartInsight insight;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: insight.accentColor.withOpacity(0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: insight.accentColor.withOpacity(0.25),
          width: 1,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: insight.accentColor.withOpacity(0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(insight.icon, color: insight.accentColor, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      insight.title,
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        color: insight.accentColor,
                        fontSize: 13,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 7,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: insight.accentColor.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        insight.badgeText,
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: insight.accentColor,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  insight.message,
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.textPrimary,
                    height: 1.35,
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

class _SubjectAttendanceRow extends StatelessWidget {
  const _SubjectAttendanceRow({required this.item});

  final SubjectAttendance item;

  @override
  Widget build(BuildContext context) {
    final isLow = item.percentage < 75;
    final color = isLow
        ? AppColors.danger
        : item.percentage < 85
        ? AppColors.warning
        : AppColors.success;

    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  item.subjectName,
                  style: TextStyle(
                    fontWeight: isLow ? FontWeight.w700 : FontWeight.w500,
                    fontSize: 13,
                    color: isLow ? AppColors.danger : AppColors.textPrimary,
                  ),
                ),
              ),
              Text(
                '${item.attended}/${item.total} (${item.percentage.toStringAsFixed(1)}%)',
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 12,
                  color: color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: item.percentage / 100,
              minHeight: 6,
              backgroundColor: AppColors.border,
              valueColor: AlwaysStoppedAnimation<Color>(color),
            ),
          ),
        ],
      ),
    );
  }
}

class ParentBottomNav extends StatelessWidget {
  const ParentBottomNav({required this.currentIndex, super.key});
  final int currentIndex;

  @override
  Widget build(BuildContext context) {
    const routes = [
      '/parent',
      '/parent/attendance',
      '/parent/performance',
      '/parent/profile',
    ];

    return NavigationBar(
      selectedIndex: currentIndex,
      onDestinationSelected: (index) {
        if (index != currentIndex && index < routes.length) {
          if (index == routes.length - 1) {
            context.push(routes[index]);
          } else {
            context.go(routes[index]);
          }
        }
      },
      destinations: const [
        NavigationDestination(
          icon: Icon(Icons.dashboard_outlined),
          selectedIcon: Icon(Icons.dashboard),
          label: 'Dashboard',
        ),
        NavigationDestination(
          icon: Icon(Icons.fact_check_outlined),
          selectedIcon: Icon(Icons.fact_check),
          label: 'Attendance',
        ),
        NavigationDestination(
          icon: Icon(Icons.insights_outlined),
          selectedIcon: Icon(Icons.insights),
          label: 'Performance',
        ),
        NavigationDestination(
          icon: Icon(Icons.person_outline),
          selectedIcon: Icon(Icons.person),
          label: 'Profile',
        ),
      ],
    );
  }
}

class ParentAcademicDataUnavailable extends StatelessWidget {
  const ParentAcademicDataUnavailable({super.key});

  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.all(28),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 460),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.school_outlined,
              size: 42,
              color: AppColors.primary,
            ),
            const SizedBox(height: 16),
            Text(
              'Academic records are not available yet',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            const Text(
              'Your Parent account is verified. Ask your institution to connect the authorized student record and academic data to this account.',
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    ),
  );
}
