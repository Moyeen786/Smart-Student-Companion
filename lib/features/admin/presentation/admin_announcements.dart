import 'package:flutter/material.dart';

class AdminAnnouncements extends StatelessWidget {
  const AdminAnnouncements({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Announcements')),
      body: const Center(child: Text('Administrative announcements')),
    );
  }
}
