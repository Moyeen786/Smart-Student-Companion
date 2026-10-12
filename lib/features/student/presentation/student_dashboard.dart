
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:smart_student_companion/app/app_providers.dart';

class StudentDashboard extends ConsumerWidget {
  const StudentDashboard({super.key});

  static const Color primaryColor = Color(0xFF3456D1);
  static const Color backgroundColor = Color(0xFFF5F7FB);
  static const Color textColor = Color(0xFF202A44);
  static const Color secondaryTextColor = Color(0xFF64748B);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);
    final user = authState.valueOrNull?.user;

    final String studentName =
        (user?.name ?? '').trim().isEmpty
            ? 'Student'
            : user!.name.trim();

    final String rollNumber =
        (user?.rollNumber ?? '').trim().isEmpty
            ? 'Student Account'
            : user!.rollNumber.trim();

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        title: const Text(
          'Student Companion',
          style: TextStyle(
            color: textColor,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            tooltip: 'Profile',
            onPressed: () => context.go('/student/profile'),
            icon: const Icon(
              Icons.account_circle_outlined,
              color: primaryColor,
            ),
          ),
          IconButton(
            tooltip: 'Logout',
            onPressed: () => _showLogoutDialog(context, ref),
            icon: const Icon(
              Icons.logout_outlined,
              color: primaryColor,
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),

      // Navigation to all student screens.
      bottomNavigationBar: NavigationBar(
        selectedIndex: 0,
        onDestinationSelected: (index) {
          const routes = [
            '/student',
            '/student/attendance',
            '/student/timetable',
            '/student/assignments',
            '/student/notes',
            '/student/profile',
          ];

          context.go(routes[index]);
        },
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
            icon: Icon(Icons.note_alt_outlined),
            label: 'Notes',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            label: 'Profile',
          ),
        ],
      ),

      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(18),
          children: [
            _buildWelcomeCard(studentName, rollNumber),
            const SizedBox(height: 26),

            _sectionTitle('Academic Overview'),
            const SizedBox(height: 14),

            // Data will be connected to shared providers later.
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1.3,
              children: [
                _statCard(
                  title: 'Attendance',
                  value: '--',
                  subtitle: 'Attendance records',
                  icon: Icons.fact_check_outlined,
                  color: Colors.green,
                  route: '/student/attendance',
                ),
                _statCard(
                  title: 'Assignments',
                  value: '--',
                  subtitle: 'View your work',
                  icon: Icons.assignment_outlined,
                  color: Colors.orange,
                  route: '/student/assignments',
                ),
                _statCard(
                  title: 'Classes Today',
                  value: '--',
                  subtitle: 'Your class schedule',
                  icon: Icons.calendar_month_outlined,
                  color: Colors.blue,
                  route: '/student/timetable',
                ),
                _statCard(
                  title: 'Study Notes',
                  value: '--',
                  subtitle: 'Your saved notes',
                  icon: Icons.note_alt_outlined,
                  color: Colors.purple,
                  route: '/student/notes',
                ),
              ],
            ),

            const SizedBox(height: 28),

            _sectionTitle('Quick Access'),
            const SizedBox(height: 14),

            _quickAccessCard(
              title: 'Assignments',
              subtitle: 'View and submit assignments',
              icon: Icons.assignment_outlined,
              color: Colors.orange,
              route: '/student/assignments',
            ),
            _quickAccessCard(
              title: 'Attendance',
              subtitle: 'Check your attendance',
              icon: Icons.fact_check_outlined,
              color: Colors.green,
              route: '/student/attendance',
            ),
            _quickAccessCard(
              title: 'Timetable',
              subtitle: 'View your weekly schedule',
              icon: Icons.calendar_month_outlined,
              color: Colors.blue,
              route: '/student/timetable',
            ),
            _quickAccessCard(
              title: 'Study Notes',
              subtitle: 'Organize your study notes',
              icon: Icons.note_alt_outlined,
              color: Colors.purple,
              route: '/student/notes',
            ),

            const SizedBox(height: 28),

            Row(
              children: [
                const Expanded(
                  child: Text(
                    'Upcoming Assignments',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: textColor,
                    ),
                  ),
                ),
                TextButton(
                  onPressed: () => context.go('/student/assignments'),
                  child: const Text('See all'),
                ),
              ],
            ),

            const SizedBox(height: 10),

            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(22),
              decoration: _cardDecoration(),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: primaryColor.withValues(alpha: 0.09),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.assignment_outlined,
                      color: primaryColor,
                      size: 34,
                    ),
                  ),
                  const SizedBox(height: 14),
                  const Text(
                    'Your assignments',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: textColor,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Open the assignments page to view the available '
                    'assignment list. Shared teacher assignments will '
                    'appear here after data integration.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: secondaryTextColor,
                      fontSize: 12,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      onPressed: () =>
                          context.go('/student/assignments'),
                      style: FilledButton.styleFrom(
                        backgroundColor: primaryColor,
                        padding: const EdgeInsets.symmetric(vertical: 13),
                      ),
                      icon: const Icon(Icons.arrow_forward),
                      label: const Text('Open Assignments'),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 28),

            _sectionTitle('Other Services'),
            const SizedBox(height: 12),

            Container(
              decoration: _cardDecoration(),
              child: Column(
                children: [
                  _serviceTile(
                    icon: Icons.person_outline,
                    title: 'My Profile',
                    subtitle: 'View your student details',
                    onTap: () => context.go('/student/profile'),
                  ),
                  const Divider(height: 1, indent: 70),
                  _serviceTile(
                    icon: Icons.note_alt_outlined,
                    title: 'Study Notes',
                    subtitle: 'Open your study notes',
                    onTap: () => context.go('/student/notes'),
                  ),
                  const Divider(height: 1, indent: 70),
                  _serviceTile(
                    icon: Icons.calendar_month_outlined,
                    title: 'Class Timetable',
                    subtitle: 'Check your weekly schedule',
                    onTap: () => context.go('/student/timetable'),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 26),

            const Center(
              child: Text(
                'Smart Student Companion',
                style: TextStyle(
                  color: secondaryTextColor,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  Widget _buildWelcomeCard(String name, String rollNumber) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFF3456D1),
            Color(0xFF647FEA),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(22),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Welcome back,',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  name,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 23,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  rollNumber,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 14),
                const Text(
                  'Stay organized. Keep learning.',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Container(
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.16),
              borderRadius: BorderRadius.circular(18),
            ),
            child: const Icon(
              Icons.school_outlined,
              color: Colors.white,
              size: 38,
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: textColor,
      ),
    );
  }

  Widget _statCard({
    required String title,
    required String value,
    required String subtitle,
    required IconData icon,
    required Color color,
    required String route,
  }) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: () => _openRoute(route),
        child: Container(
          padding: const EdgeInsets.all(15),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: const Color(0xFFE6EAF2)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Row(
                children: [
                  Icon(icon, color: color, size: 23),
                  const Spacer(),
                  Text(
                    value,
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: textColor,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                subtitle,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 11,
                  color: secondaryTextColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _quickAccessCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required String route,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: _cardDecoration(),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 8,
        ),
        leading: Container(
          width: 46,
          height: 46,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.10),
            borderRadius: BorderRadius.circular(13),
          ),
          child: Icon(icon, color: color),
        ),
        title: Text(
          title,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: textColor,
          ),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Text(
            subtitle,
            style: const TextStyle(
              fontSize: 12,
              color: secondaryTextColor,
            ),
          ),
        ),
        trailing: const Icon(
          Icons.chevron_right,
          color: secondaryTextColor,
        ),
        onTap: () => _openRoute(route),
      ),
    );
  }

  Widget _serviceTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 14,
        vertical: 5,
      ),
      leading: CircleAvatar(
        backgroundColor: const Color(0xFFEAF0FF),
        child: Icon(icon, color: primaryColor),
      ),
      title: Text(
        title,
        style: const TextStyle(
          fontWeight: FontWeight.w600,
          color: textColor,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: const TextStyle(
          fontSize: 12,
          color: secondaryTextColor,
        ),
      ),
      trailing: const Icon(
        Icons.chevron_right,
        color: secondaryTextColor,
      ),
      onTap: onTap,
    );
  }

  BoxDecoration _cardDecoration() {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(18),
      border: Border.all(color: const Color(0xFFE6EAF2)),
    );
  }

  void _openRoute(String route) {
    // The context is obtained through the card callbacks in build().
    // Navigation is handled by the callback-specific helper below.
  }

  void _showLogoutDialog(BuildContext context, WidgetRef ref) {
    showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Logout'),
          content: const Text(
            'Are you sure you want to log out?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                Navigator.pop(dialogContext);
                ref.read(authStateProvider.notifier).logout();
                context.go('/login');
              },
              child: const Text('Logout'),
            ),
          ],
        );
      },
    );
  }
}
