
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class StudentTimetable extends StatefulWidget {
  const StudentTimetable({super.key});

  @override
  State<StudentTimetable> createState() => _StudentTimetableState();
}

class _StudentTimetableState extends State<StudentTimetable> {
  int _selectedDay = DateTime.now().weekday - 1;

  final List<String> _days = const [
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
  ];

  final List<String> _shortDays = const [
    'MON',
    'TUE',
    'WED',
    'THU',
    'FRI',
    'SAT',
  ];

  final Map<int, List<Map<String, String>>> _timetable = {
    0: [
      {
        'time': '09:00 AM - 10:00 AM',
        'subject': 'Data Structures',
        'code': 'DS',
        'room': 'Room 201',
        'faculty': 'Faculty Member',
        'type': 'Lecture',
      },
      {
        'time': '10:00 AM - 11:00 AM',
        'subject': 'Computer Networks',
        'code': 'CN',
        'room': 'Room 204',
        'faculty': 'Faculty Member',
        'type': 'Lecture',
      },
      {
        'time': '11:15 AM - 12:15 PM',
        'subject': 'Database Management Systems',
        'code': 'DB',
        'room': 'Room 205',
        'faculty': 'Faculty Member',
        'type': 'Lecture',
      },
      {
        'time': '01:00 PM - 03:00 PM',
        'subject': 'Programming Lab',
        'code': 'PL',
        'room': 'Computer Lab 1',
        'faculty': 'Lab Instructor',
        'type': 'Lab',
      },
    ],
    1: [
      {
        'time': '09:00 AM - 10:00 AM',
        'subject': 'Operating Systems',
        'code': 'OS',
        'room': 'Room 202',
        'faculty': 'Faculty Member',
        'type': 'Lecture',
      },
      {
        'time': '10:00 AM - 11:00 AM',
        'subject': 'Design and Analysis of Algorithms',
        'code': 'DA',
        'room': 'Room 203',
        'faculty': 'Faculty Member',
        'type': 'Lecture',
      },
      {
        'time': '11:15 AM - 12:15 PM',
        'subject': 'Computer Networks',
        'code': 'CN',
        'room': 'Room 204',
        'faculty': 'Faculty Member',
        'type': 'Lecture',
      },
    ],
    2: [
      {
        'time': '09:00 AM - 10:00 AM',
        'subject': 'Database Management Systems',
        'code': 'DB',
        'room': 'Room 205',
        'faculty': 'Faculty Member',
        'type': 'Lecture',
      },
      {
        'time': '10:00 AM - 11:00 AM',
        'subject': 'Operating Systems',
        'code': 'OS',
        'room': 'Room 202',
        'faculty': 'Faculty Member',
        'type': 'Lecture',
      },
      {
        'time': '01:00 PM - 03:00 PM',
        'subject': 'Networks Lab',
        'code': 'NL',
        'room': 'Computer Lab 2',
        'faculty': 'Lab Instructor',
        'type': 'Lab',
      },
    ],
    3: [
      {
        'time': '09:00 AM - 10:00 AM',
        'subject': 'Design and Analysis of Algorithms',
        'code': 'DA',
        'room': 'Room 203',
        'faculty': 'Faculty Member',
        'type': 'Lecture',
      },
      {
        'time': '10:00 AM - 11:00 AM',
        'subject': 'Data Structures',
        'code': 'DS',
        'room': 'Room 201',
        'faculty': 'Faculty Member',
        'type': 'Lecture',
      },
      {
        'time': '11:15 AM - 12:15 PM',
        'subject': 'Database Management Systems',
        'code': 'DB',
        'room': 'Room 205',
        'faculty': 'Faculty Member',
        'type': 'Lecture',
      },
    ],
    4: [
      {
        'time': '09:00 AM - 10:00 AM',
        'subject': 'Computer Networks',
        'code': 'CN',
        'room': 'Room 204',
        'faculty': 'Faculty Member',
        'type': 'Lecture',
      },
      {
        'time': '10:00 AM - 11:00 AM',
        'subject': 'Operating Systems',
        'code': 'OS',
        'room': 'Room 202',
        'faculty': 'Faculty Member',
        'type': 'Lecture',
      },
      {
        'time': '01:00 PM - 03:00 PM',
        'subject': 'Database Lab',
        'code': 'DL',
        'room': 'Computer Lab 1',
        'faculty': 'Lab Instructor',
        'type': 'Lab',
      },
    ],
    5: [
      {
        'time': '09:00 AM - 10:00 AM',
        'subject': 'Programming Practice',
        'code': 'PP',
        'room': 'Computer Lab 1',
        'faculty': 'Lab Instructor',
        'type': 'Lab',
      },
      {
        'time': '10:00 AM - 11:00 AM',
        'subject': 'Mentoring Session',
        'code': 'MS',
        'room': 'Room 101',
        'faculty': 'Class Mentor',
        'type': 'Session',
      },
    ],
  };

