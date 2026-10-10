import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:smart_student_companion/core/theme/app_colors.dart';
import 'package:smart_student_companion/features/admin/domain/models/admin_models.dart';
import 'package:smart_student_companion/features/admin/presentation/widgets/admin_widgets.dart';
import 'package:smart_student_companion/features/admin/providers/admin_providers.dart';

class AdminAnnouncements extends ConsumerStatefulWidget {
  const AdminAnnouncements({super.key});

  @override
  ConsumerState<AdminAnnouncements> createState() => _AdminAnnouncementsState();
}

class _AdminAnnouncementsState extends ConsumerState<AdminAnnouncements> {
  @override
  Widget build(BuildContext context) {
    final state = ref.watch(adminAnnouncementsProvider);
    return AdminShell(
      title: 'Announcements & Circulars',
      child: state.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, _) => _ErrorState(
          onRetry: () => ref.invalidate(adminAnnouncementsProvider),
        ),
        data: (items) => _content(context, items),
      ),
    );
  }

  final _searchController = TextEditingController();
  AnnouncementStatus? _filter;
  String _query = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Widget _content(BuildContext context, List<Announcement> announcements) {
    final filtered = announcements.where((announcement) {
      final matchesStatus = _filter == null || announcement.status == _filter;
      final searchable = [
        announcement.title,
        announcement.message,
        announcement.categoryLabel,
        announcement.audienceLabel,
      ].join(' ').toLowerCase();
      return matchesStatus && searchable.contains(_query.toLowerCase());
    }).toList();

    return ListView(
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
        const SizedBox(height: 22),
        TextField(
          controller: _searchController,
          onChanged: (value) => setState(() => _query = value.trim()),
          decoration: InputDecoration(
            hintText: 'Search announcements...',
            prefixIcon: const Icon(Icons.search),
            suffixIcon: _query.isEmpty
                ? null
                : IconButton(
                    tooltip: 'Clear search',
                    onPressed: () {
                      _searchController.clear();
                      setState(() => _query = '');
                    },
                    icon: const Icon(Icons.clear),
                  ),
          ),
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children:
              [
                (label: 'All', status: null),
                (label: 'Published', status: AnnouncementStatus.published),
                (label: 'Scheduled', status: AnnouncementStatus.scheduled),
                (label: 'Drafts', status: AnnouncementStatus.draft),
                (label: 'Archived', status: AnnouncementStatus.archived),
              ].map((item) {
                return ChoiceChip(
                  label: Text(item.label),
                  selected: _filter == item.status,
                  onSelected: (_) => setState(() => _filter = item.status),
                );
              }).toList(),
        ),
        const SizedBox(height: 16),
        if (filtered.isEmpty)
          _EmptyState(filter: _filter, searching: _query.isNotEmpty)
        else
          ...filtered.map((announcement) => _announcementCard(announcement)),
      ],
    );
  }

  Widget _announcementCard(Announcement announcement) => Padding(
    padding: const EdgeInsets.only(bottom: 12),
    child: AdminCard(
      child: InkWell(
        onTap: () => context.push('/admin/announcements/${announcement.id}'),
        borderRadius: BorderRadius.circular(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 4,
              height: 92,
              decoration: BoxDecoration(
                color: announcement.status.color,
                borderRadius: BorderRadius.circular(3),
              ),
            ),
            const SizedBox(width: 15),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 2),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      announcement.title,
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 7),
                    Text(
                      '${announcement.categoryLabel}  |  ${announcement.audienceLabel}',
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      announcement.message,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 7),
                    Text(
                      _dateLine(announcement),
                      style: const TextStyle(
                        color: AppColors.muted,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 8),
            StatusBadge(status: announcement.recordStatus),
            PopupMenuButton<String>(
              tooltip: 'Announcement actions',
              onSelected: (action) => _handleAction(announcement, action),
              itemBuilder: (_) => _menuItems(announcement.status),
            ),
          ],
        ),
      ),
    ),
  );

  List<PopupMenuEntry<String>> _menuItems(AnnouncementStatus status) =>
      switch (status) {
        AnnouncementStatus.draft => const [
          PopupMenuItem(value: 'edit', child: Text('Edit')),
          PopupMenuItem(value: 'publish', child: Text('Publish')),
          PopupMenuItem(value: 'delete', child: Text('Delete')),
        ],
        AnnouncementStatus.scheduled => const [
          PopupMenuItem(value: 'view', child: Text('View')),
          PopupMenuItem(value: 'edit', child: Text('Edit')),
          PopupMenuItem(value: 'cancel', child: Text('Cancel Schedule')),
          PopupMenuItem(value: 'delete', child: Text('Delete')),
        ],
        AnnouncementStatus.published => const [
          PopupMenuItem(value: 'view', child: Text('View')),
          PopupMenuItem(value: 'edit', child: Text('Edit')),
          PopupMenuItem(value: 'archive', child: Text('Archive')),
        ],
        AnnouncementStatus.archived => const [
          PopupMenuItem(value: 'view', child: Text('View')),
          PopupMenuItem(value: 'restore', child: Text('Restore')),
          PopupMenuItem(value: 'delete', child: Text('Delete')),
        ],
      };

  Future<void> _handleAction(Announcement announcement, String action) async {
    if (action == 'view') {
      context.push('/admin/announcements/${announcement.id}');
      return;
    }
    if (action == 'edit') {
      context.push(
        '/admin/announcements/${announcement.id}/edit',
        extra: announcement,
      );
      return;
    }
    if (action == 'publish') {
      await _saveStatus(announcement, AnnouncementStatus.published);
      return;
    }
    if (action == 'delete') {
      final confirmed = await _confirm(
        'Delete announcement?',
        'Are you sure you want to delete this announcement? This action cannot be undone.',
      );
      if (confirmed) {
        await ref
            .read(announcementRepositoryProvider)
            .deleteAnnouncement(announcement.id);
        _refresh('Announcement deleted.');
      }
      return;
    }
    final confirmed = await _confirm(
      action == 'archive'
          ? 'Archive announcement?'
          : 'Change announcement status?',
      action == 'archive'
          ? 'This announcement will no longer appear in active announcements.'
          : 'This action will update the announcement workflow status.',
    );
    if (!confirmed) return;
    final repository = ref.read(announcementRepositoryProvider);
    if (action == 'archive') {
      await repository.archiveAnnouncement(announcement.id);
    }
    if (action == 'restore') {
      await repository.restoreAnnouncement(announcement.id);
    }
    if (action == 'cancel') {
      await repository.cancelSchedule(announcement.id);
    }
    _refresh(
      action == 'archive'
          ? 'Announcement archived.'
          : action == 'restore'
          ? 'Announcement restored.'
          : 'Schedule cancelled. Announcement moved to drafts.',
    );
  }

  Future<void> _saveStatus(
    Announcement announcement,
    AnnouncementStatus status,
  ) async {
    await ref
        .read(announcementRepositoryProvider)
        .saveAnnouncement(
          announcement.copyWith(status: status, publishedAt: DateTime.now()),
        );
    _refresh('Announcement published.');
  }

  Future<bool> _confirm(String title, String message) async =>
      await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => context.pop(false),
              child: const Text('CANCEL'),
            ),
            FilledButton(
              onPressed: () => context.pop(true),
              child: const Text('CONFIRM'),
            ),
          ],
        ),
      ) ??
      false;

  void _refresh(String message) {
    ref.invalidate(adminAnnouncementsProvider);
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  String _dateLine(Announcement announcement) {
    final date = announcement.status == AnnouncementStatus.scheduled
        ? announcement.scheduledAt
        : announcement.status == AnnouncementStatus.published
        ? announcement.publishedAt
        : announcement.createdAt;
    final label = date == null ? 'Not scheduled' : _formatDate(date);
    return '${announcement.status == AnnouncementStatus.scheduled ? 'Scheduled for' : 'Created'}: $label';
  }

  String _formatDate(DateTime date) =>
      '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.filter, required this.searching});
  final AnnouncementStatus? filter;
  final bool searching;

  @override
  Widget build(BuildContext context) => AdminCard(
    child: Column(
      children: [
        Text(
          searching
              ? 'No announcements found'
              : filter == null
              ? 'No announcements yet'
              : 'No ${filter!.label.toLowerCase()} announcements',
          style: const TextStyle(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 6),
        Text(
          searching
              ? 'Try changing your search or filters.'
              : 'Create an announcement to communicate with the institution.',
          style: const TextStyle(color: AppColors.textSecondary),
        ),
      ],
    ),
  );
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.onRetry});
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) => Center(
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Text('Unable to load announcements.'),
        const SizedBox(height: 10),
        OutlinedButton(onPressed: onRetry, child: const Text('TRY AGAIN')),
      ],
    ),
  );
}
