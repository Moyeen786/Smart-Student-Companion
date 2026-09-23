import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:smart_student_companion/core/theme/app_colors.dart';
import 'package:smart_student_companion/features/admin/domain/models/admin_models.dart';
import 'package:smart_student_companion/features/admin/presentation/widgets/admin_widgets.dart';
import 'package:smart_student_companion/features/admin/providers/admin_providers.dart';

class AdminAnnouncements extends ConsumerWidget {
  const AdminAnnouncements({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(adminAnnouncementsProvider);
    return AdminShell(
      title: 'Announcements & Circulars',
      child: state.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, _) => Center(
          child: OutlinedButton(
            onPressed: () => ref.invalidate(adminAnnouncementsProvider),
            child: const Text('Try again'),
          ),
        ),
        data: (items) => _content(context, items),
      ),
    );
  }

  Widget _content(BuildContext context, List<Announcement> announcements) =>
      ListView(
        padding: const EdgeInsets.fromLTRB(28, 26, 28, 36),
        children: [
          Row(
            children: [
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Announcements & circulars',
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    SizedBox(height: 6),
                    Text(
                      'Keep your institution informed with timely updates.',
                      style: TextStyle(color: AppColors.textSecondary),
                    ),
                  ],
                ),
              ),
              FilledButton.icon(
                onPressed: () => context.go('/admin/announcements/create'),
                icon: const Icon(Icons.add, size: 18),
                label: const Text('Create announcement'),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Wrap(
            spacing: 8,
            children: ['All', 'Published', 'Scheduled', 'Drafts', 'Archived']
                .map(
                  (label) => ChoiceChip(
                    label: Text(label),
                    selected: label == 'All',
                    onSelected: (_) {},
                  ),
                )
                .toList(),
          ),
          const SizedBox(height: 16),
          if (announcements.isEmpty)
            const AdminCard(
              child: Text(
                'No announcements yet. Create your first announcement to communicate with the institution.',
                style: TextStyle(color: AppColors.textSecondary),
              ),
            )
          else
            ...announcements.map(
              (a) => AdminCard(
                child: Row(
                  children: [
                    Container(
                      width: 4,
                      height: 58,
                      decoration: BoxDecoration(
                        color: a.status.color,
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ),
                    const SizedBox(width: 15),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            a.title,
                            style: const TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 7),
                          Text(
                            '${a.category}  |  ${a.audience}',
                            style: const TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 12,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            a.date,
                            style: const TextStyle(
                              color: AppColors.muted,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ),
                    StatusBadge(status: a.status),
                    PopupMenuButton<String>(
                      onSelected: (_) {},
                      itemBuilder: (_) => const [
                        PopupMenuItem(value: 'edit', child: Text('Edit')),
                        PopupMenuItem(value: 'archive', child: Text('Archive')),
                      ],
                    ),
                  ],
                ),
              ),
            ),
        ],
      );
}
