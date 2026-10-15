import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:smart_student_companion/app/app_providers.dart';
import 'package:smart_student_companion/core/theme/app_colors.dart';
import 'package:smart_student_companion/core/widgets/app_card.dart';
import 'package:smart_student_companion/features/admin/domain/models/campus_service_models.dart';
import 'package:smart_student_companion/features/admin/providers/admin_providers.dart';

class LostFoundScreen extends ConsumerStatefulWidget {
  const LostFoundScreen({super.key});

  @override
  ConsumerState<LostFoundScreen> createState() => _LostFoundScreenState();
}

class _LostFoundScreenState extends ConsumerState<LostFoundScreen> {
  final _searchController = TextEditingController();
  String _query = '';
  String _filter = 'All';
  int _tab = 0;

  @override
  Widget build(BuildContext context) {
    final publicState = ref.watch(approvedLostFoundProvider);
    final reportsState = ref.watch(myLostFoundReportsProvider);
    final records = _tab == 0
        ? publicState.valueOrNull ?? const <CampusServiceRecord>[]
        : reportsState.valueOrNull ?? const <CampusServiceRecord>[];
    final isLoading = _tab == 0
        ? publicState.isLoading
        : reportsState.isLoading;
    final error = _tab == 0 ? publicState.error : reportsState.error;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Lost & Found'),
        actions: [
          IconButton(
            tooltip: 'Sign out',
            onPressed: () async {
              final loggedOut = await ref
                  .read(authStateProvider.notifier)
                  .logout();
              if (loggedOut && context.mounted) context.go('/login');
            },
            icon: const Icon(Icons.logout_outlined),
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : error != null
          ? _errorState()
          : _content(records),
    );
  }

  Widget _content(List<CampusServiceRecord> records) {
    final filtered = records.where((record) {
      final searchable = [
        record.name,
        record.category,
        record.secondary,
        record.description,
        record.color,
        ...record.details.values,
      ].join(' ').toLowerCase();
      final matchesQuery = searchable.contains(_query.toLowerCase());
      final type = record.type.isNotEmpty ? record.type : record.status.name;
      final matchesFilter =
          _filter == 'All' ||
          type.toLowerCase() == _filter.toLowerCase() ||
          record.status.name == _filter.toLowerCase();
      return matchesQuery && matchesFilter;
    }).toList();

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
      children: [
        Text(
          'Lost & Found',
          style: Theme.of(
            context,
          ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 6),
        const Text(
          'Find reported items or submit a report for the campus community.',
          style: TextStyle(color: AppColors.textSecondary),
        ),
        const SizedBox(height: 18),
        SegmentedButton<int>(
          segments: const [
            ButtonSegment(value: 0, label: Text('Campus items')),
            ButtonSegment(value: 1, label: Text('My reports')),
          ],
          selected: {_tab},
          onSelectionChanged: (value) => setState(() => _tab = value.first),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: _searchController,
          onChanged: (value) => setState(() => _query = value.trim()),
          decoration: const InputDecoration(
            prefixIcon: Icon(Icons.search),
            hintText: 'Search item, category, location or description',
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: ['All', 'Lost', 'Found', 'Claimed', 'Resolved']
              .map(
                (value) => ChoiceChip(
                  label: Text(value),
                  selected: _filter == value,
                  onSelected: (_) => setState(() => _filter = value),
                ),
              )
              .toList(),
        ),
        if (_tab == 0) ...[
          const SizedBox(height: 16),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              FilledButton.icon(
                onPressed: () => _openReport('lost'),
                icon: const Icon(Icons.search_off_outlined),
                label: const Text('Report lost item'),
              ),
              OutlinedButton.icon(
                onPressed: () => _openReport('found'),
                icon: const Icon(Icons.inventory_2_outlined),
                label: const Text('Report found item'),
              ),
            ],
          ),
        ],
        const SizedBox(height: 18),
        if (filtered.isEmpty)
          AppCard(
            child: Text(
              _tab == 0
                  ? 'No approved Lost & Found items match your search.'
                  : 'You have not submitted any reports yet.',
              style: const TextStyle(color: AppColors.textSecondary),
            ),
          )
        else
          ...filtered.map(_recordCard),
      ],
    );
  }

