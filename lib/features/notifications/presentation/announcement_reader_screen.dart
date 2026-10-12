import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smart_student_companion/features/admin/domain/models/admin_models.dart';
import 'package:smart_student_companion/features/admin/providers/admin_providers.dart';

class AnnouncementReaderScreen extends ConsumerWidget {
  const AnnouncementReaderScreen({required this.id, super.key});

  final String id;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text('Announcement')),
      body: FutureBuilder<Announcement?>(
        future: ref
            .read(announcementRepositoryProvider)
            .getAnnouncementById(id),
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          final announcement = snapshot.data;
          if (announcement == null ||
              announcement.status != AnnouncementStatus.published) {
            return const Center(child: Text('Announcement not found.'));
          }
          return ListView(
            padding: const EdgeInsets.all(20),
            children: [
              Text(
                announcement.title,
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 8),
              Text(
                '${announcement.categoryLabel} | ${announcement.audienceLabel}',
                style: const TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 20),
              Text(announcement.message, style: const TextStyle(height: 1.5)),
            ],
          );
        },
      ),
    );
  }
}
