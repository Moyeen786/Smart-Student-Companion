import 'package:flutter/material.dart';

class TeacherLeaveRequests extends StatelessWidget {
  const TeacherLeaveRequests({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Leave Requests')),
      body: const Center(child: Text('Faculty leave request management')),
    );
  }
}
