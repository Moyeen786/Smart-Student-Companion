import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:smart_student_companion/app/app_providers.dart';
import 'package:smart_student_companion/core/theme/app_colors.dart';
import 'package:smart_student_companion/features/admin/domain/models/campus_service_models.dart';
import 'package:smart_student_companion/features/admin/presentation/widgets/admin_widgets.dart';
import 'package:smart_student_companion/features/admin/providers/admin_providers.dart';

class AdminCampusService extends ConsumerStatefulWidget {
  const AdminCampusService({super.key, required this.kind});
  final CampusServiceKind kind;

  @override
  ConsumerState<AdminCampusService> createState() => _AdminCampusServiceState();
}

class _AdminCampusServiceState extends ConsumerState<AdminCampusService> {
  final _searchController = TextEditingController();
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(campusServiceRecordsProvider(widget.kind));
    return AdminShell(
      title: '${widget.kind.label} Management',
      child: state.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) {
          final firebaseError = error is FirebaseException ? error : null;
          debugPrint('Lost & Found load failed');
          debugPrint('Collection: lost_found');
          debugPrint(
            'Query: collection("lost_found").orderBy("createdAt", descending: true).get()',
          );
          debugPrint(
            'FirebaseException code: ${firebaseError?.code ?? 'not a FirebaseException'}',
          );
          debugPrint(
            'FirebaseException message: ${firebaseError?.message ?? error}',
          );
          debugPrint('Stack trace: $stackTrace');
          return _errorState();
        },
        data: (records) => _content(records),
      ),
    );
  }

  Widget _errorState() => Center(
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text('Unable to load ${widget.kind.label.toLowerCase()} records.'),
        const SizedBox(height: 12),
        OutlinedButton(
          onPressed: () =>
              ref.invalidate(campusServiceRecordsProvider(widget.kind)),
          child: const Text('Try again'),
        ),
      ],
    ),
  );

  Widget _content(List<CampusServiceRecord> records) {
    final pending = records
        .where((record) => record.status == CampusRecordStatus.pending)
        .toList();
    final filtered = records.where((record) {
      final text = [
        record.name,
        record.secondary,
        record.description,
        record.date,
        ...record.details.values,
      ].join(' ').toLowerCase();
      return text.contains(_query.toLowerCase()) &&
          !(widget.kind == CampusServiceKind.lostFound &&
              record.status == CampusRecordStatus.pending);
    }).toList();
    return ListView(
      padding: const EdgeInsets.fromLTRB(28, 26, 28, 36),
      children: [
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.kind.label,
                    style: const TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    _subtitle,
                    style: const TextStyle(color: AppColors.textSecondary),
                  ),
                ],
              ),
            ),
            FilledButton.icon(
              onPressed: () => _openForm(),
              icon: const Icon(Icons.add, size: 18),
              label: Text('Add ${_singularLabel.toLowerCase()}'),
            ),
          ],
        ),
        const SizedBox(height: 22),
        TextField(
          controller: _searchController,
          onChanged: (value) => setState(() => _query = value.trim()),
          decoration: const InputDecoration(
            prefixIcon: Icon(Icons.search),
            hintText: 'Search records...',
          ),
        ),
        const SizedBox(height: 16),
        if (widget.kind == CampusServiceKind.lostFound && pending.isNotEmpty)
          _pendingReports(pending),
        if (widget.kind == CampusServiceKind.lostFound && pending.isNotEmpty)
          const SizedBox(height: 18),
        if (filtered.isEmpty)
          AdminCard(
            child: Center(
              child: Text(
                records.isEmpty
                    ? 'No records have been added yet.'
                    : 'No records match your search.',
                style: const TextStyle(color: AppColors.textSecondary),
              ),
            ),
          )
        else
          ...filtered.map(_recordCard),
      ],
    );
  }

  Widget _pendingReports(List<CampusServiceRecord> records) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const Text(
        'Pending reports',
        style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
      ),
      const SizedBox(height: 10),
      ...records.map(_recordCard),
    ],
  );

  Widget _recordCard(CampusServiceRecord record) => Padding(
    padding: const EdgeInsets.only(bottom: 12),
    child: AdminCard(
      child: ListTile(
        contentPadding: EdgeInsets.zero,
        leading: CircleAvatar(
          backgroundColor: const Color(0xFFE4EFFB),
          child: Icon(_icon, color: AppColors.primary),
        ),
        title: Text(
          record.name,
          style: const TextStyle(fontWeight: FontWeight.w700),
        ),
        subtitle: Text(
          [
            record.secondary,
            record.date,
            record.description,
          ].where((text) => text.isNotEmpty).join('  |  '),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        trailing: PopupMenuButton<String>(
          tooltip: 'Record actions',
          onSelected: (action) {
            if (action == 'edit') {
              _openForm(record);
            }
            if (action == 'delete') {
              _delete(record);
            }
            if (action == 'view') {
              _viewDetails(record);
            }
            if (action == 'approve') {
              _review(record, CampusRecordStatus.approved);
            }
            if (action == 'reject') {
              _review(record, CampusRecordStatus.rejected);
            }
            if (action.startsWith('status:')) {
              _changeStatus(
                record,
                CampusRecordStatusLabel.fromValue(action.substring(7)),
              );
            }
          },
          itemBuilder: (_) => _menuItems(record),
        ),
      ),
    ),
  );

  List<PopupMenuEntry<String>> _menuItems(CampusServiceRecord record) => [
    if (widget.kind == CampusServiceKind.lostFound &&
        record.status == CampusRecordStatus.pending) ...[
      const PopupMenuItem(value: 'approve', child: Text('Approve')),
      const PopupMenuItem(value: 'reject', child: Text('Reject')),
      const PopupMenuItem(value: 'view', child: Text('View details')),
    ],
    const PopupMenuItem(value: 'edit', child: Text('Edit')),
    ..._statusOptions(record.status).map(
      (status) => PopupMenuItem(
        value: 'status:${status.name}',
        child: Text('Mark ${status.label}'),
      ),
    ),
    const PopupMenuItem(value: 'delete', child: Text('Delete')),
  ];

  List<CampusRecordStatus> _statusOptions(CampusRecordStatus current) =>
      widget.kind == CampusServiceKind.lostFound
      ? CampusRecordStatus.values
            .where(
              (status) =>
                  [
                    CampusRecordStatus.approved,
                    CampusRecordStatus.rejected,
                    CampusRecordStatus.lost,
                    CampusRecordStatus.found,
                    CampusRecordStatus.claimed,
                    CampusRecordStatus.resolved,
                  ].contains(status) &&
                  status != current,
            )
            .toList()
      : CampusRecordStatus.values
            .where(
              (status) =>
                  [
                    CampusRecordStatus.draft,
                    CampusRecordStatus.published,
                    CampusRecordStatus.archived,
                  ].contains(status) &&
                  status != current,
            )
            .toList();

  Future<void> _review(
    CampusServiceRecord record,
    CampusRecordStatus status,
  ) async {
    try {
      final reviewer = ref.read(authStateProvider).valueOrNull?.user?.uid;
      await ref
          .read(campusServiceRepositoryProvider)
          .updateStatus(record, status, reviewedBy: reviewer);
      _refresh(
        'Report ${status == CampusRecordStatus.approved ? 'approved' : 'rejected'}.',
      );
    } catch (_) {
      _message('Unable to update the report.');
    }
  }

  Future<void> _viewDetails(CampusServiceRecord record) => showDialog<void>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      title: Text(record.name),
      content: SingleChildScrollView(
        child: Text(
          [
            'Type: ${record.type}',
            'Reporter: ${record.reportedBy}',
            'Location: ${record.secondary}',
            'Date: ${record.date}',
            'Description: ${record.description}',
            if (record.contact.isNotEmpty) 'Contact: ${record.contact}',
            if (record.imageUrl != null) 'Image: ${record.imageUrl}',
          ].join('\n\n'),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => dialogContext.pop(),
          child: const Text('Close'),
        ),
      ],
    ),
  );

  Future<void> _openForm([CampusServiceRecord? record]) async {
    final result = await showDialog<CampusServiceRecord>(
      context: context,
      builder: (_) => _ServiceFormDialog(kind: widget.kind, record: record),
    );
    if (result == null) return;
    try {
      await ref.read(campusServiceRepositoryProvider).save(result);
      _refresh(result.id.isEmpty ? 'Record added.' : 'Record updated.');
    } catch (_) {
      _message('Unable to save the record.');
    }
  }

  Future<void> _changeStatus(
    CampusServiceRecord record,
    CampusRecordStatus status,
  ) async {
    try {
      await ref
          .read(campusServiceRepositoryProvider)
          .updateStatus(record, status);
      _refresh('Record marked ${status.label.toLowerCase()}.');
    } catch (_) {
      _message('Unable to update the record.');
    }
  }

  Future<void> _delete(CampusServiceRecord record) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete record?'),
        content: Text('Delete "${record.name}"? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    try {
      await ref.read(campusServiceRepositoryProvider).delete(record);
      _refresh('Record deleted.');
    } catch (_) {
      _message('Unable to delete the record.');
    }
  }

  void _refresh(String message) {
    ref.invalidate(campusServiceRecordsProvider(widget.kind));
    _message(message);
  }

  void _message(String message) =>
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(message)));

  String get _singularLabel => switch (widget.kind) {
    CampusServiceKind.placements => 'Placement opportunity',
    CampusServiceKind.events => 'Event',
    CampusServiceKind.lostFound => 'Lost & found item',
  };

  String get _subtitle => switch (widget.kind) {
    CampusServiceKind.placements =>
      'Manage companies, opportunities and placement drives.',
    CampusServiceKind.events => 'Publish and manage campus events.',
    CampusServiceKind.lostFound => 'Review, update and resolve reported items.',
  };

  IconData get _icon => switch (widget.kind) {
    CampusServiceKind.placements => Icons.work_outline_rounded,
    CampusServiceKind.events => Icons.event_outlined,
    CampusServiceKind.lostFound => Icons.inventory_2_outlined,
  };

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}

