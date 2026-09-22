import 'package:flutter/material.dart';

class StudentNotes extends StatelessWidget {
  const StudentNotes({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Notes')),
      body: const Center(
        child: Text('Subject notes and future AI study assistant'),
      ),
    );
  }
}
