import 'package:cloud_firestore/cloud_firestore.dart';

class LibraryBook {
  const LibraryBook({
    this.id = '',
    required this.title,
    required this.author,
    this.isbn = '',
    this.category = '',
    this.department = '',
    this.totalCopies = 0,
    this.availableCopies = 0,
    this.createdAt,
  });

  final String id;
  final String title;
  final String author;
  final String isbn;
  final String category;
  final String department;
  final int totalCopies;
  final int availableCopies;
  final DateTime? createdAt;

  int get issuedCopies => totalCopies - availableCopies;
  bool get isAvailable => availableCopies > 0;

  LibraryBook copyWith({
    String? id,
    String? title,
    String? author,
    String? isbn,
    String? category,
    String? department,
    int? totalCopies,
    int? availableCopies,
    DateTime? createdAt,
  }) => LibraryBook(
    id: id ?? this.id,
    title: title ?? this.title,
    author: author ?? this.author,
    isbn: isbn ?? this.isbn,
    category: category ?? this.category,
    department: department ?? this.department,
    totalCopies: totalCopies ?? this.totalCopies,
    availableCopies: availableCopies ?? this.availableCopies,
    createdAt: createdAt ?? this.createdAt,
  );

  factory LibraryBook.fromMap(Map<String, dynamic> map, String id) =>
      LibraryBook(
        id: id,
        title: map['title'] as String? ?? '',
        author: map['author'] as String? ?? '',
        isbn: map['isbn'] as String? ?? '',
        category: map['category'] as String? ?? '',
        department: map['department'] as String? ?? '',
        totalCopies: _integer(map['totalCopies']),
        availableCopies: _integer(map['availableCopies']),
        createdAt: _date(map['createdAt']),
      );

  Map<String, dynamic> toMap() => {
    'title': title,
    'author': author,
    'isbn': isbn,
    'category': category,
    'department': department,
    'totalCopies': totalCopies,
    'availableCopies': availableCopies,
    'createdAt': createdAt ?? FieldValue.serverTimestamp(),
  };

  static int _integer(dynamic value) => value is num ? value.round() : 0;

  static DateTime? _date(dynamic value) => value is Timestamp
      ? value.toDate()
      : value is DateTime
      ? value
      : null;
}

class LibraryStatistics {
  const LibraryStatistics({
    required this.totalBooks,
    required this.availableBooks,
    required this.issuedBooks,
    required this.overdueBooks,
  });

  final int totalBooks;
  final int availableBooks;
  final int issuedBooks;
  final int overdueBooks;
}
