import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class StudentAttendance extends StatefulWidget {
  const StudentAttendance({super.key});

  @override
  State<StudentAttendance> createState() => _StudentAttendanceState();
}

class _StudentAttendanceState extends State<StudentAttendance> {
  String _selectedFilter = 'All';

  final List<Map<String, dynamic>> _attendance = [
    {
      'subject': 'Computer Networks',
      'code': 'CS501',
      'attended': 28,
      'total': 30,
      'color': Colors.blue,
      'icon': Icons.lan_outlined,
    },
    {
      'subject': 'Operating Systems',
      'code': 'CS502',
      'attended': 27,
      'total': 30,
      'color': Colors.deepPurple,
      'icon': Icons.computer_outlined,
    },
    {
      'subject': 'Design and Analysis of Algorithms',
      'code': 'CS503',
      'attended': 25,
      'total': 28,
      'color': Colors.teal,
      'icon': Icons.code_outlined,
    },
    {
      'subject': 'Database Management Systems',
      'code': 'CS504',
      'attended': 19,
      'total': 20,
      'color': Colors.orange,
      'icon': Icons.storage_outlined,
    },
  ];

  double _percentage(Map<String, dynamic> item) {
    final total = item['total'] as int;
    if (total == 0) return 0;
    return (item['attended'] as int) / total * 100;
  }

  int get _totalClasses =>
      _attendance.fold(0, (sum, item) => sum + (item['total'] as int));

  int get _attendedClasses =>
      _attendance.fold(0, (sum, item) => sum + (item['attended'] as int));

  double get _overallPercentage =>
      _totalClasses == 0 ? 0 : _attendedClasses / _totalClasses * 100;

  List<Map<String, dynamic>> get _filteredAttendance {
    if (_selectedFilter == 'Below 75%') {
      return _attendance.where((item) => _percentage(item) < 75).toList();
    }

    if (_selectedFilter == '75% and above') {
      return _attendance.where((item) => _percentage(item) >= 75).toList();
    }

    return _attendance;
  }

  @override
  Widget build(BuildContext context) {
    final percentage = _overallPercentage;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FB),
      appBar: AppBar(
        title: const Text(
          'Attendance',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            tooltip: 'Dashboard',
            onPressed: () => context.go('/student'),
            icon: const Icon(Icons.home_outlined),
          ),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: 1,
        onDestinationSelected: _navigate,
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home_outlined), label: 'Home'),
          NavigationDestination(
            icon: Icon(Icons.fact_check_outlined),
            selectedIcon: Icon(Icons.fact_check),
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
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF3456D1), Color(0xFF6878ED)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(22),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Overall attendance',
                    style: TextStyle(color: Colors.white70),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          '${percentage.toStringAsFixed(1)}%',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 36,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      SizedBox(
                        width: 76,
                        height: 76,
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            CircularProgressIndicator(
                              value: percentage / 100,
                              strokeWidth: 8,
                              backgroundColor: Colors.white24,
                              valueColor: const AlwaysStoppedAnimation<Color>(
                                Colors.white,
                              ),
                            ),
                            Center(
                              child: Text(
                                '${percentage.round()}%',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    '$_attendedClasses of $_totalClasses classes attended',
                    style: const TextStyle(color: Colors.white),
                  ),
                  const SizedBox(height: 16),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: LinearProgressIndicator(
                      value: percentage / 100,
                      minHeight: 8,
                      backgroundColor: Colors.white24,
                      valueColor: const AlwaysStoppedAnimation<Color>(
                        Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Keep track of your attendance in every subject.',
                    style: TextStyle(color: Colors.white70, fontSize: 12),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: _InfoCard(
                    title: 'Attended',
                    value: '$_attendedClasses',
                    icon: Icons.check_circle_outline,
                    color: Colors.green,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _InfoCard(
                    title: 'Missed',
                    value: '${_totalClasses - _attendedClasses}',
                    icon: Icons.event_busy_outlined,
                    color: Colors.deepOrange,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 26),
            const Text(
              'Subject-wise attendance',
              style: TextStyle(
                fontSize: 19,
                fontWeight: FontWeight.bold,
                color: Color(0xFF172554),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 42,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: ['All', 'Below 75%', '75% and above'].map((filter) {
                  final selected = _selectedFilter == filter;

                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: Text(filter),
                      selected: selected,
                      showCheckmark: false,
                      selectedColor: const Color(0xFF3456D1),
                      backgroundColor: Colors.white,
                      labelStyle: TextStyle(
                        color: selected ? Colors.white : Colors.black87,
                        fontWeight: FontWeight.w600,
                      ),
                      onSelected: (_) {
                        setState(() => _selectedFilter = filter);
                      },
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 12),
            if (_filteredAttendance.isEmpty)
              const Padding(
                padding: EdgeInsets.all(28),
                child: Center(child: Text('No subjects match this filter.')),
              ),
            ..._filteredAttendance.map(
              (item) => _SubjectAttendanceCard(
                subject: item['subject'] as String,
                code: item['code'] as String,
                attended: item['attended'] as int,
                total: item['total'] as int,
                percentage: _percentage(item),
                color: item['color'] as Color,
                icon: item['icon'] as IconData,
              ),
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.amber.shade50,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.amber.shade100),
              ),
              child: const Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.info_outline, color: Colors.orange),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'These are sample attendance figures for UI testing. '
                      'Actual attendance will appear after connecting your '
                      'college attendance data.',
                      style: TextStyle(height: 1.5),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _navigate(int index) {
    const routes = [
      '/student',
      '/student/attendance',
      '/student/timetable',
      '/student/assignments',
      '/student/notes',
      '/student/profile',
    ];

    if (index == 1) return;

    if (index == routes.length - 1) {
      context.push(routes[index]);
    } else {
      context.go(routes[index]);
    }
  }
}

class _InfoCard extends StatelessWidget {
  const _InfoCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  final String title;
  final String value;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 27),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  title,
                  style: const TextStyle(color: Colors.blueGrey, fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SubjectAttendanceCard extends StatelessWidget {
  const _SubjectAttendanceCard({
    required this.subject,
    required this.code,
    required this.attended,
    required this.total,
    required this.percentage,
    required this.color,
    required this.icon,
  });

  final String subject;
  final String code;
  final int attended;
  final int total;
  final double percentage;
  final Color color;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final progressColor = percentage < 75 ? Colors.deepOrange : Colors.green;

    return Card(
      color: Colors.white,
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: const BorderSide(color: Color(0xFFE6EAF2)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.10),
                    borderRadius: BorderRadius.circular(13),
                  ),
                  child: Icon(icon, color: color),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        subject,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        code,
                        style: const TextStyle(
                          color: Colors.blueGrey,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  '${percentage.toStringAsFixed(1)}%',
                  style: TextStyle(
                    color: progressColor,
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: LinearProgressIndicator(
                value: percentage / 100,
                minHeight: 7,
                backgroundColor: const Color(0xFFE9EDF5),
                valueColor: AlwaysStoppedAnimation<Color>(progressColor),
              ),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Text(
                  '$attended / $total classes attended',
                  style: const TextStyle(color: Colors.blueGrey, fontSize: 12),
                ),
                const Spacer(),
                if (percentage < 75)
                  const Text(
                    'Below 75%',
                    style: TextStyle(
                      color: Colors.deepOrange,
                      fontWeight: FontWeight.w600,
                      fontSize: 11,
                    ),
                  )
                else
                  const Text(
                    'On track',
                    style: TextStyle(
                      color: Colors.green,
                      fontWeight: FontWeight.w600,
                      fontSize: 11,
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
