
import 'package:flutter/material.dart';

class TeacherAttendance extends StatefulWidget {
  const TeacherAttendance({super.key});

  @override
  State<TeacherAttendance> createState() =>
      _TeacherAttendanceState();
}

class _TeacherAttendanceState extends State<TeacherAttendance> {
  DateTime selectedDate = DateTime.now();

  String department = 'CSE';
  String semester = '1';
  String section = 'D';
  String searchQuery = '';

  bool saved = false;

  final TextEditingController searchController =
      TextEditingController();

  final List<Map<String, dynamic>> students = [
    {
      'name': 'Student One',
      'roll': 'CSE001',
      'status': 'Present',
    },
    {
      'name': 'Student Two',
      'roll': 'CSE002',
      'status': 'Present',
    },
    {
      'name': 'Student Three',
      'roll': 'CSE003',
      'status': 'Present',
    },
    {
      'name': 'Student Four',
      'roll': 'CSE004',
      'status': 'Present',
    },
    {
      'name': 'Student Five',
      'roll': 'CSE005',
      'status': 'Present',
    },
    {
      'name': 'Student Six',
      'roll': 'CSE006',
      'status': 'Present',
    },
    {
      'name': 'Student Seven',
      'roll': 'CSE007',
      'status': 'Present',
    },
    {
      'name': 'Student Eight',
      'roll': 'CSE008',
      'status': 'Present',
    },
  ];

  int get presentCount => students
      .where((s) => s['status'] == 'Present')
      .length;

  int get absentCount => students
      .where((s) => s['status'] == 'Absent')
      .length;

  int get lateCount => students
      .where((s) => s['status'] == 'Late')
      .length;

  int get totalStudents => students.length;

  double get attendancePercentage {
    if (totalStudents == 0) return 0;

    return presentCount / totalStudents * 100;
  }

  List<Map<String, dynamic>> get filteredStudents {
    final query = searchQuery.trim().toLowerCase();

    return students.where((student) {
      final name =
          student['name'].toString().toLowerCase();
      final roll =
          student['roll'].toString().toLowerCase();

      return name.contains(query) || roll.contains(query);
    }).toList();
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  String formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/'
        '${date.year}';
  }

  void markStudent(
    Map<String, dynamic> student,
    String status,
  ) {
    setState(() {
      student['status'] = status;
      saved = false;
    });
  }

  void markAllPresent() {
    setState(() {
      for (final student in students) {
        student['status'] = 'Present';
      }
      saved = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('All students marked present'),
      ),
    );
  }

