
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class StudentAssignments extends StatefulWidget {
  const StudentAssignments({super.key});

  @override
  State<StudentAssignments> createState() =>
      _StudentAssignmentsState();
}

class _StudentAssignmentsState extends State<StudentAssignments> {
  final TextEditingController _searchController =
      TextEditingController();

  String _filter = 'All';

  // Demo data. Shared with the dashboard in a later step.
  final List<Map<String, dynamic>> _assignments = [
    {
      'title': 'Sorting Algorithms',
      'subject': 'Design and Analysis of Algorithms',
      'description':
          'Implement Quick Sort and Merge Sort. Explain their time and space complexities.',
      'due': '18 Oct 2026',
      'status': 'Pending',
      'icon': Icons.code,
      'color': Colors.blue,
    },
    {
      'title': 'Database Design',
      'subject': 'Database Management Systems',
      'description':
          'Design an ER diagram for a student management system.',
      'due': '20 Oct 2026',
      'status': 'Pending',
      'icon': Icons.storage,
      'color': Colors.deepPurple,
    },
    {
      'title': 'Network Programming',
      'subject': 'Computer Networks',
      'description':
          'Implement a client-server program using TCP sockets.',
      'due': '15 Oct 2026',
      'status': 'Submitted',
      'icon': Icons.lan,
      'color': Colors.teal,
    },
    {
      'title': 'Functional Programming',
      'subject': 'Programming Paradigms',
      'description':
          'Solve list-processing problems using Haskell and recursion.',
      'due': '22 Oct 2026',
      'status': 'Pending',
      'icon': Icons.functions,
      'color': Colors.orange,
    },
  ];

  List<Map<String, dynamic>> get _visibleAssignments {
    final query = _searchController.text.trim().toLowerCase();

    return _assignments.where((assignment) {
      final matchesSearch =
          assignment['title'].toString().toLowerCase().contains(query) ||
          assignment['subject'].toString().toLowerCase().contains(query);

      final matchesFilter =
          _filter == 'All' || assignment['status'] == _filter;

      return matchesSearch && matchesFilter;
    }).toList();
  }

  int get _pendingCount => _assignments
      .where((a) => a['status'] == 'Pending')
      .length;