  Widget _recordCard(CampusServiceRecord record) {
    final type = record.type.isNotEmpty
        ? record.type
        : record.status == CampusRecordStatus.found
        ? 'found'
        : 'lost';
    final statusLabel = record.status.label;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: AppCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    record.name,
                    style: const TextStyle(fontWeight: FontWeight.w800),
                  ),
                ),
                Chip(
                  label: Text(type.toUpperCase()),
                  visualDensity: VisualDensity.compact,
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              [
                if (record.category.isNotEmpty) record.category,
                if (record.secondary.isNotEmpty) record.secondary,
                if (record.date.isNotEmpty) record.date,
              ].join('  |  '),
              style: const TextStyle(color: AppColors.textSecondary),
            ),
            const SizedBox(height: 8),
            Text(record.description),
            const SizedBox(height: 10),
            Row(
              children: [
                Text(
                  statusLabel,
                  style: TextStyle(
                    color: record.status == CampusRecordStatus.rejected
                        ? AppColors.danger
                        : AppColors.primary,
                    fontWeight: FontWeight.w700,
                    fontSize: 12,
                  ),
                ),
                const Spacer(),
                if (_tab == 1 && record.status == CampusRecordStatus.pending)
                  TextButton(
                    onPressed: () => _openReport(type, record: record),
                    child: const Text('EDIT'),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _errorState() => Center(
    child: Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('Unable to load Lost & Found records.'),
          const SizedBox(height: 12),
          OutlinedButton(
            onPressed: () {
              ref.invalidate(approvedLostFoundProvider);
              ref.invalidate(myLostFoundReportsProvider);
            },
            child: const Text('Try again'),
          ),
        ],
      ),
    ),
  );

  Future<void> _openReport(String type, {CampusServiceRecord? record}) async {
    final result = await showDialog<CampusServiceRecord>(
      context: context,
      builder: (_) => _LostFoundReportDialog(type: type, record: record),
    );
    if (result == null) return;
    try {
      final repository = ref.read(campusServiceRepositoryProvider);
      if (record == null) {
        await repository.submitLostFoundReport(result);
      } else {
        await repository.updatePendingLostFoundReport(result);
      }
      ref.invalidate(myLostFoundReportsProvider);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Report submitted for admin review.')),
        );
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Unable to submit the report.')),
        );
      }
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}

class _LostFoundReportDialog extends StatefulWidget {
  const _LostFoundReportDialog({required this.type, this.record});
  final String type;
  final CampusServiceRecord? record;

  @override
  State<_LostFoundReportDialog> createState() => _LostFoundReportDialogState();
}

class _LostFoundReportDialogState extends State<_LostFoundReportDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _name;
  late final TextEditingController _category;
  late final TextEditingController _description;
  late final TextEditingController _location;
  late final TextEditingController _date;
  late final TextEditingController _time;
  late final TextEditingController _color;
  late final TextEditingController _identifyingDetails;
  late final TextEditingController _imageUrl;
  late final TextEditingController _contact;

  @override
  void initState() {
    super.initState();
    final record = widget.record;
    _name = TextEditingController(text: record?.name);
    _category = TextEditingController(text: record?.category);
    _description = TextEditingController(text: record?.description);
    _location = TextEditingController(text: record?.secondary);
    _date = TextEditingController(text: record?.date);
    _time = TextEditingController(text: record?.time);
    _color = TextEditingController(text: record?.color);
    _identifyingDetails = TextEditingController(
      text: record?.details['identifyingDetails'],
    );
    _imageUrl = TextEditingController(text: record?.imageUrl);
    _contact = TextEditingController(text: record?.contact);
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
    title: Text('Report ${widget.type} item'),
    content: SizedBox(
      width: 480,
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            children: [
              _field(_name, 'Item name'),
              _field(_category, 'Category'),
              _field(_description, 'Description', lines: 3),
              _field(_location, 'Location'),
              _field(_date, 'Date'),
              _field(_time, 'Time', required: false),
              _field(_color, 'Color', required: false),
              _field(
                _identifyingDetails,
                'Identifying details',
                required: false,
                lines: 2,
              ),
              _field(_imageUrl, 'Image URL (optional)', required: false),
              _field(_contact, 'Contact information'),
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
      FilledButton(onPressed: _submit, child: const Text('Submit report')),
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
    if (!(_formKey.currentState?.validate() ?? false)) return;
    final user = ProviderScope.containerOf(
      context,
    ).read(authStateProvider).valueOrNull?.user;
    if (user == null) return;
    Navigator.pop(
      context,
      CampusServiceRecord(
        id: widget.record?.id ?? '',
        kind: CampusServiceKind.lostFound,
        name: _name.text.trim(),
        description: _description.text.trim(),
        secondary: _location.text.trim(),
        status: CampusRecordStatus.pending,
        date: _date.text.trim(),
        details: {'identifyingDetails': _identifyingDetails.text.trim()},
        type: widget.type,
        category: _category.text.trim(),
        time: _time.text.trim(),
        color: _color.text.trim(),
        imageUrl: _imageUrl.text.trim().isEmpty ? null : _imageUrl.text.trim(),
        reportedBy: user.name,
        reportedByUserId: user.uid,
        contact: _contact.text.trim(),
      ),
    );
  }

  @override
  void dispose() {
    for (final controller in [
      _name,
      _category,
      _description,
      _location,
      _date,
      _time,
      _color,
      _identifyingDetails,
      _imageUrl,
      _contact,
    ]) {
      controller.dispose();
    }
    super.dispose();
  }
}