  @override
  Widget build(BuildContext context) {
    final classes = _timetable[_selectedDay] ?? [];

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FB),
      appBar: AppBar(
        title: const Text(
          'Class Timetable',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            tooltip: 'Today',
            onPressed: () {
              setState(() {
                _selectedDay = DateTime.now().weekday - 1;
                if (_selectedDay > 5) _selectedDay = 0;
              });
            },
            icon: const Icon(Icons.today_outlined),
          ),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: 2,
        onDestinationSelected: _navigate,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.fact_check_outlined),
            label: 'Attendance',
          ),
          NavigationDestination(
            icon: Icon(Icons.calendar_month),
            selectedIcon: Icon(Icons.calendar_month),
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
            _buildWelcomeCard(),
            const SizedBox(height: 24),
            const Text(
              'Select Day',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF202A44),
              ),
            ),
            const SizedBox(height: 14),
            _buildDaySelector(),
            const SizedBox(height: 24),
            Row(
              children: [
                const Expanded(
                  child: Text(
                    'Your Classes',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF202A44),
                    ),
                  ),
                ),
                Text(
                  '${classes.length} classes',
                  style: const TextStyle(
                    color: Color(0xFF64748B),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            if (classes.isEmpty)
              _buildEmptyState()
            else
              ...List.generate(
                classes.length,
                (index) => _buildClassCard(
                  classes[index],
                  index,
                ),
              ),
            const SizedBox(height: 18),
            _buildReminderCard(),
          ],
        ),
      ),
    );
  }

  Widget _buildWelcomeCard() {
    return Container(
      padding: const EdgeInsets.all(20),
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
                  'Weekly Schedule',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 21,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  _days[_selectedDay],
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.9),
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Keep your classes organized and stay on track.',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.85),
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
              Icons.calendar_month_outlined,
              size: 38,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDaySelector() {
    return SizedBox(
      height: 82,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: _days.length,
        separatorBuilder: (_, __) => const SizedBox(width: 10),
        itemBuilder: (context, index) {
          final selected = index == _selectedDay;

          return GestureDetector(
            onTap: () {
              setState(() => _selectedDay = index);
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              width: 62,
              decoration: BoxDecoration(
                color: selected
                    ? const Color(0xFF3456D1)
                    : Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: selected
                      ? const Color(0xFF3456D1)
                      : const Color(0xFFE3E8F0),
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    _shortDays[index],
                    style: TextStyle(
                      color: selected
                          ? Colors.white
                          : const Color(0xFF64748B),
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Icon(
                    Icons.circle,
                    size: 9,
                    color: selected
                        ? Colors.white
                        : const Color(0xFFD6DCE8),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildClassCard(
    Map<String, String> item,
    int index,
  ) {
    final isLab = item['type'] == 'Lab';
    final color = isLab
        ? const Color(0xFF8B5CF6)
        : const Color(0xFF3456D1);

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE6EAF2)),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: () => _showClassDetails(item),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 5,
                height: 100,
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(5),
                ),
              ),
              const SizedBox(width: 13),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item['time']!,
                      style: const TextStyle(
                        color: Color(0xFF64748B),
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 9),
                    Text(
                      item['subject']!,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF202A44),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(
                          Icons.location_on_outlined,
                          size: 15,
                          color: Color(0xFF64748B),
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            item['room']!,
                            style: const TextStyle(
                              color: Color(0xFF64748B),
                              fontSize: 12,
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 9,
                            vertical: 5,
                          ),
                          decoration: BoxDecoration(
                            color: color.withValues(alpha: 0.10),
                            borderRadius: BorderRadius.circular(9),
                          ),
                          child: Text(
                            item['type']!,
                            style: TextStyle(
                              color: color,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 5),
              const Icon(
                Icons.chevron_right,
                color: Color(0xFF94A3B8),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE6EAF2)),
      ),
      child: const Column(
        children: [
          Icon(
            Icons.event_available_outlined,
            size: 48,
            color: Color(0xFF3456D1),
          ),
          SizedBox(height: 12),
          Text(
            'No classes scheduled',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 6),
          Text(
            'Enjoy your day! There are no classes listed for this day.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Color(0xFF64748B),
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReminderCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFEAF0FF),
        borderRadius: BorderRadius.circular(16),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.tips_and_updates_outlined,
            color: Color(0xFF3456D1),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Quick Reminder',
                  style: TextStyle(
                    color: Color(0xFF202A44),
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 5),
                Text(
                  'Check your timetable regularly. Your actual class schedule may change.',
                  style: TextStyle(
                    color: Color(0xFF53627D),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showClassDetails(Map<String, String> item) {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      backgroundColor: Colors.white,
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(22, 10, 22, 28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                item['subject']!,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 18),
              _detailRow(
                Icons.access_time_outlined,
                'Time',
                item['time']!,
              ),
              _detailRow(
                Icons.location_on_outlined,
                'Room',
                item['room']!,
              ),
              _detailRow(
                Icons.person_outline,
                'Faculty',
                item['faculty']!,
              ),
              _detailRow(
                Icons.category_outlined,
                'Class Type',
                item['type']!,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _detailRow(
    IconData icon,
    String label,
    String value,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFF3456D1), size: 20),
          const SizedBox(width: 12),
          Text(
            '$label: ',
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
          Expanded(child: Text(value)),
        ],
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

    if (index == 2) return;

    context.go(routes[index]);
  }
}
