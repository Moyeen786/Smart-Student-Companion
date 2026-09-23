import 'package:flutter/material.dart';
import 'package:smart_student_companion/core/theme/app_colors.dart';
import 'package:smart_student_companion/features/admin/presentation/widgets/admin_widgets.dart';

class AdminSecondaryScreen extends StatelessWidget {
  const AdminSecondaryScreen({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
  });
  final String title, subtitle;
  final IconData icon;
  @override
  Widget build(BuildContext context) => AdminShell(
    title: title,
    child: ListView(
      padding: const EdgeInsets.fromLTRB(28, 26, 28, 36),
      children: [
        Row(
          children: [
            CircleAvatar(
              radius: 25,
              backgroundColor: const Color(0xFFE4EFFB),
              child: Icon(icon, color: AppColors.primary),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: const TextStyle(color: AppColors.textSecondary),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 28),
        AdminCard(
          child: Column(
            children: [
              const Icon(
                Icons.construction_outlined,
                size: 34,
                color: AppColors.primary,
              ),
              const SizedBox(height: 14),
              Text(
                '$title workspace',
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'This Admin workspace is ready for repository-backed records and Firebase integration.',
                textAlign: TextAlign.center,
                style: TextStyle(color: AppColors.textSecondary),
              ),
              const SizedBox(height: 18),
              FilledButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.add),
                label: Text('Create ${title.toLowerCase()} record'),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}
