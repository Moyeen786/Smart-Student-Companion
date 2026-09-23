import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:smart_student_companion/core/theme/app_colors.dart';
import 'package:smart_student_companion/features/admin/domain/models/admin_models.dart';
import 'package:smart_student_companion/features/admin/presentation/widgets/admin_widgets.dart';
import 'package:smart_student_companion/features/admin/providers/admin_providers.dart';

class AdminDashboard extends ConsumerWidget {
  const AdminDashboard({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(adminDashboardProvider);
    return AdminShell(
      title: 'Admin Dashboard',
      child: state.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, _) => _errorState(ref),
        data: (data) =>
            _content(context, data.overview, data.departments, data.activities),
      ),
    );
  }

  Widget _errorState(WidgetRef ref) => Center(
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Text('Unable to load the institutional overview.'),
        const SizedBox(height: 12),
        OutlinedButton(
          onPressed: () => ref.invalidate(adminDashboardProvider),
          child: const Text('Try again'),
        ),
      ],
    ),
  );

  Widget _content(
    BuildContext context,
    AdminOverview overview,
    List<DepartmentSummary> departments,
    List<ActivityItem> activities,
  ) => LayoutBuilder(
    builder: (context, constraints) {
      final wide = constraints.maxWidth >= 980;
      return ListView(
        padding: const EdgeInsets.fromLTRB(28, 26, 28, 36),
        children: [
          const Text(
            'Good morning, Administrator',
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            "Here's an overview of your institution.",
            style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
          ),
          const SizedBox(height: 24),
          GridView.count(
            crossAxisCount: wide ? 4 : 2,
            crossAxisSpacing: 14,
            mainAxisSpacing: 14,
            childAspectRatio: wide ? 1.42 : 1.65,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            children: [
              AdminStatCard(
                label: 'Total students',
                value: '${overview.students}',
                detail: 'From institution users',
                icon: Icons.school_outlined,
                color: AppColors.primary,
              ),
              AdminStatCard(
                label: 'Total faculty',
                value: '${overview.faculty}',
                detail: 'From institution users',
                icon: Icons.badge_outlined,
                color: const Color(0xFF1F7A52),
              ),
              AdminStatCard(
                label: 'Departments',
                value: '${overview.departments}',
                detail: 'Configured departments',
                icon: Icons.account_tree_outlined,
                color: const Color(0xFF6B4FA1),
              ),
              AdminStatCard(
                label: 'Active events',
                value: '${overview.activeEvents}',
                detail: 'Published or active',
                icon: Icons.event_available_outlined,
                color: const Color(0xFFB26A00),
              ),
            ],
          ),
          const SizedBox(height: 28),
          if (wide)
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: _attendance(departments, overview.attendance)),
                const SizedBox(width: 18),
                Expanded(child: _activity(activities)),
              ],
            )
          else ...[
            _attendance(departments, overview.attendance),
            const SizedBox(height: 18),
            _activity(activities),
          ],
          const SizedBox(height: 28),
          SectionTitle(
            title: 'Department overview',
            action: TextButton(
              onPressed: () => context.go('/admin/analytics'),
              child: const Text('View analytics'),
            ),
          ),
          const SizedBox(height: 12),
          AdminCard(
            child: departments.isEmpty
                ? const _EmptyText(
                    message: 'No departments have been configured.',
                  )
                : Column(
                    children: departments
                        .map((department) => _departmentRow(department, wide))
                        .toList(),
                  ),
          ),
          const SizedBox(height: 28),
          const SectionTitle(title: 'Quick actions'),
          const SizedBox(height: 12),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              _action(
                context,
                'Add user',
                Icons.person_add_alt_1,
                '/admin/users',
              ),
              _action(
                context,
                'Create announcement',
                Icons.campaign_outlined,
                '/admin/announcements/create',
              ),
              _action(
                context,
                'View analytics',
                Icons.insights_outlined,
                '/admin/analytics',
              ),
              _action(
                context,
                'Campus services',
                Icons.apartment_outlined,
                '/admin/utilities',
              ),
            ],
          ),
        ],
      );
    },
  );

  Widget _attendance(List<DepartmentSummary> departments, int? attendance) =>
      AdminCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SectionTitle(title: 'Attendance overview'),
            const SizedBox(height: 20),
            Text(
              attendance == null ? '--' : '$attendance%',
              style: const TextStyle(
                fontSize: 36,
                fontWeight: FontWeight.w800,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 18),
            if (departments.isEmpty)
              const _EmptyText(message: 'No attendance data available.')
            else
              ...departments.map(
                (d) => Padding(
                  padding: const EdgeInsets.only(bottom: 11),
                  child: Row(
                    children: [
                      SizedBox(
                        width: 42,
                        child: Text(
                          d.name,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      Expanded(
                        child: LinearProgressIndicator(
                          value: d.attendance / 100,
                          minHeight: 7,
                          backgroundColor: const Color(0xFFE8EEF6),
                          color: AppColors.primary,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        '${d.attendance}%',
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      );
  Widget _activity(List<ActivityItem> activities) => AdminCard(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionTitle(title: 'Recent activity'),
        const SizedBox(height: 8),
        if (activities.isEmpty)
          const _EmptyText(message: 'No recent activity.')
        else
          ...activities.map(
            (a) => ListTile(
              contentPadding: EdgeInsets.zero,
              leading: CircleAvatar(
                radius: 17,
                backgroundColor: a.color.withValues(alpha: .1),
                child: Icon(a.icon, size: 17, color: a.color),
              ),
              title: Text(
                a.title,
                style: const TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w600,
                ),
              ),
              subtitle: Text(
                a.time,
                style: const TextStyle(
                  fontSize: 11,
                  color: AppColors.textSecondary,
                ),
              ),
            ),
          ),
      ],
    ),
  );
  Widget _departmentRow(DepartmentSummary d, bool wide) => Container(
    padding: const EdgeInsets.symmetric(vertical: 13),
    decoration: const BoxDecoration(
      border: Border(top: BorderSide(color: AppColors.border)),
    ),
    child: wide
        ? Row(
            children: [
              Expanded(
                child: Text(
                  d.name,
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
              ),
              SizedBox(width: 90, child: Text('${d.students}')),
              SizedBox(width: 80, child: Text('${d.faculty}')),
              SizedBox(width: 80, child: Text('${d.attendance}%')),
              const SizedBox(
                width: 55,
                child: Text(
                  'Active',
                  style: TextStyle(color: AppColors.success, fontSize: 12),
                ),
              ),
            ],
          )
        : Row(
            children: [
              Expanded(
                child: Text(
                  d.name,
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
              ),
              Text(
                '${d.students} students  |  ${d.attendance}%',
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 12,
                ),
              ),
            ],
          ),
  );
  Widget _action(
    BuildContext context,
    String label,
    IconData icon,
    String route,
  ) => InkWell(
    onTap: () => context.go(route),
    child: Container(
      width: 190,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppColors.primary, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    ),
  );
}

class _EmptyText extends StatelessWidget {
  const _EmptyText({required this.message});
  final String message;
  @override
  Widget build(BuildContext context) => Text(
    message,
    style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
  );
}
