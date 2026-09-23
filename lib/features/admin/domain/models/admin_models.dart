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

class AdminUser {
  const AdminUser({required this.user, required this.status});
  final UserModel user;
  final RecordStatus status;
}

class Announcement {
  const Announcement({
    required this.title,
    required this.category,
    required this.audience,
    required this.date,
    required this.status,
  });
  final String title;
  final String category;
  final String audience;
  final String date;
  final RecordStatus status;
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
