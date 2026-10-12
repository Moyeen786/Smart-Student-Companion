
import 'package:flutter/material.dart';

class TeacherAssignments extends StatefulWidget {
  const TeacherAssignments({super.key});

  @override
  State<TeacherAssignments> createState() =>
      _TeacherAssignmentsState();
}

class _TeacherAssignmentsState extends State<TeacherAssignments> {
  final List<Map<String, dynamic>> _assignments = [];

  Future<void> _createAssignment() async {
    final formKey = GlobalKey<FormState>();

    final titleController = TextEditingController();
    final subjectController = TextEditingController();
    final departmentController = TextEditingController();
    final sectionController = TextEditingController();
    final marksController = TextEditingController();

    DateTime dueDate = DateTime.now().add(
      const Duration(days: 7),
    );

    String assignmentType = 'Homework';

    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('Create Assignment'),
              content: SingleChildScrollView(
                child: Form(
                  key: formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextFormField(
                        controller: titleController,
                        decoration: const InputDecoration(
                          labelText: 'Assignment title',
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null ||
                              value.trim().isEmpty) {
                            return 'Enter assignment title';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: subjectController,
                        decoration: const InputDecoration(
                          labelText: 'Subject',
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null ||
                              value.trim().isEmpty) {
                            return 'Enter subject';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 12),
                      DropdownButtonFormField<String>(
                        value: assignmentType,
                        decoration: const InputDecoration(
                          labelText: 'Assignment type',
                          border: OutlineInputBorder(),
                        ),
                        items: const [
                          DropdownMenuItem(
                            value: 'Homework',
                            child: Text('Homework'),
                          ),
                          DropdownMenuItem(
                            value: 'Project',
                            child: Text('Project'),
                          ),
                          DropdownMenuItem(
                            value: 'Quiz',
                            child: Text('Quiz'),
                          ),
                          DropdownMenuItem(
                            value: 'Lab',
                            child: Text('Lab'),
                          ),
                        ],
                        onChanged: (value) {
                          if (value != null) {
                            setDialogState(() {
                              assignmentType = value;
                            });
                          }
                        },
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: departmentController,
                        decoration: const InputDecoration(
                          labelText: 'Department',
                          hintText: 'e.g. CSE',
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null ||
                              value.trim().isEmpty) {
                            return 'Enter department';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: sectionController,
                        decoration: const InputDecoration(
                          labelText: 'Section (optional)',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: marksController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Maximum marks',
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          final marks = int.tryParse(
                            value?.trim() ?? '',
                          );

                          if (marks == null || marks <= 0) {
                            return 'Enter valid maximum marks';
                          }

                          return null;
                        },
                      ),
                      const SizedBox(height: 12),
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: const Icon(Icons.event),
                        title: const Text('Due date'),
                        subtitle: Text(
                          '${dueDate.day}/${dueDate.month}/${dueDate.year}',
                        ),
                        trailing: const Icon(
                          Icons.calendar_month,
                        ),
                        onTap: () async {
                          final selected =
                              await showDatePicker(
                            context: dialogContext,
                            initialDate: dueDate,
                            firstDate: DateTime.now(),
                            lastDate: DateTime.now().add(
                              const Duration(days: 365 * 3),
                            ),
                          );

                          if (selected != null) {
                            setDialogState(() {
                              dueDate = selected;
                            });
                          }
                        },
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(dialogContext);
                  },
                  child: const Text('Cancel'),
                ),
                FilledButton(
                  onPressed: () {
                    if (!formKey.currentState!.validate()) {
                      return;
                    }

                    Navigator.pop(
                      dialogContext,
                      {
                        'title': titleController.text.trim(),
                        'subject': subjectController.text.trim(),
                        'type': assignmentType,
                        'department':
                            departmentController.text.trim(),
                        'section': sectionController.text.trim(),
                        'marks': int.parse(
                          marksController.text.trim(),
                        ),
                        'dueDate': dueDate,
                        'status': 'Scheduled',
                      },
                    );
                  },
                  child: const Text('Create'),
                ),
              ],
            );
          },
        );
      },
    );

    titleController.dispose();
    subjectController.dispose();
    departmentController.dispose();
    sectionController.dispose();
    marksController.dispose();

    if (!mounted || result == null) return;

    setState(() {
      _assignments.insert(0, result);
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Assignment created successfully'),
      ),
    );
  }

  void _refreshAssignments() {
    setState(() {});

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Assignment list refreshed'),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Assignments'),
        actions: [
          IconButton(
            tooltip: 'Refresh assignments',
            onPressed: _refreshAssignments,
            icon: const Icon(Icons.refresh_rounded),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _createAssignment,
        icon: const Icon(Icons.add_rounded),
        label: const Text('Create Assignment'),
      ),
      body: _assignments.isEmpty
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.assignment_outlined,
                      size: 72,
                      color: Theme.of(context)
                          .colorScheme
                          .primary,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'No assignments yet',
                      style: Theme.of(context)
                          .textTheme
                          .titleLarge,
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Create an assignment to share it with your class.',
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 20),
                    FilledButton.icon(
                      onPressed: _createAssignment,
                      icon: const Icon(Icons.add),
                      label: const Text('Create Assignment'),
                    ),
                  ],
                ),
              ),
            )
          : ListView.separated(
              padding: const EdgeInsets.fromLTRB(
                16,
                16,
                16,
                100,
              ),
              itemCount: _assignments.length,
              separatorBuilder: (_, __) =>
                  const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final assignment = _assignments[index];
                final dueDate =
                    assignment['dueDate'] as DateTime;

                return Card(
                  elevation: 1,
                  clipBehavior: Clip.antiAlias,
                  child: InkWell(
                    onTap: () {
                      showDialog<void>(
                        context: context,
                        builder: (dialogContext) {
                          return AlertDialog(
                            title: Text(
                              assignment['title'] as String,
                            ),
                            content: Text(
                              'Subject: ${assignment['subject']}\n'
                              'Type: ${assignment['type']}\n'
                              'Department: ${assignment['department']}\n'
                              'Section: ${assignment['section'].toString().isEmpty ? 'All sections' : assignment['section']}\n'
                              'Maximum marks: ${assignment['marks']}\n'
                              'Due date: ${_formatDate(dueDate)}\n'
                              'Status: ${assignment['status']}',
                            ),
                            actions: [
                              TextButton(
                                onPressed: () {
                                  Navigator.pop(dialogContext);
                                },
                                child: const Text('Close'),
                              ),
                            ],
                          );
                        },
                      );
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment:
                            CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(
                                Icons.assignment_outlined,
                                size: 28,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  assignment['title'] as String,
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleMedium
                                      ?.copyWith(
                                        fontWeight:
                                            FontWeight.bold,
                                      ),
                                ),
                              ),
                              const Icon(
                                Icons.chevron_right_rounded,
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Text(
                            '${assignment['subject']} • ${assignment['type']}',
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Department: ${assignment['department']}',
                          ),
                          Text(
                            'Section: ${assignment['section'].toString().isEmpty ? 'All sections' : assignment['section']}',
                          ),
                          Text(
                            'Due: ${_formatDate(dueDate)}',
                          ),
                          Text(
                            'Maximum marks: ${assignment['marks']}',
                          ),
                          const SizedBox(height: 10),
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Chip(
                              label: Text(
                                assignment['status'] as String,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }
}
