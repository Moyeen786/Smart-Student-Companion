import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:smart_student_companion/features/admin/domain/models/admin_models.dart';

abstract class AnnouncementRepository {
  Future<Announcement> saveAnnouncement(Announcement announcement);
  Future<List<Announcement>> listAnnouncements();
  Future<Announcement?> getAnnouncementById(String id);
  Future<void> deleteAnnouncement(String id);
  Future<void> archiveAnnouncement(String id);
  Future<void> restoreAnnouncement(String id);
  Future<void> cancelSchedule(String id);
}

class MockAnnouncementRepository implements AnnouncementRepository {
  final List<Announcement> _items = <Announcement>[];

  @override
  Future<Announcement> saveAnnouncement(Announcement announcement) async {
    await Future<void>.delayed(const Duration(milliseconds: 500));

    final normalized = announcement.copyWith(
      id: announcement.id.isEmpty
          ? 'announcement-${DateTime.now().microsecondsSinceEpoch}'
          : announcement.id,
      status: announcement.status,
      publishedAt: announcement.status == AnnouncementStatus.published
          ? (announcement.publishedAt ?? DateTime.now())
          : null,
      scheduledAt: announcement.status == AnnouncementStatus.scheduled
          ? announcement.scheduledAt
          : null,
      updatedAt: DateTime.now(),
    );

    final existingIndex = _items.indexWhere((item) => item.id == normalized.id);
    if (existingIndex >= 0) {
      _items[existingIndex] = normalized;
      return normalized;
    }
    _items.insert(0, normalized);
    return normalized;
  }

  @override
  Future<List<Announcement>> listAnnouncements() async {
    await Future<void>.delayed(const Duration(milliseconds: 200));
    return List<Announcement>.unmodifiable(_items);
  }

  @override
  Future<Announcement?> getAnnouncementById(String id) async =>
      _items.where((item) => item.id == id).firstOrNull;

  @override
  Future<void> deleteAnnouncement(String id) async =>
      _items.removeWhere((item) => item.id == id);

  @override
  Future<void> archiveAnnouncement(String id) async =>
      _changeStatus(id, AnnouncementStatus.archived);

  @override
  Future<void> restoreAnnouncement(String id) async =>
      _changeStatus(id, AnnouncementStatus.published);

  @override
  Future<void> cancelSchedule(String id) async =>
      _changeStatus(id, AnnouncementStatus.draft);

  void _changeStatus(String id, AnnouncementStatus status) {
    final index = _items.indexWhere((item) => item.id == id);
    if (index >= 0) {
      _items[index] = _items[index].copyWith(
        status: status,
        updatedAt: DateTime.now(),
      );
    }
  }
}

class FirestoreAnnouncementRepository implements AnnouncementRepository {
  FirestoreAnnouncementRepository({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  @override
  Future<Announcement> saveAnnouncement(Announcement announcement) async {
    final collection = _firestore.collection('announcements');
    final document = announcement.id.isEmpty
        ? collection.doc()
        : collection.doc(announcement.id);
    final saved = announcement.copyWith(
      id: document.id,
      updatedAt: DateTime.now(),
      publishedAt: announcement.status == AnnouncementStatus.published
          ? (announcement.publishedAt ?? DateTime.now())
          : null,
    );

    await document.set(saved.toMap());
    return saved;
  }

  @override
  Future<List<Announcement>> listAnnouncements() async {
    final snapshot = await _firestore
        .collection('announcements')
        .orderBy('createdAt', descending: true)
        .get();
    return snapshot.docs.map((doc) {
      return Announcement.fromMap({...doc.data(), 'id': doc.id});
    }).toList();
  }

  @override
  Future<Announcement?> getAnnouncementById(String id) async {
    final doc = await _firestore.collection('announcements').doc(id).get();
    if (!doc.exists || doc.data() == null) return null;
    return Announcement.fromMap({...doc.data()!, 'id': doc.id});
  }

  @override
  Future<void> deleteAnnouncement(String id) =>
      _firestore.collection('announcements').doc(id).delete();

  @override
  Future<void> archiveAnnouncement(String id) =>
      _setStatus(id, AnnouncementStatus.archived);

  @override
  Future<void> restoreAnnouncement(String id) =>
      _setStatus(id, AnnouncementStatus.published);

  @override
  Future<void> cancelSchedule(String id) =>
      _setStatus(id, AnnouncementStatus.draft);

  Future<void> _setStatus(String id, AnnouncementStatus status) =>
      _firestore.collection('announcements').doc(id).update({
        'status': status.value,
        'updatedAt': DateTime.now(),
        if (status == AnnouncementStatus.published)
          'publishedAt': DateTime.now(),
        if (status == AnnouncementStatus.draft) 'scheduledAt': null,
      });
}
