import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:smart_student_companion/features/admin/domain/models/library_models.dart';

abstract class LibraryRepository {
  Future<List<LibraryBook>> books();
  Future<void> saveBook(LibraryBook book);
  Future<void> deleteBook(String id);
  Future<LibraryStatistics> statistics();
}

class FirestoreLibraryRepository implements LibraryRepository {
  FirestoreLibraryRepository({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _collection =>
      _firestore.collection('library_books');

  @override
  Future<List<LibraryBook>> books() async {
    final snapshot = await _collection.orderBy('title').get();
    return snapshot.docs
        .map((doc) => LibraryBook.fromMap(doc.data(), doc.id))
        .toList();
  }

  @override
  Future<void> saveBook(LibraryBook book) async {
    final document = book.id.isEmpty ? _collection.doc() : _collection.doc(book.id);
    await document.set(book.toMap(), SetOptions(merge: true));
  }

  @override
  Future<void> deleteBook(String id) => _collection.doc(id).delete();

  @override
  Future<LibraryStatistics> statistics() async {
    final snapshot = await _collection.get();
    var total = 0;
    var available = 0;
    for (final doc in snapshot.docs) {
      final book = LibraryBook.fromMap(doc.data(), doc.id);
      total += book.totalCopies;
      available += book.availableCopies;
    }
    return LibraryStatistics(
      totalBooks: snapshot.size,
      availableBooks: available,
      issuedBooks: total - available,
      overdueBooks: 0,
    );
  }
}
