import 'package:flutter/material.dart';

class TeacherAttendance extends StatelessWidget {
  const TeacherAttendance({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Attendance')),
      body: const Center(child: Text('Faculty attendance management')),
    );
  }
}
