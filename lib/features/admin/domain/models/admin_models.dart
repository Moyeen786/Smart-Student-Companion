import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:smart_student_companion/models/user_model.dart';

enum RecordStatus {
  active,
  published,
  scheduled,
  draft,
  archived,
  reported,
  review,
  claimed,
  closed,
}

enum AnnouncementCategory {
  academic,
  examination,
  placement,
  event,
  general,
  emergency,
}

enum AnnouncementAudience {
  allUsers,
  students,
  faculty,
  parents,
  studentsAndFaculty,
  specificDepartment,
}

enum AnnouncementStatus { draft, scheduled, published, archived }

extension RecordStatusLabel on RecordStatus {
  String get label => switch (this) {
    RecordStatus.active => 'Active',
    RecordStatus.published => 'Published',
    RecordStatus.scheduled => 'Scheduled',
    RecordStatus.draft => 'Draft',
    RecordStatus.archived => 'Archived',
    RecordStatus.reported => 'Reported',
    RecordStatus.review => 'Under review',
    RecordStatus.claimed => 'Claimed',
    RecordStatus.closed => 'Closed',
  };

  Color get color => switch (this) {
    RecordStatus.active || RecordStatus.published => const Color(0xFF1F7A52),
    RecordStatus.scheduled => const Color(0xFF2563A6),
    RecordStatus.draft || RecordStatus.archived => const Color(0xFF667085),
    RecordStatus.reported || RecordStatus.review => const Color(0xFFB26A00),
    RecordStatus.claimed || RecordStatus.closed => const Color(0xFF6B4FA1),
  };
}

extension AnnouncementCategoryLabel on AnnouncementCategory {
  String get label => switch (this) {
    AnnouncementCategory.academic => 'Academic',
    AnnouncementCategory.examination => 'Examination',
    AnnouncementCategory.placement => 'Placement',
    AnnouncementCategory.event => 'Event',
    AnnouncementCategory.general => 'General',
    AnnouncementCategory.emergency => 'Emergency',
  };

  String get value => name;

  static AnnouncementCategory fromValue(String? value) => switch (value) {
    'academic' => AnnouncementCategory.academic,
    'examination' => AnnouncementCategory.examination,
    'placement' => AnnouncementCategory.placement,
    'event' => AnnouncementCategory.event,
    'general' => AnnouncementCategory.general,
    'emergency' => AnnouncementCategory.emergency,
    _ => AnnouncementCategory.general,
  };
}

extension AnnouncementAudienceLabel on AnnouncementAudience {
  String get label => switch (this) {
    AnnouncementAudience.allUsers => 'All Users',
    AnnouncementAudience.students => 'Students',
    AnnouncementAudience.faculty => 'Faculty',
    AnnouncementAudience.parents => 'Parents',
    AnnouncementAudience.studentsAndFaculty => 'Students & Faculty',
    AnnouncementAudience.specificDepartment => 'Specific Department',
  };

  String get value => name;

  static AnnouncementAudience fromValue(String? value) => switch (value) {
    'allUsers' => AnnouncementAudience.allUsers,
    'students' => AnnouncementAudience.students,
    'faculty' => AnnouncementAudience.faculty,
    'parents' => AnnouncementAudience.parents,
    'studentsAndFaculty' => AnnouncementAudience.studentsAndFaculty,
    'specificDepartment' => AnnouncementAudience.specificDepartment,
    _ => AnnouncementAudience.allUsers,
  };
}

extension AnnouncementStatusLabel on AnnouncementStatus {
  String get label => switch (this) {
    AnnouncementStatus.draft => 'Draft',
    AnnouncementStatus.scheduled => 'Scheduled',
    AnnouncementStatus.published => 'Published',
    AnnouncementStatus.archived => 'Archived',
  };

  String get value => name;

  static AnnouncementStatus fromValue(String? value) => switch (value) {
    'draft' => AnnouncementStatus.draft,
    'scheduled' => AnnouncementStatus.scheduled,
    'published' => AnnouncementStatus.published,
    'archived' => AnnouncementStatus.archived,
    _ => AnnouncementStatus.draft,
  };

  RecordStatus get recordStatus => switch (this) {
    AnnouncementStatus.published => RecordStatus.published,
    AnnouncementStatus.scheduled => RecordStatus.scheduled,
    AnnouncementStatus.draft => RecordStatus.draft,
    AnnouncementStatus.archived => RecordStatus.archived,
  };

