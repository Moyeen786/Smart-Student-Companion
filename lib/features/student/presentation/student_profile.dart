
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class StudentProfile extends StatefulWidget {
  const StudentProfile({super.key});

  @override
  State<StudentProfile> createState() => _StudentProfileState();
}

class _StudentProfileState extends State<StudentProfile> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _nameController =
      TextEditingController(text: 'Student Name');
  final TextEditingController _emailController =
      TextEditingController(text: 'student@example.com');
  final TextEditingController _rollController =
      TextEditingController(text: 'CB. Sc. U4CSE24347');
  final TextEditingController _courseController =
      TextEditingController(text: 'Computer Science and Engineering');
  final TextEditingController _yearController =
      TextEditingController(text: '1st Year');

  bool _isEditing = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _rollController.dispose();
    _courseController.dispose();
    _yearController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final name = _nameController.text.trim().isEmpty
        ? 'Student Name'
        : _nameController.text.trim();

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FB),
      appBar: AppBar(
        title: const Text(
          'My Profile',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          TextButton.icon(
            onPressed: () {
              if (_isEditing) {
                _saveProfile();
              } else {
                setState(() => _isEditing = true);
              }
            },
            icon: Icon(_isEditing ? Icons.check : Icons.edit_outlined),
            label: Text(_isEditing ? 'Save' : 'Edit'),
          ),
          const SizedBox(width: 8),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: 5,
        onDestinationSelected: _navigate,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.fact_check_outlined),
            label: 'Attendance',
          ),
          NavigationDestination(
            icon: Icon(Icons.calendar_month_outlined),
            label: 'Timetable',
          ),
          NavigationDestination(
            icon: Icon(Icons.assignment_outlined),
            label: 'Assignments',
          ),
          NavigationDestination(
            icon: Icon(Icons.note_alt_outlined),
            label: 'Notes',
          ),
          NavigationDestination(
            icon: Icon(Icons.person),
            selectedIcon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(18, 18, 18, 28),
          children: [
            _buildProfileHeader(name),
            const SizedBox(height: 22),
            _buildSectionTitle('Personal Information'),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(18),
              decoration: _cardDecoration(),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    _buildField(
                      label: 'Full Name',
                      controller: _nameController,
                      icon: Icons.person_outline,
                    ),
                    const SizedBox(height: 16),
                    _buildField(
                      label: 'Email Address',
                      controller: _emailController,
                      icon: Icons.email_outlined,
                      keyboardType: TextInputType.emailAddress,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter your email';
                        }
                        if (!value.contains('@') ||
                            !value.contains('.')) {
                          return 'Please enter a valid email';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    _buildField(
                      label: 'Roll Number',
                      controller: _rollController,
                      icon: Icons.badge_outlined,
                    ),
                    const SizedBox(height: 16),
                    _buildField(
                      label: 'Course',
                      controller: _courseController,
                      icon: Icons.school_outlined,
                    ),
                    const SizedBox(height: 16),
                    _buildField(
                      label: 'Academic Year',
                      controller: _yearController,
                      icon: Icons.calendar_today_outlined,
                    ),
                    if (_isEditing) ...[
                      const SizedBox(height: 20),
                      SizedBox(
                        width: double.infinity,
                        child: FilledButton.icon(
                          onPressed: _saveProfile,
                          icon: const Icon(Icons.save_outlined),
                          label: const Text('Save Changes'),
                          style: FilledButton.styleFrom(
                            backgroundColor: const Color(0xFF3456D1),
                            padding: const EdgeInsets.symmetric(
                              vertical: 14,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      SizedBox(
                        width: double.infinity,
                        child: TextButton(
                          onPressed: () {
                            setState(() => _isEditing = false);
                          },
                          child: const Text('Cancel Editing'),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            _buildSectionTitle('Academic Details'),
            const SizedBox(height: 12),
            Container(
              decoration: _cardDecoration(),
              child: Column(
                children: [
                  _buildInfoTile(
                    icon: Icons.school_outlined,
                    title: 'Department',
                    subtitle: 'Computer Science and Engineering',
                    color: Colors.blue,
                  ),
                  const Divider(height: 1, indent: 65),
                  _buildInfoTile(
                    icon: Icons.groups_outlined,
                    title: 'Section',
                    subtitle: 'CSE-D',
                    color: Colors.deepPurple,
                  ),
                  const Divider(height: 1, indent: 65),
                  _buildInfoTile(
                    icon: Icons.menu_book_outlined,
                    title: 'Learning Dashboard',
                    subtitle: 'View attendance, classes and assignments',
                    color: Colors.teal,
                    onTap: () => context.go('/student'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            _buildSectionTitle('Quick Navigation'),
            const SizedBox(height: 12),
            Container(
              decoration: _cardDecoration(),
              child: Column(
                children: [
                  _buildInfoTile(
                    icon: Icons.fact_check_outlined,
                    title: 'Attendance',
                    subtitle: 'Check attendance records',
                    color: Colors.green,
                    onTap: () => context.go('/student/attendance'),
                  ),
                  const Divider(height: 1, indent: 65),
                  _buildInfoTile(
                    icon: Icons.calendar_month_outlined,
                    title: 'Timetable',
                    subtitle: 'View your class schedule',
                    color: Colors.orange,
                    onTap: () => context.go('/student/timetable'),
                  ),
                  const Divider(height: 1, indent: 65),
                  _buildInfoTile(
                    icon: Icons.assignment_outlined,
                    title: 'Assignments',
                    subtitle: 'Review pending assignments',
                    color: Colors.indigo,
                    onTap: () => context.go('/student/assignments'),
                  ),
                  const Divider(height: 1, indent: 65),
                  _buildInfoTile(
                    icon: Icons.note_alt_outlined,
                    title: 'My Notes',
                    subtitle: 'Open your study notes',
                    color: Colors.pink,
                    onTap: () => context.go('/student/notes'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            _buildSectionTitle('App Settings'),
            const SizedBox(height: 12),
            Container(
              decoration: _cardDecoration(),
              child: Column(
                children: [
                  _buildInfoTile(
                    icon: Icons.notifications_outlined,
                    title: 'Notifications',
                    subtitle: 'Manage notification preferences',
                    color: Colors.blue,
                    onTap: _showComingSoon,
                  ),
                  const Divider(height: 1, indent: 65),
                  _buildInfoTile(
                    icon: Icons.lock_outline,
                    title: 'Privacy and Security',
                    subtitle: 'Account security options',
                    color: Colors.deepPurple,
                    onTap: _showComingSoon,
                  ),
                  const Divider(height: 1, indent: 65),
                  _buildInfoTile(
                    icon: Icons.info_outline,
                    title: 'About Student Companion',
                    subtitle: 'App information',
                    color: Colors.teal,
                    onTap: _showAbout,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 22),
            const Center(
              child: Text(
                'Smart Student Companion',
                style: TextStyle(
                  color: Colors.blueGrey,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(height: 5),
            const Center(
              child: Text(
                'Your learning, organized.',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.blueGrey,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader(String name) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFF3456D1),
            Color(0xFF647FEA),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(22),
      ),
      child: Column(
        children: [
          CircleAvatar(
            radius: 43,
            backgroundColor: Colors.white.withValues(alpha: 0.18),
            child: Text(
              name.isEmpty ? 'S' : name[0].toUpperCase(),
              style: const TextStyle(
                fontSize: 34,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(height: 14),
          Text(
            name,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 21,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            _emailController.text,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.85),
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 13,
              vertical: 7,
            ),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.17),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Text(
              'Student Account',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildField({
    required String label,
    required TextEditingController controller,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      enabled: _isEditing,
      keyboardType: keyboardType,
      validator: validator,
      onChanged: (_) => setState(() {}),
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        filled: true,
        fillColor: _isEditing
            ? const Color(0xFFF5F7FB)
            : const Color(0xFFFAFBFD),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(13),
          borderSide: const BorderSide(color: Color(0xFFE3E8F0)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(13),
          borderSide: const BorderSide(color: Color(0xFFE3E8F0)),
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(13),
          borderSide: const BorderSide(color: Color(0xFFE3E8F0)),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 17,
        fontWeight: FontWeight.bold,
        color: Color(0xFF202A44),
      ),
    );
  }

  Widget _buildInfoTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    VoidCallback? onTap,
  }) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 6,
      ),
      leading: Container(
        width: 43,
        height: 43,
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.10),
          borderRadius: BorderRadius.circular(13),
        ),
        child: Icon(icon, color: color),
      ),
      title: Text(
        title,
        style: const TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 14,
        ),
      ),
      subtitle: Padding(
        padding: const EdgeInsets.only(top: 4),
        child: Text(
          subtitle,
          style: const TextStyle(
            fontSize: 12,
            color: Colors.blueGrey,
          ),
        ),
      ),
      trailing: const Icon(
        Icons.chevron_right,
        color: Colors.blueGrey,
      ),
      onTap: onTap,
    );
  }

  BoxDecoration _cardDecoration() {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(18),
      border: Border.all(color: const Color(0xFFE6EAF2)),
    );
  }

  void _saveProfile() {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isEditing = false);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Profile updated for this session.'),
      ),
    );
  }

  void _navigate(int index) {
    const routes = [
      '/student',
      '/student/attendance',
      '/student/timetable',
      '/student/assignments',
      '/student/notes',
      '/student/profile',
    ];

    if (index == 5) return;

    context.go(routes[index]);
  }

  void _showComingSoon() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('This setting will be available in a future update.'),
      ),
    );
  }

  void _showAbout() {
    showAboutDialog(
      context: context,
      applicationName: 'Smart Student Companion',
      applicationVersion: '1.0.0',
      applicationLegalese: 'Student learning and organization app.',
    );
  }
}
