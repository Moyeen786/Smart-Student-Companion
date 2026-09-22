import 'package:flutter/material.dart';

class ChildAttendance extends StatelessWidget {
  const ChildAttendance({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Child Attendance')),
      body: const Center(
        child: Text('Parent can view student attendance only'),
      ),
    );
  }
}