  Color get color => recordStatus.color;
}

class AdminUser {
  const AdminUser({required this.user, required this.status});
  final UserModel user;
  final RecordStatus status;
}

class Announcement {
  Announcement({
    this.id = '',
    this.title = '',
    this.message = '',
    this.category = AnnouncementCategory.general,
    this.audience = AnnouncementAudience.allUsers,
    this.status = AnnouncementStatus.draft,
    this.createdBy = '',
    DateTime? createdAt,
    this.publishedAt,
    this.scheduledAt,
    this.attachmentUrl,
    this.attachmentName,
    this.date = '',
  }) : createdAt = createdAt ?? DateTime.now();

  final String id;
  final String title;
  final String message;
  final AnnouncementCategory category;
  final AnnouncementAudience audience;
  final AnnouncementStatus status;
  final String createdBy;
  final DateTime createdAt;
  final DateTime? publishedAt;
  final DateTime? scheduledAt;
  final String? attachmentUrl;
  final String? attachmentName;
  final String date;

  String get categoryLabel => category.label;
  String get audienceLabel => audience.label;
  String get statusLabel => status.label;
  RecordStatus get recordStatus => status.recordStatus;

  Announcement copyWith({
    String? id,
    String? title,
    String? message,
    AnnouncementCategory? category,
    AnnouncementAudience? audience,
    AnnouncementStatus? status,
    String? createdBy,
    DateTime? createdAt,
    DateTime? publishedAt,
    DateTime? scheduledAt,
    String? attachmentUrl,
    String? attachmentName,
    String? date,
  }) => Announcement(
    id: id ?? this.id,
    title: title ?? this.title,
    message: message ?? this.message,
    category: category ?? this.category,
    audience: audience ?? this.audience,
    status: status ?? this.status,
    createdBy: createdBy ?? this.createdBy,
    createdAt: createdAt ?? this.createdAt,
    publishedAt: publishedAt ?? this.publishedAt,
    scheduledAt: scheduledAt ?? this.scheduledAt,
    attachmentUrl: attachmentUrl ?? this.attachmentUrl,
    attachmentName: attachmentName ?? this.attachmentName,
    date: date ?? this.date,
  );

  factory Announcement.fromMap(Map<String, dynamic> map) => Announcement(
    id: map['id'] as String? ?? '',
    title: map['title'] as String? ?? '',
    message: map['message'] as String? ?? '',
    category: AnnouncementCategoryLabel.fromValue(map['category'] as String?),
    audience: AnnouncementAudienceLabel.fromValue(map['audience'] as String?),
    status: AnnouncementStatusLabel.fromValue(map['status'] as String?),
    createdBy: map['createdBy'] as String? ?? '',
    createdAt: _asDateTime(map['createdAt']) ?? DateTime.now(),
    publishedAt: _asDateTime(map['publishedAt']),
    scheduledAt: _asDateTime(map['scheduledAt']),
    attachmentUrl: map['attachmentUrl'] as String?,
    attachmentName: map['attachmentName'] as String?,
    date: map['date'] as String? ?? '',
  );

  Map<String, dynamic> toMap() => {
    'id': id,
    'title': title,
    'message': message,
    'category': category.value,
    'audience': audience.value,
    'status': status.value,
    'createdBy': createdBy,
    'createdAt': createdAt,
    'publishedAt': publishedAt,
    'scheduledAt': scheduledAt,
    'attachmentUrl': attachmentUrl,
    'attachmentName': attachmentName,
    'date': date,
  };

  static DateTime? _asDateTime(dynamic value) {
    if (value is Timestamp) {
      return value.toDate();
    }
    if (value is DateTime) {
      return value;
    }
    return null;
  }
}

class ActivityItem {
  const ActivityItem({
    required this.title,
    required this.time,
    required this.icon,
    required this.color,
  });
  final String title;
  final String time;
  final IconData icon;
  final Color color;
}

class DepartmentSummary {
  const DepartmentSummary({
    required this.name,
    required this.students,
    required this.faculty,
    required this.attendance,
  });
  final String name;
  final int students;
  final int faculty;
  final int attendance;
}

class AdminOverview {
  const AdminOverview({
    required this.students,
    required this.faculty,
    required this.departments,
    required this.activeEvents,
    this.attendance,
  });

  final int students;
  final int faculty;
  final int departments;
  final int activeEvents;
  final int? attendance;
}
