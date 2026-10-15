import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class StudentNotes extends StatefulWidget {
  const StudentNotes({super.key});

  @override
  State<StudentNotes> createState() => _StudentNotesState();
}

class _StudentNotesState extends State<StudentNotes> {
  final TextEditingController _searchController = TextEditingController();

  String _selectedSubject = 'All';

  final List<Map<String, dynamic>> _notes = [
    {
      'title': 'TCP and UDP Protocols',
      'subject': 'Computer Networks',
      'description':
          'Study the differences between TCP and UDP, connection establishment, reliability, ports, and common applications.',
      'type': 'Study Notes',
      'date': '12 Oct 2026',
      'icon': Icons.lan_outlined,
      'color': Colors.blue,
    },
    {
      'title': 'CPU Scheduling Algorithms',
      'subject': 'Operating Systems',
      'description':
          'Revision notes on FCFS, SJF, Round Robin, and Priority Scheduling, including waiting time and turnaround time.',
      'type': 'Revision',
      'date': '10 Oct 2026',
      'icon': Icons.computer_outlined,
      'color': Colors.deepPurple,
    },
    {
      'title': 'Quick Sort and Merge Sort',
      'subject': 'Design and Analysis of Algorithms',
      'description':
          'Review divide and conquer, partitioning, recurrence relations, and sorting time complexities.',
      'type': 'Study Notes',
      'date': '08 Oct 2026',
      'icon': Icons.code_outlined,
      'color': Colors.teal,
    },
    {
      'title': 'SQL Queries',
      'subject': 'Database Management Systems',
      'description':
          'Practice SELECT, WHERE, GROUP BY, JOIN, aggregate functions, and nested queries.',
      'type': 'Practice',
      'date': '06 Oct 2026',
      'icon': Icons.storage_outlined,
      'color': Colors.orange,
    },
    {
      'title': 'Haskell Recursion',
      'subject': 'Programming Paradigms',
      'description':
          'Review recursion, pattern matching, list comprehensions, and recursive function examples.',
      'type': 'Revision',
      'date': '04 Oct 2026',
      'icon': Icons.functions_outlined,
      'color': Colors.pink,
    },
  ];

  List<String> get _subjects {
    final subjects = _notes
        .map((note) => note['subject'] as String)
        .toSet()
        .toList();

    return ['All', ...subjects];
  }

