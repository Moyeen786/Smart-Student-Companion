import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:smart_student_companion/app/app_providers.dart';
import 'package:smart_student_companion/core/theme/app_colors.dart';
import 'package:smart_student_companion/features/admin/presentation/widgets/admin_widgets.dart';

class AdminProfile extends ConsumerWidget {
  const AdminProfile({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authStateProvider).valueOrNull?.user;
    final name = user?.name.isNotEmpty == true ? user!.name : 'Administrator';
    final email = user?.email.isNotEmpty == true
        ? user!.email
        : 'No email available';
    final initials = name
        .split(RegExp(r'\s+'))
        .where((part) => part.isNotEmpty)
        .take(2)
        .map((part) => part[0].toUpperCase())
        .join();

    return AdminShell(
      title: 'Admin Profile',
      child: ListView(
        padding: const EdgeInsets.fromLTRB(28, 26, 28, 36),
        children: [
          const Text(
            'Admin profile',
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Manage your administrator account and preferences.',
            style: TextStyle(color: AppColors.textSecondary),
          ),
          const SizedBox(height: 24),
          AdminCard(
            child: Row(
              children: [
                CircleAvatar(
                  radius: 34,
                  backgroundColor: const Color(0xFFDCEBFA),
                  child: Text(
                    initials.isEmpty ? 'A' : initials,
                    style: const TextStyle(
                      color: AppColors.primary,
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                const SizedBox(width: 18),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        style: const TextStyle(
                          fontSize: 19,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        email,
                        style: const TextStyle(color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                ),
                OutlinedButton.icon(
                  onPressed: () => _showUnavailable(context, 'Edit profile'),
                  icon: const Icon(Icons.edit_outlined, size: 17),
                  label: const Text('Edit profile'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          AdminCard(
            child: Column(
              children: [
                _detail('Administrator ID', user?.uid ?? 'Not available'),
                _detail('Department', user?.department ?? 'Not available'),
                _detail('Role', 'Administrator'),
                _detail('Account email', email),
              ],
            ),
          ),
          const SizedBox(height: 18),
          AdminCard(
            padding: EdgeInsets.zero,
            child: Column(
              children: [
                _action(
                  context,
                  Icons.lock_outline,
                  'Change password',
                  () => _showUnavailable(context, 'Change password'),
                ),
                const Divider(height: 1),
                _action(context, Icons.logout_rounded, 'Log out', () async {
                  await ref.read(authStateProvider.notifier).logout();
                  if (context.mounted) context.go('/login');
                }),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _detail(String label, String value) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 13),
    child: Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 13,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            textAlign: TextAlign.right,
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
          ),
        ),
      ],
    ),
  );

  Widget _action(
    BuildContext context,
    IconData icon,
    String label,
    VoidCallback onPressed,
  ) => ListTile(
    leading: Icon(icon, color: AppColors.primary),
    title: Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
    trailing: const Icon(Icons.chevron_right, color: AppColors.muted),
    onTap: onPressed,
  );

  void _showUnavailable(BuildContext context, String feature) =>
      showDialog<void>(
        context: context,
        builder: (dialogContext) => AlertDialog(
          title: Text(feature),
          content: Text('$feature is ready for Firebase integration.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Close'),
            ),
          ],
        ),
      );
}