  int get _submittedCount => _assignments
      .where((a) => a['status'] == 'Submitted')
      .length;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final assignments = _visibleAssignments;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FB),
      appBar: AppBar(
        title: const Text(
          'Assignments',
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
        selectedIndex: 3,
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
            icon: Icon(Icons.calendar_month_outlined),
            label: 'Timetable',
          ),
          NavigationDestination(
            icon: Icon(Icons.assignment_outlined),
            selectedIcon: Icon(Icons.assignment),
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
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(18, 12, 18, 20),
              color: Colors.white,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Manage your academic work',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.blueGrey,
                    ),
                  ),
                  const SizedBox(height: 18),
                  Row(
                    children: [
                      Expanded(
                        child: _SummaryCard(
                          label: 'Total',
                          count: _assignments.length,
                          color: Colors.blue,
                          icon: Icons.assignment_outlined,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _SummaryCard(
                          label: 'Pending',
                          count: _pendingCount,
                          color: Colors.deepOrange,
                          icon: Icons.schedule,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _SummaryCard(
                          label: 'Submitted',
                          count: _submittedCount,
                          color: Colors.green,
                          icon: Icons.check_circle_outline,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  TextField(
                    controller: _searchController,
                    onChanged: (_) => setState(() {}),
                    decoration: InputDecoration(
                      hintText: 'Search assignments...',
                      prefixIcon: const Icon(Icons.search),
                      suffixIcon: _searchController.text.isEmpty
                          ? null
                          : IconButton(
                              onPressed: () {
                                _searchController.clear();
                                setState(() {});
                              },
                              icon: const Icon(Icons.close),
                            ),
                      filled: true,
                      fillColor: const Color(0xFFF5F7FB),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 44,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 18),
                children: ['All', 'Pending', 'Submitted'].map((filter) {
                  final selected = _filter == filter;

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
                        setState(() => _filter = filter);
                      },
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: assignments.isEmpty
                  ? const Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.assignment_outlined,
                            size: 56,
                            color: Colors.blueGrey,
                          ),
                          SizedBox(height: 12),
                          Text(
                            'No assignments found',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 17,
                            ),
                          ),
                          SizedBox(height: 6),
                          Text(
                            'Try another search or filter.',
                            style: TextStyle(color: Colors.blueGrey),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.fromLTRB(18, 4, 18, 24),
                      itemCount: assignments.length,
                      itemBuilder: (context, index) {
                        final assignment = assignments[index];

                        return _AssignmentCard(
                          assignment: assignment,
                          onTap: () => _showDetails(assignment),
                        );
                      },
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

    if (index == 3) return;

    context.go(routes[index]);
  }

  void _showDetails(Map<String, dynamic> assignment) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(24),
        ),
      ),
      builder: (sheetContext) {
        final submitted = assignment['status'] == 'Submitted';

        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 42,
                    height: 5,
                    decoration: BoxDecoration(
                      color: Colors.black12,
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  assignment['subject'],
                  style: const TextStyle(
                    color: Color(0xFF3456D1),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  assignment['title'],
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Instructions',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  assignment['description'],
                  style: const TextStyle(
                    height: 1.5,
                    color: Colors.blueGrey,
                  ),
                ),
                const SizedBox(height: 18),
                Row(
                  children: [
                    const Icon(Icons.calendar_month_outlined),
                    const SizedBox(width: 8),
                    Text('Due date: ${assignment['due']}'),
                  ],
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: submitted
                        ? null
                        : () {
                            setState(() {
                              assignment['status'] = 'Submitted';
                            });

                            Navigator.pop(sheetContext);

                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'Demo submission marked as submitted.',
                                ),
                              ),
                            );
                          },
                    icon: Icon(
                      submitted ? Icons.check_circle : Icons.upload_file,
                    ),
                    label: Text(
                      submitted ? 'Already Submitted' : 'Mark as Submitted',
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF3456D1),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 15),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Demo only: this status is not saved to Firebase.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.blueGrey,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({
    required this.label,
    required this.count,
    required this.color,
    required this.icon,
  });

  final String label;
  final int count;
  final Color color;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 21),
          const SizedBox(height: 10),
          Text(
            '$count',
            style: TextStyle(
              fontSize: 23,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: Colors.blueGrey,
            ),
          ),
        ],
      ),
    );
  }
}

class _AssignmentCard extends StatelessWidget {
  const _AssignmentCard({
    required this.assignment,
    required this.onTap,
  });

  final Map<String, dynamic> assignment;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final submitted = assignment['status'] == 'Submitted';
    final color = assignment['color'] as Color;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      color: Colors.white,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: const BorderSide(color: Color(0xFFE6EAF2)),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Row(
                children: [
                  Container(
                    width: 46,
                    height: 46,
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.10),
                      borderRadius: BorderRadius.circular(13),
                    ),
                    child: Icon(
                      assignment['icon'] as IconData,
                      color: color,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          assignment['title'],
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          assignment['subject'],
                          style: const TextStyle(
                            color: Colors.blueGrey,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Icon(
                    Icons.arrow_forward_ios,
                    size: 15,
                    color: Colors.blueGrey,
                  ),
                ],
              ),
              const SizedBox(height: 15),
              const Divider(height: 1),
              const SizedBox(height: 12),
              Row(
                children: [
                  const Icon(
                    Icons.calendar_today_outlined,
                    size: 15,
                    color: Colors.blueGrey,
                  ),
                  const SizedBox(width: 7),
                  Expanded(
                    child: Text(
                      'Due ${assignment['due']}',
                      style: const TextStyle(
                        color: Colors.blueGrey,
                        fontSize: 12,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: submitted
                          ? Colors.green.shade50
                          : Colors.orange.shade50,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      assignment['status'],
                      style: TextStyle(
                        color: submitted
                            ? Colors.green.shade700
                            : Colors.orange.shade800,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
