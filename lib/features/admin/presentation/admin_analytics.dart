import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smart_student_companion/core/theme/app_colors.dart';
import 'package:smart_student_companion/features/admin/domain/models/admin_models.dart';
import 'package:smart_student_companion/features/admin/presentation/widgets/admin_widgets.dart';
import 'package:smart_student_companion/features/admin/providers/admin_providers.dart';

class AdminAnalytics extends ConsumerWidget {
  const AdminAnalytics({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(adminDashboardProvider);
    return AdminShell(
      title: 'Institutional Analytics',
      child: state.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, _) => Center(
          child: OutlinedButton(
            onPressed: () => ref.invalidate(adminDashboardProvider),
            child: const Text('Try again'),
          ),
        ),
        data: (data) => _content(data.overview, data.departments),
      ),
    );
  }

  Widget _content(
    AdminOverview overview,
    List<DepartmentSummary> departments,
  ) => ListView(
    padding: const EdgeInsets.fromLTRB(28, 26, 28, 36),
    children: [
      const Text(
        'Institutional analytics',
        style: TextStyle(
          fontSize: 26,
          fontWeight: FontWeight.w800,
          color: AppColors.textPrimary,
        ),
      ),
      const SizedBox(height: 6),
      const Text(
        'A focused view of academic health and institutional scale.',
        style: TextStyle(color: AppColors.textSecondary),
      ),
      const SizedBox(height: 24),
      Wrap(
        spacing: 14,
        runSpacing: 14,
        children: [
          SizedBox(
            width: 210,
            height: 125,
            child: AdminStatCard(
              label: 'Overall attendance',
              value: overview.attendance == null
                  ? '--'
                  : '${overview.attendance}%',
              detail: 'From department records',
              icon: Icons.fact_check_outlined,
              color: AppColors.primary,
            ),
          ),
          SizedBox(
            width: 210,
            height: 125,
            child: AdminStatCard(
              label: 'Students',
              value: '${overview.students}',
              detail: 'From institution users',
              icon: Icons.groups_outlined,
              color: const Color(0xFF1F7A52),
            ),
          ),
          SizedBox(
            width: 210,
            height: 125,
            child: AdminStatCard(
              label: 'Faculty',
              value: '${overview.faculty}',
              detail: 'From institution users',
              icon: Icons.support_agent_outlined,
              color: const Color(0xFF6B4FA1),
            ),
          ),
        ],
      ),
      const SizedBox(height: 28),
      AdminCard(
        child: departments.isEmpty
            ? const Text(
                'No department analytics available.',
                style: TextStyle(color: AppColors.textSecondary),
              )
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SectionTitle(title: 'Attendance by department'),
                  const SizedBox(height: 20),
                  ...departments.map(
                    (d) => Padding(
                      padding: const EdgeInsets.only(bottom: 17),
                      child: Row(
                        children: [
                          SizedBox(
                            width: 50,
                            child: Text(
                              d.name,
                              style: const TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 12,
                              ),
                            ),
                          ),
                          Expanded(
                            child: LinearProgressIndicator(
                              value: d.attendance / 100,
                              minHeight: 12,
                              backgroundColor: const Color(0xFFE8EEF6),
                              color: AppColors.primary,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            '${d.attendance}%',
                            style: const TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
      ),
    ],
  );
}
