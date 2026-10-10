import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:smart_student_companion/features/admin/domain/models/admin_models.dart';
import 'package:smart_student_companion/models/user_model.dart';

abstract class AdminRepository {
  Future<List<AdminUser>> users();
  Future<List<Announcement>> announcements();
  Future<List<DepartmentSummary>> departments();
  Future<List<ActivityItem>> activities();
  Future<AdminOverview> overview();
}

class FirestoreAdminRepository implements AdminRepository {
  FirestoreAdminRepository({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  @override
  Future<List<AdminUser>> users() async {
    final snapshot = await _firestore.collection('users').get();
    return snapshot.docs.map((doc) {
      final data = doc.data();
      final user = UserModel.fromMap({...data, 'uid': data['uid'] ?? doc.id});
      return AdminUser(user: user, status: _status(data['status'] as String?));
    }).toList();
  }

  @override
  Future<List<Announcement>> announcements() async {
    final snapshot = await _firestore
        .collection('announcements')
        .orderBy('createdAt', descending: true)
        .get();
    return snapshot.docs.map((doc) {
      final data = doc.data();
      return Announcement.fromMap({...data, 'id': doc.id});
    }).toList();
  }

  @override
  Future<List<DepartmentSummary>> departments() async {
    final snapshot = await _firestore.collection('departments').get();
    return snapshot.docs.map((doc) {
      final data = doc.data();
      return DepartmentSummary(
        name: data['name'] as String? ?? doc.id,
        students: _integer(data['students']),
        faculty: _integer(data['faculty']),
        attendance: _integer(data['attendance']),
      );
    }).toList();
  }

  @override
  Future<List<ActivityItem>> activities() async {
    final snapshot = await _firestore
        .collection('notifications')
        .orderBy('createdAt', descending: true)
        .limit(10)
        .get();
    return snapshot.docs.map((doc) {
      final data = doc.data();
      return ActivityItem(
        title: data['title'] as String? ?? '',
        time: _dateLabel(data['createdAt']),
        icon: _activityIcon(data['type'] as String?),
        color: _activityColor(data['type'] as String?),
      );
    }).toList();
  }

  @override
  Future<AdminOverview> overview() async {
    final users = await _firestore.collection('users').get();
    final departments = await _firestore.collection('departments').get();
    final events = await _firestore.collection('events').get();
    final activeEvents = events.docs.where((doc) {
      final status = doc.data()['status'] as String?;
      return status == null || status == 'active' || status == 'published';
    }).length;
    final students = users.docs
        .where((doc) => doc.data()['role'] == 'student')
        .length;
    final faculty = users.docs.where((doc) {
      final role = doc.data()['role'];
      return role == 'faculty' || role == 'teacher';
    }).length;
    final attendanceValues = departments.docs
        .map((doc) => doc.data()['attendance'])
        .whereType<num>()
        .toList();
    final attendance = attendanceValues.isEmpty
        ? null
        : attendanceValues.reduce((a, b) => a + b) / attendanceValues.length;
    return AdminOverview(
      students: students,
      faculty: faculty,
      departments: departments.size,
      activeEvents: activeEvents,
      attendance: attendance?.round(),
    );
  }

  RecordStatus _status(String? value) => RecordStatus.values.firstWhere(
    (status) => status.name == value,
    orElse: () => RecordStatus.active,
  );

  int _integer(dynamic value) => value is num ? value.round() : 0;

  String _dateLabel(dynamic value) {
    final date = value is Timestamp
        ? value.toDate()
        : value is DateTime
        ? value
        : null;
    if (date == null) return '';
    return '${date.day}/${date.month}/${date.year}';
  }

  IconData _activityIcon(String? type) => switch (type) {
    'user' => Icons.person_add_alt_1,
    'announcement' => Icons.campaign_outlined,
    'event' => Icons.event_available_outlined,
    'library' => Icons.menu_book_outlined,
    'lost_found' => Icons.inventory_2_outlined,
    _ => Icons.notifications_none_rounded,
  };

  Color _activityColor(String? type) => switch (type) {
    'user' => const Color(0xFF2563A6),
    'announcement' => const Color(0xFF1F7A52),
    'event' => const Color(0xFF6B4FA1),
    'library' => const Color(0xFFB26A00),
    'lost_found' => const Color(0xFFCF4B4B),
    _ => const Color(0xFF667085),
  };
}
