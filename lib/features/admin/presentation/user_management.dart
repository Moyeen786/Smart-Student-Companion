import 'package:flutter/material.dart';

class UserManagement extends StatelessWidget {
  const UserManagement({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('User Management')),
      body: const Center(child: Text('Admin user management workspace')),
    );
  }
}
