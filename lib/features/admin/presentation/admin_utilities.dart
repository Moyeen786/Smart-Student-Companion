import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:smart_student_companion/core/theme/app_colors.dart';
import 'package:smart_student_companion/features/admin/presentation/widgets/admin_widgets.dart';

class AdminUtilities extends StatelessWidget {
  const AdminUtilities({super.key});
  @override
  Widget build(BuildContext context) => AdminShell(
    title: 'Campus Services',
    child: ListView(
      padding: const EdgeInsets.fromLTRB(28, 26, 28, 36),
      children: [
        const Text(
          'Campus services',
          style: TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.w800,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 6),
        const Text(
          'Operational tools for the services your campus depends on.',
          style: TextStyle(color: AppColors.textSecondary),
        ),
        const SizedBox(height: 26),
        GridView.count(
          crossAxisCount: MediaQuery.sizeOf(context).width > 1050 ? 4 : 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 1.18,
          children: [
            _service(
              context,
              'Library',
              'Books, circulation and notices',
              Icons.menu_book_outlined,
              '/admin/utilities/library',
              AppColors.primary,
            ),
            _service(
              context,
              'Placements',
              'Drives, companies and outcomes',
              Icons.work_outline_rounded,
              '/admin/utilities/placements',
              const Color(0xFF1F7A52),
            ),
            _service(
              context,
              'Events',
              'Publish and manage campus events',
              Icons.event_outlined,
              '/admin/utilities/events',
              const Color(0xFF6B4FA1),
            ),
            _service(
              context,
              'Lost & Found',
              'Review and resolve reported items',
              Icons.inventory_2_outlined,
              '/admin/utilities/lost-found',
              const Color(0xFFB26A00),
            ),
          ],
        ),
      ],
    ),
  );
  Widget _service(
    BuildContext context,
    String title,
    String description,
    IconData icon,
    String route,
    Color color,
  ) => InkWell(
    onTap: () => context.go(route),
    borderRadius: BorderRadius.circular(12),
    child: AdminCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 22,
            backgroundColor: color.withValues(alpha: .1),
            child: Icon(icon, color: color),
          ),
          const Spacer(),
          Text(
            title,
            style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 7),
          Text(
            description,
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Text(
                'Open service',
                style: TextStyle(
                  color: color,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const Spacer(),
              Icon(Icons.arrow_forward_rounded, size: 17, color: color),
            ],
          ),
        ],
      ),
    ),
  );
}
