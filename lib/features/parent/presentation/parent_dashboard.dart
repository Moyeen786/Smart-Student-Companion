import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:smart_student_companion/app/app_providers.dart';
import 'package:smart_student_companion/core/theme/app_colors.dart';
import 'package:smart_student_companion/core/widgets/app_card.dart';
import 'package:smart_student_companion/core/widgets/section_header.dart';
import 'package:smart_student_companion/core/widgets/stat_card.dart';

class ParentDashboard extends ConsumerWidget {
  const ParentDashboard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Parent Dashboard'),
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
            '/parent',
            '/parent/attendance',
            '/parent/performance',
          ];
          if (index < routes.length) context.go(routes[index]);
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.dashboard_outlined),
            label: 'Overview',
          ),
          NavigationDestination(
            icon: Icon(Icons.fact_check_outlined),
            label: 'Attendance',
          ),
          NavigationDestination(
            icon: Icon(Icons.insights_outlined),
            label: 'Performance',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            label: 'Profile',
          ),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Row(
              children: [
                const CircleAvatar(
                  radius: 28,
                  child: Icon(Icons.family_restroom_rounded),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text(
                      'Student: Riya Sharma',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      'CSE • Semester 5',
                      style: TextStyle(color: AppColors.textSecondary),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 20),
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1.25,
              children: const [
                StatCard(
                  label: 'Attendance',
                  value: '92%',
                  icon: Icons.check_circle_outline_rounded,
                  color: Color(0xFFEAF6EE),
                ),
                StatCard(
                  label: 'CGPA',
                  value: '8.4',
                  icon: Icons.trending_up_rounded,
                  color: Color(0xFFE9F1FF),
                ),
                StatCard(
                  label: 'Subjects',
                  value: '07',
                  icon: Icons.book_rounded,
                  color: Color(0xFFFFF3E7),
                ),
                StatCard(
                  label: 'Alerts',
                  value: '02',
                  icon: Icons.notifications_active_rounded,
                  color: Color(0xFFF1E8FF),
                ),
              ],
            ),
            const SizedBox(height: 28),
            const SectionHeader(title: 'Recent academic activity'),
            AppCard(
              child: Column(
                children: const [
                  ListTile(
                    title: Text('Internal Test 2'),
                    subtitle: Text('Scored 88% • Data Structures'),
                    trailing: Icon(Icons.trending_up_rounded),
                  ),
                  Divider(),
                  ListTile(
                    title: Text('Attendance update'),
                    subtitle: Text('Computer Science lab attendance improved'),
                    trailing: Icon(Icons.check_circle_rounded),
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
