import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:smart_student_companion/app/app_providers.dart';
import 'package:smart_student_companion/core/widgets/app_card.dart';
import 'package:smart_student_companion/core/widgets/section_header.dart';
import 'package:smart_student_companion/core/widgets/stat_card.dart';

class AdminDashboard extends ConsumerWidget {
  const AdminDashboard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Administrator Portal'),
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
      bottomNavigationBar: NavigationBar(
        selectedIndex: 0,
        onDestinationSelected: (index) {
          const routes = [
            '/admin',
            '/admin/users',
            '/admin/analytics',
            '/admin/utilities',
          ];
          if (index < routes.length) context.go(routes[index]);
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.dashboard_outlined),
            label: 'Dashboard',
          ),
          NavigationDestination(
            icon: Icon(Icons.people_outline),
            label: 'Users',
          ),
          NavigationDestination(
            icon: Icon(Icons.analytics_outlined),
            label: 'Analytics',
          ),
          NavigationDestination(icon: Icon(Icons.more_horiz), label: 'More'),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            const Text(
              'Institutional overview',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 16),
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1.25,
              children: const [
                StatCard(
                  label: 'Students',
                  value: '1,280',
                  icon: Icons.school_rounded,
                  color: Color(0xFFEAF6EE),
                ),
                StatCard(
                  label: 'Faculty',
                  value: '128',
                  icon: Icons.person_pin_rounded,
                  color: Color(0xFFE9F1FF),
                ),
                StatCard(
                  label: 'Announcements',
                  value: '1,020',
                  icon: Icons.family_restroom_rounded,
                  color: Color(0xFFFFF3E7),
                ),
                StatCard(
                  label: 'Departments',
                  value: '12',
                  icon: Icons.apartment_rounded,
                  color: Color(0xFFF1E8FF),
                ),
              ],
            ),
            const SizedBox(height: 28),
            const SectionHeader(title: 'Quick actions'),
            const SizedBox(height: 8),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                ActionChip(
                  avatar: const Icon(Icons.people_outline, size: 18),
                  label: const Text('Manage Users'),
                  onPressed: () => context.go('/admin/users'),
                ),
                ActionChip(
                  avatar: const Icon(Icons.campaign_outlined, size: 18),
                  label: const Text('Announcements'),
                  onPressed: () => context.go('/admin/announcements'),
                ),
                ActionChip(
                  avatar: const Icon(Icons.analytics_outlined, size: 18),
                  label: const Text('Analytics'),
                  onPressed: () => context.go('/admin/analytics'),
                ),
                ActionChip(
                  avatar: const Icon(Icons.build_outlined, size: 18),
                  label: const Text('Campus Utilities'),
                  onPressed: () => context.go('/admin/utilities'),
                ),
              ],
            ),
            const SizedBox(height: 28),
            const SectionHeader(title: 'Announcements'),
            AppCard(
              child: Column(
                children: const [
                  ListTile(
                    title: Text('Semester registration open'),
                    subtitle: Text('Open until September 28, 2026'),
                  ),
                  Divider(),
                  ListTile(
                    title: Text('Campus event schedule published'),
                    subtitle: Text('Updated by the administration office'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            const SectionHeader(title: 'System utilities'),
            AppCard(
              child: Column(
                children: const [
                  ListTile(
                    title: Text('Library access'),
                    leading: Icon(Icons.local_library_rounded),
                  ),
                  ListTile(
                    title: Text('Placements'),
                    leading: Icon(Icons.work_rounded),
                  ),
                  ListTile(
                    title: Text('Lost & found'),
                    leading: Icon(Icons.search_rounded),
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
