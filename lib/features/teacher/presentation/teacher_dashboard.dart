import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:smart_student_companion/app/app_providers.dart';
import 'package:smart_student_companion/core/theme/app_colors.dart';
import 'package:smart_student_companion/core/widgets/app_card.dart';
import 'package:smart_student_companion/core/widgets/section_header.dart';
import 'package:smart_student_companion/core/widgets/stat_card.dart';

class TeacherDashboard extends ConsumerWidget {
  const TeacherDashboard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Faculty Dashboard'),
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
            '/faculty',
            '/faculty/attendance',
            '/faculty/assignments',
            '/faculty/leave-requests',
          ];
          if (index < routes.length) {
            index == 0
                ? context.go(routes[index])
                : context.push(routes[index]);
          }
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.dashboard_outlined),
            label: 'Dashboard',
          ),
          NavigationDestination(
            icon: Icon(Icons.fact_check_outlined),
            label: 'Classes',
          ),
          NavigationDestination(
            icon: Icon(Icons.assignment_outlined),
            label: 'Assignments',
          ),
          NavigationDestination(
            icon: Icon(Icons.inbox_outlined),
            label: 'Requests',
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
                  child: Icon(Icons.person_rounded),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text(
                      'Good morning, Dr. Mehta',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      'Faculty ID: FAC-2026-018 • CSE',
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
                  label: "Today's Classes",
                  value: '06',
                  icon: Icons.class_rounded,
                  color: Color(0xFFEAF6EE),
                ),
                StatCard(
                  label: 'Pending Attendance',
                  value: '02',
                  icon: Icons.fact_check_rounded,
                  color: Color(0xFFE9F1FF),
                ),
                StatCard(
                  label: 'Assignments',
                  value: '18',
                  icon: Icons.assignment_turned_in_rounded,
                  color: Color(0xFFFFF3E7),
                ),
                StatCard(
                  label: 'Leave Requests',
                  value: '03',
                  icon: Icons.event_busy_rounded,
                  color: Color(0xFFF1E8FF),
                ),
              ],
            ),
            const SizedBox(height: 28),
            const SectionHeader(title: "Today's classes"),
            const SizedBox(height: 8),
            const AppCard(
              child: Column(
                children: [
                  ListTile(
                    title: Text('Computer Networks'),
                    subtitle: Text('09:00 - Room AB-204 • 42 students'),
                    trailing: Icon(Icons.class_outlined),
                  ),
                  Divider(height: 1),
                  ListTile(
                    title: Text('Operating Systems'),
                    subtitle: Text('11:00 - Room CC-301 • 38 students'),
                    trailing: Icon(Icons.class_outlined),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 28),
            const SectionHeader(title: 'Pending leave requests'),
            const SizedBox(height: 8),
            AppCard(
              child: Column(
                children: const [
                  ListTile(
                    title: Text('Sanket Reddy'),
                    subtitle: Text('Medical leave • 2 days'),
                    trailing: Text('Pending'),
                  ),
                  Divider(),
                  ListTile(
                    title: Text('Priya Nair'),
                    subtitle: Text('Academic conference • 1 day'),
                    trailing: Text('Approved'),
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
