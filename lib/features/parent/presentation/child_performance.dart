import 'package:flutter/material.dart';

class ChildPerformance extends StatelessWidget {
  const ChildPerformance({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Performance')),
      body: const Center(child: Text('Parent academic performance summary')),
    );
  }
}