class _ServiceFormDialog extends StatefulWidget {
  const _ServiceFormDialog({required this.kind, this.record});
  final CampusServiceKind kind;
  final CampusServiceRecord? record;

  @override
  State<_ServiceFormDialog> createState() => _ServiceFormDialogState();
}

class _ServiceFormDialogState extends State<_ServiceFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _name;
  late final TextEditingController _secondary;
  late final TextEditingController _description;
  late final TextEditingController _date;
  late final TextEditingController _detailOne;
  late final TextEditingController _detailTwo;
  late CampusRecordStatus _status;

  @override
  void initState() {
    super.initState();
    final record = widget.record;
    _name = TextEditingController(text: record?.name);
    _secondary = TextEditingController(text: record?.secondary);
    _description = TextEditingController(text: record?.description);
    _date = TextEditingController(text: record?.date);
    _detailOne = TextEditingController(text: record?.details['detailOne']);
    _detailTwo = TextEditingController(text: record?.details['detailTwo']);
    _status =
        record?.status ??
        (widget.kind == CampusServiceKind.lostFound
            ? CampusRecordStatus.approved
            : CampusRecordStatus.draft);
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
    title: Text(
      widget.record == null
          ? 'Add ${_label.toLowerCase()}'
          : 'Edit ${_label.toLowerCase()}',
    ),
    content: SizedBox(
      width: 480,
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            children: [
              _field(_name, _nameLabel),
              _field(_secondary, _secondaryLabel),
              _field(_description, 'Description', required: false, lines: 3),
              _field(_date, _dateLabel, required: false),
              _field(_detailOne, _detailOneLabel, required: false),
              _field(_detailTwo, _detailTwoLabel, required: false),
              DropdownButtonFormField<CampusRecordStatus>(
                initialValue: _status,
                decoration: const InputDecoration(labelText: 'Status'),
                items: _statuses
                    .map(
                      (status) => DropdownMenuItem(
                        value: status,
                        child: Text(status.label),
                      ),
                    )
                    .toList(),
                onChanged: (value) => setState(() => _status = value!),
              ),
            ],
          ),
        ),
      ),
    ),
    actions: [
      TextButton(
        onPressed: () => Navigator.pop(context),
        child: const Text('Cancel'),
      ),
      FilledButton(onPressed: _submit, child: const Text('Save')),
    ],
  );

  Widget _field(
    TextEditingController controller,
    String label, {
    bool required = true,
    int lines = 1,
  }) => Padding(
    padding: const EdgeInsets.only(bottom: 12),
    child: TextFormField(
      controller: controller,
      maxLines: lines,
      decoration: InputDecoration(labelText: label),
      validator: required
          ? (value) => value == null || value.trim().isEmpty
                ? '$label is required.'
                : null
          : null,
    ),
  );

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    Navigator.pop(
      context,
      CampusServiceRecord(
        id: widget.record?.id ?? '',
        kind: widget.kind,
        name: _name.text.trim(),
        secondary: _secondary.text.trim(),
        description: _description.text.trim(),
        date: _date.text.trim(),
        status: _status,
        details: {
          'detailOne': _detailOne.text.trim(),
          'detailTwo': _detailTwo.text.trim(),
        },
        createdAt: widget.record?.createdAt,
      ),
    );
  }

  List<CampusRecordStatus> get _statuses =>
      widget.kind == CampusServiceKind.lostFound
      ? [
          CampusRecordStatus.lost,
          CampusRecordStatus.found,
          CampusRecordStatus.claimed,
          CampusRecordStatus.resolved,
        ]
      : [
          CampusRecordStatus.draft,
          CampusRecordStatus.published,
          CampusRecordStatus.archived,
        ];

  String get _label => switch (widget.kind) {
    CampusServiceKind.placements => 'Placement opportunity',
    CampusServiceKind.events => 'Event',
    CampusServiceKind.lostFound => 'Lost & found item',
  };

  String get _nameLabel => switch (widget.kind) {
    CampusServiceKind.placements => 'Company / opportunity name',
    CampusServiceKind.events => 'Event name',
    CampusServiceKind.lostFound => 'Item name',
  };

  String get _secondaryLabel => switch (widget.kind) {
    CampusServiceKind.placements => 'Job role',
    CampusServiceKind.events => 'Venue / organizer',
    CampusServiceKind.lostFound => 'Location',
  };

  String get _dateLabel => switch (widget.kind) {
    CampusServiceKind.placements => 'Application deadline / drive date',
    CampusServiceKind.events => 'Event date / registration deadline',
    CampusServiceKind.lostFound => 'Reported date',
  };

  String get _detailOneLabel => switch (widget.kind) {
    CampusServiceKind.placements => 'Package / CTC',
    CampusServiceKind.events => 'Category',
    CampusServiceKind.lostFound => 'Category',
  };

  String get _detailTwoLabel => switch (widget.kind) {
    CampusServiceKind.placements => 'Eligibility / location',
    CampusServiceKind.events => 'Start and end time',
    CampusServiceKind.lostFound => 'Reported by',
  };

  @override
  void dispose() {
    for (final controller in [
      _name,
      _secondary,
      _description,
      _date,
      _detailOne,
      _detailTwo,
    ]) {
      controller.dispose();
    }
    super.dispose();
  }
}
