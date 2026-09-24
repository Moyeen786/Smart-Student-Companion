import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:smart_student_companion/features/admin/domain/models/admin_models.dart';

abstract class AnnouncementRepository {
  Future<void> saveAnnouncement(
    Announcement announcement, {
    required bool publish,
  });

  Future<List<Announcement>> listAnnouncements();
}

class MockAnnouncementRepository implements AnnouncementRepository {
  final List<Announcement> _items = <Announcement>[];

  @override
  Future<void> saveAnnouncement(
    Announcement announcement, {
    required bool publish,
  }) async {
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
    );

    final existingIndex = _items.indexWhere((item) => item.id == normalized.id);
    if (existingIndex >= 0) {
      _items[existingIndex] = normalized;
      return;
    }
    _items.insert(0, normalized);
  }

  @override
  Future<List<Announcement>> listAnnouncements() async {
    await Future<void>.delayed(const Duration(milliseconds: 200));
    return List<Announcement>.unmodifiable(_items);
  }
}

class FirestoreAnnouncementRepository implements AnnouncementRepository {
  FirestoreAnnouncementRepository({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  @override
  Future<void> saveAnnouncement(
    Announcement announcement, {
    required bool publish,
  }) async {
    final collection = _firestore.collection('announcements');
    final document = announcement.id.isEmpty
        ? collection.doc()
        : collection.doc(announcement.id);
    final saved = announcement.copyWith(id: document.id);

    await document.set(saved.toMap());
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
}
