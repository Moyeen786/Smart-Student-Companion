import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:smart_student_companion/core/theme/app_colors.dart';
import 'package:smart_student_companion/features/admin/domain/models/admin_models.dart';
import 'package:smart_student_companion/features/admin/presentation/widgets/admin_widgets.dart';
import 'package:smart_student_companion/features/admin/providers/admin_providers.dart';

class UserManagement extends ConsumerStatefulWidget {
  const UserManagement({super.key});
  @override
  ConsumerState<UserManagement> createState() => _UserManagementState();
}

class _UserManagementState extends ConsumerState<UserManagement> {
  final search = TextEditingController();
  int tab = 0;
  @override
  Widget build(BuildContext context) {
    final state = ref.watch(adminUsersProvider);
    return AdminShell(
      title: 'User Management',
      child: state.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, _) => _error(),
        data: (users) => _content(context, users),
      ),
    );
  }

  Widget _error() => Center(
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Text('Unable to load users.'),
        const SizedBox(height: 12),
        OutlinedButton(
          onPressed: () => ref.invalidate(adminUsersProvider),
          child: const Text('Try again'),
        ),
      ],
    ),
  );
  Widget _content(BuildContext context, List<AdminUser> allUsers) {
    final q = search.text.toLowerCase();
    final users = allUsers.where((item) {
      final matches =
          item.user.name.toLowerCase().contains(q) ||
          item.user.email.toLowerCase().contains(q) ||
          item.user.uid.toLowerCase().contains(q);
      final role =
          tab == 0 ||
          (tab == 1 && item.user.role.name == 'student') ||
          (tab == 2 && item.user.role.name == 'faculty') ||
          (tab == 3 && item.user.role.name == 'parent');
      return matches && role;
    }).toList();
    return ListView(
      padding: const EdgeInsets.fromLTRB(28, 26, 28, 36),
      children: [
        const Text(
          'User management',
          style: TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.w800,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 6),
        const Text(
          'Manage students, faculty and institutional accounts.',
          style: TextStyle(color: AppColors.textSecondary),
        ),
        const SizedBox(height: 24),
        TextField(
          controller: search,
          onChanged: (_) => setState(() {}),
          decoration: const InputDecoration(
            prefixIcon: Icon(Icons.search),
            hintText: 'Search by name, ID or email',
          ),
        ),
        const SizedBox(height: 20),
        DefaultTabController(
          length: 4,
          child: AdminCard(
            padding: EdgeInsets.zero,
            child: Column(
              children: [
                TabBar(
                  tabs: const [
                    Tab(text: 'ALL'),
                    Tab(text: 'STUDENTS'),
                    Tab(text: 'FACULTY'),
                    Tab(text: 'PARENTS'),
                  ],
                  onTap: (value) => setState(() => tab = value),
                  isScrollable: true,
                  labelColor: AppColors.primary,
                  indicatorColor: AppColors.primary,
                ),
                if (users.isEmpty)
                  const Padding(
                    padding: EdgeInsets.all(28),
                    child: Text(
                      'No users match the current filters.',
                      style: TextStyle(color: AppColors.textSecondary),
                    ),
                  ),
                ...users.map((item) => _row(context, item)),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _row(BuildContext context, AdminUser item) => InkWell(
    onTap: () => context.push('/admin/users/${item.user.uid}'),
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      child: Row(
        children: [
          CircleAvatar(
            radius: 19,
            backgroundColor: const Color(0xFFE4EFFB),
            child: Text(
              item.user.name.isEmpty ? '?' : item.user.name.substring(0, 1),
              style: const TextStyle(
                color: AppColors.primary,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            flex: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.user.name,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                  ),
                ),
                Text(
                  item.user.email,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Text(
              item.user.uid,
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.textSecondary,
              ),
            ),
          ),
          Expanded(
            child: Text(
              item.user.role.name,
              style: const TextStyle(fontSize: 12),
            ),
          ),
          Expanded(
            child: Text(
              item.user.department,
              style: const TextStyle(fontSize: 12),
            ),
          ),
          StatusBadge(status: item.status),
          const SizedBox(width: 8),
          const Icon(Icons.chevron_right, color: AppColors.muted, size: 19),
        ],
      ),
    ),
  );
  @override
  void dispose() {
    search.dispose();
    super.dispose();
  }
}
