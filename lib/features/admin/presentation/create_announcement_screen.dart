import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:smart_student_companion/app/app_providers.dart';
import 'package:smart_student_companion/core/theme/app_colors.dart';
import 'package:smart_student_companion/features/admin/domain/models/admin_models.dart';
import 'package:smart_student_companion/features/admin/presentation/widgets/admin_widgets.dart';
import 'package:smart_student_companion/features/admin/providers/admin_providers.dart';
import 'package:smart_student_companion/models/user_model.dart';

class CreateAnnouncementScreen extends ConsumerStatefulWidget {
  const CreateAnnouncementScreen({super.key});

  @override
  ConsumerState<CreateAnnouncementScreen> createState() =>
      _CreateAnnouncementScreenState();
}

class _CreateAnnouncementScreenState
    extends ConsumerState<CreateAnnouncementScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _messageController = TextEditingController();

  AnnouncementCategory? _category;
  AnnouncementAudience? _audience;

  @override
  void initState() {
    super.initState();
    _messageController.addListener(() => setState(() {}));
  }

  bool _publishNow = true;
  DateTime? _scheduledDate;
  TimeOfDay? _scheduledTime;
  PlatformFile? _attachment;

  bool _isSubmitting = false;
  bool _success = false;
  bool _savedAsDraft = false;

  @override
  void dispose() {
    _titleController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authStateProvider).valueOrNull?.user;
    final wide = MediaQuery.sizeOf(context).width >= 760;

    return AdminShell(
      title: 'Create announcement',
      child: LayoutBuilder(
        builder: (context, constraints) {
          final maxWidth = constraints.maxWidth > 1100
              ? 1100.0
              : constraints.maxWidth;
          return Center(
            child: SizedBox(
              width: maxWidth,
              child: ListView(
                padding: const EdgeInsets.fromLTRB(28, 26, 28, 36),
                children: [
                  Text(
                    'Create announcement',
                    style: const TextStyle(
                      fontSize: 27,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Draft, schedule and publish an institutional circular.',
                    style: TextStyle(color: AppColors.textSecondary),
                  ),
                  const SizedBox(height: 18),
                  Text(
                    'Admin / Announcements / Create Announcement',
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.muted,
                      letterSpacing: 0.1,
                    ),
                  ),
                  const SizedBox(height: 22),
                  if (_success) _successBanner() else const SizedBox.shrink(),
                  const SizedBox(height: 22),
                  if (!_success)
                    _buildFormCard(wide, user)
                  else
                    _buildSuccessActions(user),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildFormCard(bool wide, UserModel? user) => AdminCard(
    padding: const EdgeInsets.all(22),
    child: Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'ANNOUNCEMENT DETAILS',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.1,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Provide the information that should be shared with the selected audience.',
            style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
          ),
          const SizedBox(height: 22),
          _buildTextField(
            label: 'Announcement Title',
            hint: 'Enter announcement title',
            controller: _titleController,
            validator: (value) {
              if ((value ?? '').trim().isEmpty) {
                return 'Announcement title is required.';
              }
              return null;
            },
          ),
          const SizedBox(height: 18),
          if (wide)
            Row(
              children: [
                Expanded(child: _buildCategoryField()),
                const SizedBox(width: 18),
                Expanded(child: _buildAudienceField()),
              ],
            )
          else ...[
            _buildCategoryField(),
            const SizedBox(height: 18),
            _buildAudienceField(),
          ],
          const SizedBox(height: 20),
          _buildMessageField(),
          const SizedBox(height: 18),
          const Text(
            'ATTACHMENT',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.1,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Add a supporting document if required.',
            style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
          ),
          const SizedBox(height: 14),
          _attachment != null
              ? _attachmentCard()
              : SizedBox(
                  width: 180,
                  child: OutlinedButton.icon(
                    onPressed: _pickAttachment,
                    icon: const Icon(Icons.attach_file_rounded, size: 18),
                    label: const Text('Add Attachment'),
                  ),
                ),
          const SizedBox(height: 22),
          const Text(
            'PUBLICATION',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.1,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Choose when this announcement should be published.',
            style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
          ),
          const SizedBox(height: 16),
          RadioGroup<bool>(
            groupValue: _publishNow,
            onChanged: (value) {
              if (value != null) setState(() => _publishNow = value);
            },
            child: Column(
              children: [
                Row(
                  children: [
                    const Radio<bool>(value: true),
                    const Expanded(
                      child: Text(
                        'Publish Now',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    const Radio<bool>(value: false),
                    const Expanded(
                      child: Text(
                        'Schedule for Later',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          if (!_publishNow) ...[
            const SizedBox(height: 10),
            if (wide)
              Row(
                children: [
                  Expanded(child: _buildDateField()),
                  const SizedBox(width: 18),
                  Expanded(child: _buildTimeField()),
                ],
              )
            else ...[
              _buildDateField(),
              const SizedBox(height: 14),
              _buildTimeField(),
            ],
          ],
          const SizedBox(height: 28),
          Align(
            alignment: Alignment.centerRight,
            child: Wrap(
              alignment: WrapAlignment.end,
              spacing: 12,
              runSpacing: 12,
              children: [
                OutlinedButton(
                  onPressed: _isSubmitting ? null : _handleSaveDraft,
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 16,
                    ),
                    foregroundColor: AppColors.primary,
                    side: const BorderSide(color: AppColors.primary),
                  ),
                  child: Text(
                    _isSubmitting && _savedAsDraft ? 'Saving...' : 'SAVE DRAFT',
                  ),
                ),
                ElevatedButton(
                  onPressed: _isSubmitting ? null : _handlePublish,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 16,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: Text(
                    _isSubmitting && !_savedAsDraft
                        ? 'Publishing...'
                        : 'PUBLISH ANNOUNCEMENT',
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  );

  Widget _buildTextField({
    required String label,
    required String hint,
    required TextEditingController controller,
    required String? Function(String?) validator,
  }) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        label,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          color: AppColors.textPrimary,
        ),
      ),
      const SizedBox(height: 8),
      TextFormField(
        controller: controller,
        validator: validator,
        decoration: InputDecoration(
          hintText: hint,
          filled: true,
          fillColor: const Color(0xFFF9FBFF),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 14,
            vertical: 16,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.border),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.border),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.danger),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.danger, width: 1.5),
          ),
        ),
      ),
    ],
  );

  Widget _buildCategoryField() => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const Text(
        'Category',
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          color: AppColors.textPrimary,
        ),
      ),
      const SizedBox(height: 8),
      DropdownButtonFormField<AnnouncementCategory>(
        initialValue: _category,
        isExpanded: true,
        decoration: _fieldDecoration(),
        hint: const Text('Select category'),
        items: AnnouncementCategory.values
            .map(
              (category) => DropdownMenuItem(
                value: category,
                child: Text(category.label),
              ),
            )
            .toList(),
        onChanged: (value) => setState(() => _category = value),
        validator: (value) {
          if (value == null) {
            return 'Please select a category.';
          }
          return null;
        },
      ),
    ],
  );

  Widget _buildAudienceField() => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const Text(
        'Audience',
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          color: AppColors.textPrimary,
        ),
      ),
      const SizedBox(height: 8),
      DropdownButtonFormField<AnnouncementAudience>(
        initialValue: _audience,
        isExpanded: true,
        decoration: _fieldDecoration(),
        hint: const Text('Select audience'),
        items: AnnouncementAudience.values
            .map(
              (audience) => DropdownMenuItem(
                value: audience,
                child: Text(audience.label),
              ),
            )
            .toList(),
        onChanged: (value) => setState(() => _audience = value),
        validator: (value) {
          if (value == null) {
            return 'Please select an audience.';
          }
          return null;
        },
      ),
    ],
  );

  InputDecoration _fieldDecoration() => InputDecoration(
    filled: true,
    fillColor: const Color(0xFFF9FBFF),
    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: AppColors.border),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: AppColors.border),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
    ),
    errorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: AppColors.danger),
    ),
    focusedErrorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: AppColors.danger, width: 1.5),
    ),
  );

  Widget _buildMessageField() => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const Text(
        'Message',
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          color: AppColors.textPrimary,
        ),
      ),
      const SizedBox(height: 8),
      TextFormField(
        controller: _messageController,
        maxLength: 2000,
        minLines: 7,
        maxLines: 12,
        validator: (value) {
          if ((value ?? '').trim().isEmpty) {
            return 'Announcement message is required.';
          }
          return null;
        },
        decoration: InputDecoration(
          hintText: 'Write the announcement details here...',
          filled: true,
          fillColor: const Color(0xFFF9FBFF),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 14,
            vertical: 14,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.border),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.border),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.danger),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.danger, width: 1.5),
          ),
          counterText: '',
        ),
      ),
      const SizedBox(height: 8),
      Align(
        alignment: Alignment.centerRight,
        child: Text(
          '${_messageController.text.length} / 2000',
          style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
        ),
      ),
    ],
  );

  Widget _buildDateField() => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const Text(
        'Publication Date',
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          color: AppColors.textPrimary,
        ),
      ),
      const SizedBox(height: 8),
      InkWell(
        onTap: _pickDate,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: const Color(0xFFF9FBFF),
            border: Border.all(color: AppColors.border),
          ),
          child: Row(
            children: [
              const Icon(
                Icons.calendar_today_outlined,
                size: 18,
                color: AppColors.primary,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  _scheduledDate == null
                      ? 'Select Date'
                      : '${_scheduledDate!.day}/${_scheduledDate!.month}/${_scheduledDate!.year}',
                  style: TextStyle(
                    color: _scheduledDate == null
                        ? AppColors.muted
                        : AppColors.textPrimary,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      if (_scheduledDate == null && !_publishNow)
        const Padding(
          padding: EdgeInsets.only(top: 8),
          child: Text(
            'Publication date is required.',
            style: TextStyle(color: AppColors.danger, fontSize: 12),
          ),
        ),
    ],
  );

  Widget _buildTimeField() => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const Text(
        'Publication Time',
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          color: AppColors.textPrimary,
        ),
      ),
      const SizedBox(height: 8),
      InkWell(
        onTap: _pickTime,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: const Color(0xFFF9FBFF),
            border: Border.all(color: AppColors.border),
          ),
          child: Row(
            children: [
              const Icon(
                Icons.access_time_outlined,
                size: 18,
                color: AppColors.primary,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  _scheduledTime == null
                      ? 'Select Time'
                      : _scheduledTime!.format(context),
                  style: TextStyle(
                    color: _scheduledTime == null
                        ? AppColors.muted
                        : AppColors.textPrimary,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      if (_scheduledTime == null && !_publishNow)
        const Padding(
          padding: EdgeInsets.only(top: 8),
          child: Text(
            'Publication time is required.',
            style: TextStyle(color: AppColors.danger, fontSize: 12),
          ),
        ),
    ],
  );

  Widget _attachmentCard() => Container(
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(12),
      color: const Color(0xFFF5F9FF),
      border: Border.all(color: AppColors.border),
    ),
    child: Row(
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Icon(
            Icons.insert_drive_file_outlined,
            color: AppColors.primary,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _attachment?.name ?? 'Attachment',
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                _formatFileSize(_attachment?.size ?? 0),
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
        TextButton(
          onPressed: () => setState(() => _attachment = null),
          child: const Text('Remove'),
        ),
      ],
    ),
  );

  Widget _successBanner() => Container(
    padding: const EdgeInsets.all(18),
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(14),
      color: const Color(0xFFEAF7F0),
      border: Border.all(color: const Color(0xFFB9E7C6)),
    ),
    child: Row(
      children: [
        Container(
          width: 34,
          height: 34,
          decoration: BoxDecoration(
            color: const Color(0xFF2E8B57),
            borderRadius: BorderRadius.circular(17),
          ),
          child: const Icon(Icons.check, color: Colors.white),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _savedAsDraft ? 'Draft Saved' : 'Announcement Published',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                _savedAsDraft
                    ? 'Announcement saved as draft.'
                    : 'Your announcement has been published successfully.',
                style: const TextStyle(color: AppColors.textSecondary),
              ),
            ],
          ),
        ),
      ],
    ),
  );

  Widget _buildSuccessActions(UserModel? user) => Row(
    mainAxisAlignment: MainAxisAlignment.start,
    children: [
      FilledButton(
        onPressed: () => context.go('/admin/announcements'),
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
        ),
        child: const Text('VIEW ANNOUNCEMENTS'),
      ),
      const SizedBox(width: 12),
      OutlinedButton(
        onPressed: () {
          setState(() {
            _success = false;
            _savedAsDraft = false;
            _titleController.clear();
            _messageController.clear();
            _category = null;
            _audience = null;
            _publishNow = true;
            _scheduledDate = null;
            _scheduledTime = null;
            _attachment = null;
          });
        },
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
          side: const BorderSide(color: AppColors.primary),
          foregroundColor: AppColors.primary,
        ),
        child: const Text('CREATE ANOTHER'),
      ),
    ],
  );

  Future<void> _pickAttachment() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: const ['pdf', 'doc', 'docx', 'jpg', 'jpeg', 'png'],
    );

    if (result == null || result.files.isEmpty) return;

    setState(() => _attachment = result.files.first);
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now().subtract(const Duration(days: 1)),
      lastDate: DateTime.now().add(const Duration(days: 3650)),
    );
    if (picked != null) {
      setState(() => _scheduledDate = picked);
    }
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null) {
      setState(() => _scheduledTime = picked);
    }
  }

  Future<void> _handleSaveDraft() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    if (!_publishNow && (_scheduledDate == null || _scheduledTime == null)) {
      setState(() {});
      if (_scheduledDate == null) {
        _showInlineMessage('Publication date is required.');
      }
      if (_scheduledTime == null) {
        _showInlineMessage('Publication time is required.');
      }
      return;
    }

    await _submitAnnouncement(saveDraft: true);
  }

  Future<void> _handlePublish() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    if (!_publishNow && (_scheduledDate == null || _scheduledTime == null)) {
      if (_scheduledDate == null) {
        _showInlineMessage('Publication date is required.');
      }
      if (_scheduledTime == null) {
        _showInlineMessage('Publication time is required.');
      }
      return;
    }

    await _submitAnnouncement(saveDraft: false);
  }

  Future<void> _submitAnnouncement({required bool saveDraft}) async {
    setState(() {
      _isSubmitting = true;
      _savedAsDraft = saveDraft;
    });

    try {
      final repository = ref.read(announcementRepositoryProvider);
      final scheduledWhen =
          !_publishNow && _scheduledDate != null && _scheduledTime != null
          ? DateTime(
              _scheduledDate!.year,
              _scheduledDate!.month,
              _scheduledDate!.day,
              _scheduledTime!.hour,
              _scheduledTime!.minute,
            )
          : null;

      final announcement = Announcement(
        title: _titleController.text.trim(),
        message: _messageController.text.trim(),
        category: _category ?? AnnouncementCategory.general,
        audience: _audience ?? AnnouncementAudience.allUsers,
        status: saveDraft
            ? AnnouncementStatus.draft
            : (_publishNow
                  ? AnnouncementStatus.published
                  : AnnouncementStatus.scheduled),
        createdBy:
            ref.read(authStateProvider).valueOrNull?.user?.uid ?? 'admin-user',
        createdAt: DateTime.now(),
        publishedAt: _publishNow ? DateTime.now() : null,
        scheduledAt: scheduledWhen,
        attachmentUrl: null,
        attachmentName: _attachment?.name,
      );

      await repository.saveAnnouncement(announcement, publish: !saveDraft);
      setState(() {
        _isSubmitting = false;
        _success = true;
      });
    } catch (error) {
      setState(() => _isSubmitting = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Unable to ${saveDraft ? 'save draft' : 'publish'} announcement. Please try again.',
            ),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  void _showInlineMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), behavior: SnackBarBehavior.floating),
    );
  }

  String _formatFileSize(int bytes) {
    if (bytes <= 0) return '0 KB';
    const suffixes = ['B', 'KB', 'MB', 'GB'];
    var size = bytes.toDouble();
    var index = 0;
    while (size >= 1024 && index < suffixes.length - 1) {
      size /= 1024;
      index++;
    }
    return '${size.toStringAsFixed(size >= 10 || index == 0 ? 0 : 1)} ${suffixes[index]}';
  }
}