  List<Map<String, dynamic>> get _filteredNotes {
    final query = _searchController.text.trim().toLowerCase();

    return _notes.where((note) {
      final matchesSearch =
          note['title'].toString().toLowerCase().contains(query) ||
          note['subject'].toString().toLowerCase().contains(query) ||
          note['type'].toString().toLowerCase().contains(query);

      final matchesSubject =
          _selectedSubject == 'All' || note['subject'] == _selectedSubject;

      return matchesSearch && matchesSubject;
    }).toList();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final notes = _filteredNotes;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FB),
      appBar: AppBar(
        title: const Text(
          'My Notes',
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
        selectedIndex: 4,
        onDestinationSelected: _navigate,
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home_outlined), label: 'Home'),
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
            selectedIcon: Icon(Icons.note_alt),
            label: 'Notes',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            label: 'Profile',
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddNoteDialog,
        icon: const Icon(Icons.add),
        label: const Text('Add Note'),
        backgroundColor: const Color(0xFF3456D1),
        foregroundColor: Colors.white,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(18, 12, 18, 18),
              color: Colors.white,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Your learning space',
                    style: TextStyle(fontSize: 14, color: Colors.blueGrey),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: _NotesSummaryCard(
                          title: 'Total notes',
                          value: '${_notes.length}',
                          icon: Icons.menu_book_outlined,
                          color: Colors.blue,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _NotesSummaryCard(
                          title: 'Subjects',
                          value: '${_subjects.length - 1}',
                          icon: Icons.school_outlined,
                          color: Colors.deepPurple,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  TextField(
                    controller: _searchController,
                    onChanged: (_) => setState(() {}),
                    decoration: InputDecoration(
                      hintText: 'Search your notes...',
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
            const SizedBox(height: 14),
            SizedBox(
              height: 42,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 18),
                children: _subjects.map((subject) {
                  final selected = _selectedSubject == subject;

                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: Text(subject),
                      selected: selected,
                      showCheckmark: false,
                      selectedColor: const Color(0xFF3456D1),
                      backgroundColor: Colors.white,
                      labelStyle: TextStyle(
                        color: selected ? Colors.white : Colors.black87,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                      onSelected: (_) {
                        setState(() => _selectedSubject = subject);
                      },
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: notes.isEmpty
                  ? const Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.note_alt_outlined,
                            size: 56,
                            color: Colors.blueGrey,
                          ),
                          SizedBox(height: 12),
                          Text(
                            'No notes found',
                            style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 6),
                          Text(
                            'Try a different search or subject.',
                            style: TextStyle(color: Colors.blueGrey),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.fromLTRB(18, 4, 18, 100),
                      itemCount: notes.length,
                      itemBuilder: (context, index) {
                        final note = notes[index];

                        return _NoteCard(
                          note: note,
                          onTap: () => _showNoteDetails(note),
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

    if (index == 4) return;

    if (index == routes.length - 1) {
      context.push(routes[index]);
    } else {
      context.go(routes[index]);
    }
  }

  void _showNoteDetails(Map<String, dynamic> note) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetContext) {
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
                  note['subject'],
                  style: const TextStyle(
                    color: Color(0xFF3456D1),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  note['title'],
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    _Tag(label: note['type']),
                    const SizedBox(width: 8),
                    Text(
                      note['date'],
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.blueGrey,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Text(note['description'], style: const TextStyle(height: 1.6)),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () => Navigator.pop(sheetContext),
                    icon: const Icon(Icons.check),
                    label: const Text('Done'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showAddNoteDialog() {
    final titleController = TextEditingController();
    final descriptionController = TextEditingController();

    String subject = _subjects.length > 1 ? _subjects[1] : 'General';

    showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('Create a note'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: titleController,
                      decoration: const InputDecoration(
                        labelText: 'Note title',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 14),
                    DropdownButtonFormField<String>(
                      value: subject,
                      isExpanded: true,
                      decoration: const InputDecoration(
                        labelText: 'Subject',
                        border: OutlineInputBorder(),
                      ),
                      items: _subjects
                          .where((s) => s != 'All')
                          .map(
                            (s) => DropdownMenuItem(
                              value: s,
                              child: Text(s, overflow: TextOverflow.ellipsis),
                            ),
                          )
                          .toList(),
                      onChanged: (value) {
                        if (value != null) {
                          setDialogState(() => subject = value);
                        }
                      },
                    ),
                    const SizedBox(height: 14),
                    TextField(
                      controller: descriptionController,
                      maxLines: 4,
                      decoration: const InputDecoration(
                        labelText: 'Note content',
                        alignLabelWithHint: true,
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () {
                    final title = titleController.text.trim();
                    final description = descriptionController.text.trim();

                    if (title.isEmpty || description.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Enter a title and note content.'),
                        ),
                      );
                      return;
                    }

                    setState(() {
                      _notes.insert(0, {
                        'title': title,
                        'subject': subject,
                        'description': description,
                        'type': 'Personal Note',
                        'date': '12 Oct 2026',
                        'icon': Icons.note_alt_outlined,
                        'color': Colors.indigo,
                      });

                      _selectedSubject = 'All';
                      _searchController.clear();
                    });

                    Navigator.pop(dialogContext);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Note created successfully.'),
                      ),
                    );
                  },
                  child: const Text('Save'),
                ),
              ],
            );
          },
        );
      },
    ).then((_) {
      titleController.dispose();
      descriptionController.dispose();
    });
  }
}

class _NotesSummaryCard extends StatelessWidget {
  const _NotesSummaryCard({
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
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 26),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
                Text(
                  title,
                  style: const TextStyle(fontSize: 11, color: Colors.blueGrey),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _NoteCard extends StatelessWidget {
  const _NoteCard({required this.note, required this.onTap});

  final Map<String, dynamic> note;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = note['color'] as Color;

    return Card(
      color: Colors.white,
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: const BorderSide(color: Color(0xFFE6EAF2)),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(note['icon'] as IconData, color: color),
              ),
              const SizedBox(width: 13),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      note['title'],
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      note['subject'],
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.blueGrey,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      note['description'],
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 12,
                        height: 1.4,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        _Tag(label: note['type']),
                        const Spacer(),
                        Text(
                          note['date'],
                          style: const TextStyle(
                            color: Colors.blueGrey,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 6),
              const Icon(Icons.chevron_right, color: Colors.blueGrey),
            ],
          ),
        ),
      ),
    );
  }
}

class _Tag extends StatelessWidget {
  const _Tag({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: const Color(0xFFEAF0FF),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: Color(0xFF3456D1),
          fontSize: 10,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
