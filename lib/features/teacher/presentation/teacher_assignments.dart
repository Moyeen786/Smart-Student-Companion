import 'package:flutter/material.dart';

class TeacherAssignments extends StatelessWidget {
  const TeacherAssignments({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Assignments')),
      body: const Center(
        child: Text('Faculty assignment list and create assignment UI'),
      ),
    );
  }
}
