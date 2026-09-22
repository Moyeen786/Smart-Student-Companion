import 'package:flutter/material.dart';

class StudentTimetable extends StatelessWidget {
  const StudentTimetable({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Timetable')),
      body: const Center(child: Text('Weekly class timetable')),
    );
  }
}
