import 'package:flutter/material.dart';

class AdminAnalytics extends StatelessWidget {
  const AdminAnalytics({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Analytics')),
      body: const Center(child: Text('Admin analytics overview')),
    );
  }
}