  Future<void> chooseDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );

    if (picked != null && mounted) {
      setState(() {
        selectedDate = picked;
        saved = false;
      });
    }
  }

  void saveAttendance() {
    setState(() {
      saved = true;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Attendance confirmed for this session.',
        ),
      ),
    );
  }

  void resetAttendance() {
    setState(() {
      for (final student in students) {
        student['status'] = 'Present';
      }
      saved = false;
    });
  }

  Color statusColor(String status) {
    switch (status) {
      case 'Present':
        return Colors.green;
      case 'Absent':
        return Colors.red;
      case 'Late':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  Widget summaryCard(
    String title,
    int count,
    Color color,
    IconData icon,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 25),
            const SizedBox(height: 10),
            Text(
              '$count',
              style: const TextStyle(
                fontSize: 23,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              title,
              style: const TextStyle(fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildStudentCard(
    Map<String, dynamic> student,
  ) {
    final status = student['status'] as String;
    final color = statusColor(status);

    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: color.withAlpha(25),
                  child: Text(
                    student['name']
                        .toString()
                        .substring(0, 1),
                    style: TextStyle(
                      color: color,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      Text(
                        student['name'] as String,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 15,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Roll No: ${student['roll']}',
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                Chip(
                  label: Text(status),
                  backgroundColor: color.withAlpha(25),
                  side: BorderSide.none,
                  labelStyle: TextStyle(
                    color: color,
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: statusButton(
                    'Present',
                    Icons.check_circle_outline,
                    student,
                  ),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: statusButton(
                    'Absent',
                    Icons.cancel_outlined,
                    student,
                  ),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: statusButton(
                    'Late',
                    Icons.schedule,
                    student,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget statusButton(
    String status,
    IconData icon,
    Map<String, dynamic> student,
  ) {
    final selected = student['status'] == status;
    final color = statusColor(status);

    return OutlinedButton(
      onPressed: () => markStudent(student, status),
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(
          vertical: 10,
          horizontal: 4,
        ),
        backgroundColor:
            selected ? color.withAlpha(25) : null,
        foregroundColor: color,
        side: BorderSide(
          color: selected ? color : Colors.grey.shade300,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 17),
          const SizedBox(height: 4),
          Text(
            status,
            style: const TextStyle(fontSize: 11),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final visibleStudents = filteredStudents;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Attendance'),
        actions: [
          IconButton(
            tooltip: 'Reset attendance',
            onPressed: resetAttendance,
            icon: const Icon(Icons.restart_alt),
          ),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text(
              'Manage Attendance',
              style: Theme.of(context)
                  .textTheme
                  .headlineSmall
                  ?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 6),
            Text(
              'Select your class and record student attendance.',
              style: TextStyle(
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 20),

            // Class selection
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Class Details',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 14),
                    DropdownButtonFormField<String>(
                      value: department,
                      decoration: const InputDecoration(
                        labelText: 'Department',
                        border: OutlineInputBorder(),
                      ),
                      items: const [
                        DropdownMenuItem(
                          value: 'CSE',
                          child: Text('CSE'),
                        ),
                        DropdownMenuItem(
                          value: 'ECE',
                          child: Text('ECE'),
                        ),
                        DropdownMenuItem(
                          value: 'EEE',
                          child: Text('EEE'),
                        ),
                        DropdownMenuItem(
                          value: 'IT',
                          child: Text('IT'),
                        ),
                      ],
                      onChanged: (value) {
                        if (value != null) {
                          setState(() {
                            department = value;
                            saved = false;
                          });
                        }
                      },
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child:
                              DropdownButtonFormField<String>(
                            value: semester,
                            decoration:
                                const InputDecoration(
                              labelText: 'Semester',
                              border: OutlineInputBorder(),
                            ),
                            items: List.generate(
                              8,
                              (index) => DropdownMenuItem(
                                value: '${index + 1}',
                                child: Text(
                                  'Semester ${index + 1}',
                                ),
                              ),
                            ),
                            onChanged: (value) {
                              if (value != null) {
                                setState(() {
                                  semester = value;
                                  saved = false;
                                });
                              }
                            },
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child:
                              DropdownButtonFormField<String>(
                            value: section,
                            decoration:
                                const InputDecoration(
                              labelText: 'Section',
                              border: OutlineInputBorder(),
                            ),
                            items: const [
                              DropdownMenuItem(
                                value: 'A',
                                child: Text('Section A'),
                              ),
                              DropdownMenuItem(
                                value: 'B',
                                child: Text('Section B'),
                              ),
                              DropdownMenuItem(
                                value: 'C',
                                child: Text('Section C'),
                              ),
                              DropdownMenuItem(
                                value: 'D',
                                child: Text('Section D'),
                              ),
                            ],
                            onChanged: (value) {
                              if (value != null) {
                                setState(() {
                                  section = value;
                                  saved = false;
                                });
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: const Icon(
                        Icons.calendar_month,
                      ),
                      title: const Text('Attendance Date'),
                      subtitle: Text(
                        formatDate(selectedDate),
                      ),
                      trailing: const Icon(
                        Icons.edit_calendar,
                      ),
                      onTap: chooseDate,
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Attendance percentage
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Attendance Overview',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment:
                          MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Present percentage'),
                        Text(
                          '${attendancePercentage.toStringAsFixed(1)}%',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    LinearProgressIndicator(
                      value: attendancePercentage / 100,
                      minHeight: 9,
                      borderRadius: BorderRadius.circular(8),
                      color: Colors.green,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      '$presentCount of $totalStudents students marked present',
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 12),

            // Summary cards
            Row(
              children: [
                Expanded(
                  child: summaryCard(
                    'Total',
                    totalStudents,
                    Colors.blue,
                    Icons.groups_outlined,
                  ),
                ),
                Expanded(
                  child: summaryCard(
                    'Present',
                    presentCount,
                    Colors.green,
                    Icons.check_circle_outline,
                  ),
                ),
                Expanded(
                  child: summaryCard(
                    'Absent',
                    absentCount,
                    Colors.red,
                    Icons.cancel_outlined,
                  ),
                ),
                Expanded(
                  child: summaryCard(
                    'Late',
                    lateCount,
                    Colors.orange,
                    Icons.schedule,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // Student list heading
            Row(
              children: [
                const Expanded(
                  child: Text(
                    'Student List',
                    style: TextStyle(
                      fontSize: 19,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                TextButton(
                  onPressed: markAllPresent,
                  child: const Text('Mark All Present'),
                ),
              ],
            ),
            const SizedBox(height: 8),

            // Search
            TextField(
              controller: searchController,
              decoration: InputDecoration(
                hintText: 'Search name or roll number',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: IconButton(
                  onPressed: () {
                    searchController.clear();
                    setState(() {
                      searchQuery = '';
                    });
                  },
                  icon: const Icon(Icons.clear),
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onChanged: (value) {
                setState(() {
                  searchQuery = value;
                });
              },
            ),

            const SizedBox(height: 14),

            if (visibleStudents.isEmpty)
              const Padding(
                padding: EdgeInsets.all(24),
                child: Center(
                  child: Text('No students found.'),
                ),
              )
            else
              ...visibleStudents.map(buildStudentCard),

            const SizedBox(height: 12),

            // Save button
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: saveAttendance,
                icon: Icon(
                  saved
                      ? Icons.check_circle
                      : Icons.save_outlined,
                ),
                label: Text(
                  saved
                      ? 'Attendance Confirmed'
                      : 'Save Attendance',
                ),
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    vertical: 16,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
