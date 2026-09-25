import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:smart_student_companion/core/theme/app_colors.dart';
import 'package:smart_student_companion/features/admin/domain/models/admin_models.dart';
import 'package:smart_student_companion/features/admin/presentation/widgets/admin_widgets.dart';
import 'package:smart_student_companion/features/admin/providers/admin_providers.dart';

class AnnouncementDetailsScreen extends ConsumerWidget {
  const AnnouncementDetailsScreen({required this.id, super.key});
  final String id;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return AdminShell(
      title: 'Announcement Details',
      child: FutureBuilder<Announcement?>(
        future: ref
            .read(announcementRepositoryProvider)
            .getAnnouncementById(id),
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          final announcement = snapshot.data;
          if (announcement == null) {
            return const Center(child: Text('Announcement not found.'));
          }
          return _details(context, announcement);
        },
      ),
    );
  }

  Widget _details(BuildContext context, Announcement announcement) => ListView(
    padding: const EdgeInsets.fromLTRB(28, 26, 28, 36),
    children: [
      Row(
        children: [
          Expanded(
            child: Text(
              announcement.title,
              style: const TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          StatusBadge(status: announcement.recordStatus),
        ],
      ),
      const SizedBox(height: 8),
      Text(
        '${announcement.categoryLabel} | ${announcement.audienceLabel}',
        style: const TextStyle(color: AppColors.textSecondary),
      ),
      const SizedBox(height: 20),
      AdminCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(announcement.message, style: const TextStyle(height: 1.5)),
            const Divider(height: 30),
            _metadata('Created by', announcement.createdBy),
            _metadata('Created at', _date(announcement.createdAt)),
            _metadata('Published at', _date(announcement.publishedAt)),
            _metadata('Scheduled at', _date(announcement.scheduledAt)),
            if (announcement.attachmentName != null)
              _metadata('Attachment', announcement.attachmentName!),
          ],
        ),
      ),
      const SizedBox(height: 18),
      Wrap(
        spacing: 12,
        runSpacing: 12,
        children: [
          OutlinedButton.icon(
            onPressed: () => context.pop(),
            icon: const Icon(Icons.arrow_back),
            label: const Text('BACK'),
          ),
          if (announcement.status != AnnouncementStatus.archived)
            FilledButton.icon(
              onPressed: () => context.push(
                '/admin/announcements/${announcement.id}/edit',
                extra: announcement,
              ),
              icon: const Icon(Icons.edit_outlined),
              label: const Text('EDIT'),
            ),
        ],
      ),
    ],
  );

  Widget _metadata(String label, String value) => Padding(
    padding: const EdgeInsets.only(bottom: 10),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 120,
          child: Text(
            label,
            style: const TextStyle(color: AppColors.textSecondary),
          ),
        ),
        Expanded(child: Text(value)),
      ],
    ),
  );

  String _date(DateTime? value) => value == null
      ? 'Not available'
      : '${value.day.toString().padLeft(2, '0')}/${value.month.toString().padLeft(2, '0')}/${value.year}';
}
