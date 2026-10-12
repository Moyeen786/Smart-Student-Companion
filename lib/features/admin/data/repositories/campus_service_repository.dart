import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:smart_student_companion/features/admin/domain/models/campus_service_models.dart';

abstract class CampusServiceRepository {
  Future<List<CampusServiceRecord>> records(CampusServiceKind kind);
  Future<List<CampusServiceRecord>> approvedLostFound();
  Future<List<CampusServiceRecord>> myLostFoundReports(String userId);
  Future<void> save(CampusServiceRecord record);
  Future<void> submitLostFoundReport(CampusServiceRecord record);
  Future<void> updatePendingLostFoundReport(CampusServiceRecord record);
  Future<void> delete(CampusServiceRecord record);
  Future<void> updateStatus(
    CampusServiceRecord record,
    CampusRecordStatus status, {
    String? reviewedBy,
  });
}

class FirestoreCampusServiceRepository implements CampusServiceRepository {
  FirestoreCampusServiceRepository({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> _collection(
    CampusServiceKind kind,
  ) => _firestore.collection(kind.collection);

  @override
  Future<List<CampusServiceRecord>> records(CampusServiceKind kind) async {
    final snapshot = await _collection(kind)
        .orderBy('createdAt', descending: true)
        .get();
    return snapshot.docs
        .map((doc) => CampusServiceRecord.fromMap(doc.data(), doc.id, kind))
        .toList();
  }

  @override
  Future<List<CampusServiceRecord>> approvedLostFound() async {
    final snapshot = await _collection(CampusServiceKind.lostFound)
        .where('status', isEqualTo: CampusRecordStatus.approved.name)
        .get();
    final records = snapshot.docs
        .map(
          (doc) => CampusServiceRecord.fromMap(
            doc.data(),
            doc.id,
            CampusServiceKind.lostFound,
          ),
        )
        .toList();
    records.sort(_newestFirst);
    return records;
  }

  @override
  Future<List<CampusServiceRecord>> myLostFoundReports(String userId) async {
    final snapshot = await _collection(CampusServiceKind.lostFound)
        .where('reportedByUserId', isEqualTo: userId)
        .get();
    final records = snapshot.docs
        .map(
          (doc) => CampusServiceRecord.fromMap(
            doc.data(),
            doc.id,
            CampusServiceKind.lostFound,
          ),
        )
        .toList();
    records.sort(_newestFirst);
    return records;
  }

  @override
  Future<void> save(CampusServiceRecord record) async {
    final collection = _collection(record.kind);
    final document = record.id.isEmpty
        ? collection.doc()
        : collection.doc(record.id);
    await document.set(record.toMap(), SetOptions(merge: true));
  }

  @override
  Future<void> submitLostFoundReport(CampusServiceRecord record) async {
    final document = _collection(CampusServiceKind.lostFound).doc();
    await document.set({
      ...record.toMap(),
      'status': CampusRecordStatus.pending.name,
      'reportedByUserId': record.reportedByUserId,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  @override
  Future<void> updatePendingLostFoundReport(CampusServiceRecord record) =>
      _collection(CampusServiceKind.lostFound).doc(record.id).update({
        ...record.toMap(),
        'status': CampusRecordStatus.pending.name,
        'updatedAt': FieldValue.serverTimestamp(),
      });

  @override
  Future<void> delete(CampusServiceRecord record) =>
      _collection(record.kind).doc(record.id).delete();

  @override
  Future<void> updateStatus(
    CampusServiceRecord record,
    CampusRecordStatus status, {
    String? reviewedBy,
  }) => _collection(record.kind).doc(record.id).update({
    'status': status.name,
    'updatedAt': FieldValue.serverTimestamp(),
    ...?reviewedBy == null
        ? null
        : {
            'reviewedBy': reviewedBy,
            'reviewedAt': FieldValue.serverTimestamp(),
          },
  });

  int _newestFirst(CampusServiceRecord left, CampusServiceRecord right) {
    final leftDate = left.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
    final rightDate = right.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
    return rightDate.compareTo(leftDate);
  }
}
