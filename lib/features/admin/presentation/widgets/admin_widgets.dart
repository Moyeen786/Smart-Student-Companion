import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:smart_student_companion/app/app_providers.dart';
import 'package:smart_student_companion/core/theme/app_colors.dart';
import 'package:smart_student_companion/features/admin/domain/models/admin_models.dart';
import 'package:smart_student_companion/features/admin/providers/admin_providers.dart';

class AdminShell extends StatelessWidget {
  const AdminShell({super.key, required this.title, required this.child});
  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final compact = constraints.maxWidth < 920;
        return Scaffold(
          drawer: compact ? const Drawer(child: AdminSidebar()) : null,
          body: Row(
            children: [
              if (!compact) const SizedBox(width: 248, child: AdminSidebar()),
              Expanded(
                child: Column(
                  children: [
                    AdminHeader(title: title, compact: compact),
                    Expanded(child: child),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class AdminSidebar extends ConsumerWidget {
  const AdminSidebar({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final path = GoRouterState.of(context).uri.path;
    return Material(
      color: AppColors.primaryVariant,
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 26, 18, 28),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'SMART STUDENT',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.2,
                    ),
                  ),
                  Text(
                    'COMPANION',
                    style: TextStyle(
                      color: Color(0xFFA9C9F2),
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.2,
                    ),
                  ),
                  SizedBox(height: 18),
                  Text(
                    'ADMIN PORTAL',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 1.4,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                children: [
                  _item(
                    context,
                    'Dashboard',
                    Icons.grid_view_rounded,
                    '/admin',
                    path == '/admin',
                  ),
                  _item(
                    context,
                    'User Management',
                    Icons.people_alt_outlined,
                    '/admin/users',
                    path.startsWith('/admin/users'),
                  ),
                  _item(
                    context,
                    'Announcements',
                    Icons.campaign_outlined,
                    '/admin/announcements',
                    path.startsWith('/admin/announcements'),
                  ),
                  _item(
                    context,
                    'Analytics',
                    Icons.insights_outlined,
                    '/admin/analytics',
                    path.startsWith('/admin/analytics'),
                  ),
                  _item(
                    context,
                    'Campus Services',
                    Icons.apartment_outlined,
                    '/admin/utilities',
                    path.startsWith('/admin/utilities'),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(14, 20, 12, 8),
                    child: Text(
                      'SERVICES',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: .48),
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ),
                  _subItem(
                    context,
                    'Library',
                    Icons.menu_book_outlined,
                    '/admin/utilities/library',
                  ),
                  _subItem(
                    context,
                    'Placements',
                    Icons.work_outline_rounded,
                    '/admin/utilities/placements',
                  ),
                  _subItem(
                    context,
                    'Events',
                    Icons.event_outlined,
                    '/admin/utilities/events',
                  ),
                  _subItem(
                    context,
                    'Lost & Found',
                    Icons.inventory_2_outlined,
                    '/admin/utilities/lost-found',
                  ),
                ],
              ),
            ),
            const Divider(color: Color(0x33FFFFFF), height: 1),
            _item(
              context,
              'Settings',
              Icons.settings_outlined,
              '/admin/profile',
              path == '/admin/profile',
            ),
            _logoutItem(context, ref),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }

  Widget _item(
    BuildContext context,
    String label,
    IconData icon,
    String route,
    bool selected,
  ) => ListTile(
    dense: true,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    selected: selected,
    selectedTileColor: const Color(0xFF2C64AC),
    leading: Icon(
      icon,
      size: 20,
      color: selected ? Colors.white : const Color(0xFFB8CBE5),
    ),
    title: Text(
      label,
      style: TextStyle(
        color: selected ? Colors.white : const Color(0xFFD9E5F4),
        fontSize: 13,
        fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
      ),
    ),
    onTap: () => context.go(route),
  );
  Widget _subItem(
    BuildContext context,
    String label,
    IconData icon,
    String route,
  ) => ListTile(
    dense: true,
    contentPadding: const EdgeInsets.only(left: 28, right: 8),
    leading: Icon(icon, size: 17, color: const Color(0xFF9DB7D8)),
    title: Text(
      label,
      style: const TextStyle(color: Color(0xFFB8CBE5), fontSize: 12.5),
    ),
    onTap: () => context.go(route),
  );

  Widget _logoutItem(BuildContext context, WidgetRef ref) => ListTile(
    dense: true,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    leading: const Icon(
      Icons.logout_rounded,
      size: 20,
      color: Color(0xFFB8CBE5),
    ),
    title: const Text(
      'Logout',
      style: TextStyle(color: Color(0xFFD9E5F4), fontSize: 13),
    ),
    onTap: () => showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Log out?'),
        content: const Text(
          'You will need to sign in again to access the Admin Portal.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () async {
              Navigator.pop(dialogContext);
              await ref.read(authStateProvider.notifier).logout();
              if (context.mounted) context.go('/login');
            },
            child: const Text('Logout'),
          ),
        ],
      ),
    ),
  );
}

class AdminHeader extends ConsumerWidget {
  const AdminHeader({super.key, required this.title, required this.compact});
  final String title;
  final bool compact;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authStateProvider).valueOrNull?.user;
    final displayName = user?.name.isNotEmpty == true
        ? user!.name
        : 'Administrator';
    final initials = displayName
        .split(RegExp(r'\s+'))
        .where((part) => part.isNotEmpty)
        .take(2)
        .map((part) => part[0].toUpperCase())
        .join();
    return Container(
      height: 76,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: AppColors.border)),
      ),
      child: Row(
        children: [
          if (compact)
            IconButton(
              onPressed: () => Scaffold.of(context).openDrawer(),
              icon: const Icon(Icons.menu_rounded),
            ),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 19,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          IconButton(
            onPressed: () => _showNotifications(context, ref),
            tooltip: 'Notifications',
            icon: const Icon(
              Icons.notifications_none_rounded,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(width: 8),
          CircleAvatar(
            radius: 18,
            backgroundColor: Color(0xFFDCEBFA),
            child: Text(
              initials.isEmpty ? 'A' : initials,
              style: const TextStyle(
                color: AppColors.primary,
                fontSize: 12,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          if (!compact)
            Padding(
              padding: EdgeInsets.only(left: 10),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    displayName,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Text(
                    user?.email ?? 'Administrator',
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          const SizedBox(width: 4),
          PopupMenuButton<String>(
            tooltip: 'Admin account menu',
            icon: const Icon(
              Icons.keyboard_arrow_down_rounded,
              size: 18,
              color: AppColors.textSecondary,
            ),
            onSelected: (value) => _handleMenu(context, ref, value),
            itemBuilder: (context) => const [
              PopupMenuItem(
                value: 'profile',
                child: ListTile(
                  leading: Icon(Icons.person_outline),
                  title: Text('View profile'),
                ),
              ),
              PopupMenuItem(
                value: 'settings',
                child: ListTile(
                  leading: Icon(Icons.settings_outlined),
                  title: Text('Settings'),
                ),
              ),
              PopupMenuDivider(),
              PopupMenuItem(
                value: 'logout',
                child: ListTile(
                  leading: Icon(Icons.logout_rounded),
                  title: Text('Logout'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _handleMenu(BuildContext context, WidgetRef ref, String value) {
    switch (value) {
      case 'profile':
      case 'settings':
        context.go('/admin/profile');
      case 'logout':
        _logout(context, ref);
    }
  }

  Future<void> _logout(BuildContext context, WidgetRef ref) async {
    await ref.read(authStateProvider.notifier).logout();
    if (context.mounted) context.go('/login');
  }

  void _showNotifications(BuildContext context, WidgetRef ref) {
    showDialog<void>(
      context: context,
      builder: (dialogContext) {
        final content = ref
            .watch(activityProvider)
            .when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (_, _) => const Text('Unable to load notifications.'),
              data: (items) => items.isEmpty
                  ? const Text('No new notifications.')
                  : ListView(
                      shrinkWrap: true,
                      children: items
                          .map(
                            (item) => ListTile(
                              leading: Icon(item.icon, color: item.color),
                              title: Text(item.title),
                              subtitle: Text(item.time),
                            ),
                          )
                          .toList(),
                    ),
            );
        return AlertDialog(
          title: const Row(
            children: [
              Icon(Icons.notifications_none_rounded),
              SizedBox(width: 10),
              Text('Notifications'),
            ],
          ),
          content: SizedBox(width: 380, child: content),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }
}

class AdminStatCard extends StatelessWidget {
  const AdminStatCard({
    super.key,
    required this.label,
    required this.value,
    required this.detail,
    required this.icon,
    required this.color,
  });
  final String label, value, detail;
  final IconData icon;
  final Color color;
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(18),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: AppColors.border),
      boxShadow: const [
        BoxShadow(
          color: Color(0x080E2848),
          blurRadius: 14,
          offset: Offset(0, 5),
        ),
      ],
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label.toUpperCase(),
              style: const TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w800,
                color: AppColors.textSecondary,
                letterSpacing: .6,
              ),
            ),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withValues(alpha: .1),
                borderRadius: BorderRadius.circular(9),
              ),
              child: Icon(icon, size: 19, color: color),
            ),
          ],
        ),
        const Spacer(),
        Text(
          value,
          style: const TextStyle(
            fontSize: 27,
            fontWeight: FontWeight.w800,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          detail,
          style: TextStyle(
            fontSize: 11,
            color: color,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    ),
  );
}

class StatusBadge extends StatelessWidget {
  const StatusBadge({super.key, required this.status});
  final RecordStatus status;
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
    decoration: BoxDecoration(
      color: status.color.withValues(alpha: .1),
      borderRadius: BorderRadius.circular(20),
    ),
    child: Text(
      status.label.toUpperCase(),
      style: TextStyle(
        color: status.color,
        fontSize: 9,
        fontWeight: FontWeight.w800,
        letterSpacing: .4,
      ),
    ),
  );
}

class SectionTitle extends StatelessWidget {
  const SectionTitle({super.key, required this.title, this.action});
  final String title;
  final Widget? action;
  @override
  Widget build(BuildContext context) => Row(
    children: [
      Expanded(
        child: Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
      ),
      ?action,
    ],
  );
}

class AdminCard extends StatelessWidget {
  const AdminCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(20),
  });
  final Widget child;
  final EdgeInsets padding;
  @override
  Widget build(BuildContext context) => Container(
    padding: padding,
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: AppColors.border),
    ),
    child: child,
  );
}
