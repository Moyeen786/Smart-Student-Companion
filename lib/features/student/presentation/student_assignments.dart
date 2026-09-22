import 'package:flutter/material.dart';

class StudentAssignments extends StatelessWidget {
  const StudentAssignments({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Assignments')),
      body: const Center(child: Text('Student assignment list')),
    );
  }
}
