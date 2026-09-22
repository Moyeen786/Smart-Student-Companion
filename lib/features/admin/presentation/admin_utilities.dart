import 'package:flutter/material.dart';

class AdminUtilities extends StatelessWidget {
  const AdminUtilities({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Campus Utilities')),
      body: const Center(
        child: Text('Library, placements, events, lost & found placeholders'),
      ),
    );
  }
}
