import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:smart_student_companion/app/app_providers.dart';
import 'package:smart_student_companion/core/theme/app_colors.dart';
import 'package:smart_student_companion/core/widgets/app_card.dart';
import 'package:smart_student_companion/core/widgets/section_header.dart';
import 'package:smart_student_companion/core/widgets/stat_card.dart';

class StudentDashboard extends ConsumerWidget {
  const StudentDashboard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authStateProvider).valueOrNull?.user;
    const routes = <String>[
      '/student',
      '/student/attendance',
      '/student/timetable',
      '/student/assignments',
      '/student/profile',
    ];
    return Scaffold(
      appBar: AppBar(
        title: const Text('Student Dashboard'),
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
        onDestinationSelected: (index) => index == 0
            ? context.go(routes[index])
            : context.push(routes[index]),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.fact_check_outlined),
            label: 'Attendance',
          ),
          NavigationDestination(
            icon: Icon(Icons.calendar_month_outlined),
            label: 'Timetable',
          ),
          NavigationDestination(
            icon: Icon(Icons.assignment_outlined),
            label: 'Assignments',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            label: 'Profile',
          ),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
          children: [
            Row(
              children: [
                const CircleAvatar(
                  radius: 28,
                  child: Icon(Icons.person_rounded),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Good morning, ${user?.name ?? 'Student'}',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      Text(
                        'Roll Number: ${user?.rollNumber ?? ''}',
                        style: TextStyle(color: AppColors.textSecondary),
                      ),
                      Text(
                        '${user?.department ?? ''} - Semester ${user?.semester ?? 0}',
                        style: TextStyle(color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 22),
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1.35,
              children: const [
                StatCard(
                  label: 'Attendance',
                  value: '92%',
                  icon: Icons.check_circle_rounded,
                  color: Color(0xFFEAF6EE),
                ),
                StatCard(
                  label: 'CGPA',
                  value: '8.4',
                  icon: Icons.insights_rounded,
                  color: Color(0xFFE9F1FF),
                ),
                StatCard(
                  label: 'Credits',
                  value: '96',
                  icon: Icons.school_rounded,
                  color: Color(0xFFFFF3E7),
                ),
                StatCard(
                  label: 'Assignments',
                  value: '03',
                  icon: Icons.assignment_rounded,
                  color: Color(0xFFF1E8FF),
                ),
              ],
            ),
            const SizedBox(height: 28),
            SectionHeader(
              title: "Today's timetable",
              action: TextButton(
                onPressed: () => context.push('/student/timetable'),
                child: const Text('View all'),
              ),
            ),
            const SizedBox(height: 8),
            const AppCard(
              child: Column(
                children: [
                  ListTile(
                    leading: Text(
                      '09:00',
                      style: TextStyle(fontWeight: FontWeight.w700),
                    ),
                    title: Text('Computer Networks'),
                    subtitle: Text('Dr. Faculty Name - Room AB-204'),
                  ),
                  Divider(height: 1),
                  ListTile(
                    leading: Text(
                      '11:00',
                      style: TextStyle(fontWeight: FontWeight.w700),
                    ),
                    title: Text('Operating Systems'),
                    subtitle: Text('Prof. Anita Rao - Room CC-301'),
                  ),
                  Divider(height: 1),
                  ListTile(
                    leading: Text(
                      '14:00',
                      style: TextStyle(fontWeight: FontWeight.w700),
                    ),
                    title: Text('Design and Analysis of Algorithms'),
                    subtitle: Text('Dr. Faculty Name - Room AB-105'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            SectionHeader(
              title: 'Attendance overview',
              action: TextButton(
                onPressed: () => context.push('/student/attendance'),
                child: const Text('Details'),
              ),
            ),
            const SizedBox(height: 8),
            const AppCard(
              child: Column(
                children: [
                  _ProgressRow(
                    subject: 'Computer Networks',
                    value: 0.94,
                    percent: '94%',
                  ),
                  _ProgressRow(
                    subject: 'Operating Systems',
                    value: 0.91,
                    percent: '91%',
                  ),
                  _ProgressRow(
                    subject: 'Algorithms',
                    value: 0.89,
                    percent: '89%',
                  ),
                  _ProgressRow(
                    subject: 'Database Systems',
                    value: 0.95,
                    percent: '95%',
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            SectionHeader(
              title: 'Upcoming assignments',
              action: TextButton(
                onPressed: () => context.push('/student/assignments'),
                child: const Text('View all'),
              ),
            ),
            const SizedBox(height: 8),
            const AppCard(
              child: Column(
                children: [
                  ListTile(
                    title: Text('Network security case study'),
                    subtitle: Text('Computer Networks - Due tomorrow'),
                    trailing: Text(
                      'Pending',
                      style: TextStyle(color: AppColors.warning),
                    ),
                  ),
                  Divider(height: 1),
                  ListTile(
                    title: Text('Process scheduling report'),
                    subtitle: Text('Operating Systems - Due Sep 28'),
                    trailing: Text(
                      'In progress',
                      style: TextStyle(color: AppColors.primary),
                    ),
                  ),
                  Divider(height: 1),
                  ListTile(
                    title: Text('Algorithm analysis'),
                    subtitle: Text('Algorithms - Due Oct 02'),
                    trailing: Text(
                      'Not started',
                      style: TextStyle(color: AppColors.textSecondary),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            const SectionHeader(title: 'Announcements'),
            const SizedBox(height: 8),
            const AppCard(
              child: Column(
                children: [
                  ListTile(
                    leading: Icon(Icons.campaign_outlined),
                    title: Text('Semester registration is open'),
                    subtitle: Text(
                      'Complete registration before September 28.',
                    ),
                  ),
                  Divider(height: 1),
                  ListTile(
                    leading: Icon(Icons.event_outlined),
                    title: Text('Campus event schedule published'),
                    subtitle: Text(
                      'Updated activities are available in campus services.',
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            const SectionHeader(title: 'Quick access'),
            const SizedBox(height: 10),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                _QuickAction(
                  label: 'Attendance',
                  icon: Icons.fact_check_outlined,
                  onTap: () => context.push('/student/attendance'),
                ),
                _QuickAction(
                  label: 'Timetable',
                  icon: Icons.calendar_month_outlined,
                  onTap: () => context.push('/student/timetable'),
                ),
                _QuickAction(
                  label: 'Assignments',
                  icon: Icons.assignment_outlined,
                  onTap: () => context.push('/student/assignments'),
                ),
                _QuickAction(
                  label: 'Notes',
                  icon: Icons.note_alt_outlined,
                  onTap: () => context.push('/student/notes'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ProgressRow extends StatelessWidget {
  const _ProgressRow({
    required this.subject,
    required this.value,
    required this.percent,
  });
  final String subject;
  final double value;
  final String percent;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 14),
    child: Column(
      children: [
        Row(
          children: [
            Expanded(child: Text(subject)),
            Text(percent, style: const TextStyle(fontWeight: FontWeight.w700)),
          ],
        ),
        const SizedBox(height: 7),
        LinearProgressIndicator(
          value: value,
          minHeight: 7,
          borderRadius: BorderRadius.circular(8),
        ),
      ],
    ),
  );
}

class _QuickAction extends StatelessWidget {
  const _QuickAction({
    required this.label,
    required this.icon,
    required this.onTap,
  });
  final String label;
  final IconData icon;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) => ActionChip(
    avatar: Icon(icon, size: 18),
    label: Text(label),
    onPressed: onTap,
  );
}
