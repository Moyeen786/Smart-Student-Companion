import 'package:cloud_firestore/cloud_firestore.dart';

enum CampusServiceKind { placements, events, lostFound }

enum CampusRecordStatus {
  draft,
  published,
  archived,
  pending,
  approved,
  rejected,
  lost,
  found,
  claimed,
  resolved,
}

extension CampusServiceKindLabel on CampusServiceKind {
  String get collection => switch (this) {
    CampusServiceKind.placements => 'placements',
    CampusServiceKind.events => 'events',
    CampusServiceKind.lostFound => 'lost_found',
  };

  String get label => switch (this) {
    CampusServiceKind.placements => 'Placements',
    CampusServiceKind.events => 'Events',
    CampusServiceKind.lostFound => 'Lost & Found',
  };
}

extension CampusRecordStatusLabel on CampusRecordStatus {
  String get label => switch (this) {
    CampusRecordStatus.draft => 'Draft',
    CampusRecordStatus.published => 'Published',
    CampusRecordStatus.archived => 'Archived',
    CampusRecordStatus.pending => 'Pending review',
    CampusRecordStatus.approved => 'Approved',
    CampusRecordStatus.rejected => 'Rejected',
    CampusRecordStatus.lost => 'Lost',
    CampusRecordStatus.found => 'Found',
    CampusRecordStatus.claimed => 'Claimed',
    CampusRecordStatus.resolved => 'Resolved',
  };

  static CampusRecordStatus fromValue(String? value) =>
      CampusRecordStatus.values.firstWhere(
        (status) => status.name == value,
        orElse: () => CampusRecordStatus.draft,
      );
}

class CampusServiceRecord {
  const CampusServiceRecord({
    this.id = '',
    required this.kind,
    required this.name,
    this.description = '',
    this.secondary = '',
    this.status = CampusRecordStatus.draft,
    this.date = '',
    this.details = const <String, String>{},
    this.createdAt,
    this.updatedAt,
    this.type = '',
    this.category = '',
    this.time = '',
    this.color = '',
    this.imageUrl,
    this.reportedBy = '',
    this.reportedByUserId = '',
    this.contact = '',
    this.reviewedBy,
    this.reviewedAt,
  });

  final String id;
  final CampusServiceKind kind;
  final String name;
  final String description;
  final String secondary;
  final CampusRecordStatus status;
  final String date;
  final Map<String, String> details;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final String type;
  final String category;
  final String time;
  final String color;
  final String? imageUrl;
  final String reportedBy;
  final String reportedByUserId;
  final String contact;
  final String? reviewedBy;
  final DateTime? reviewedAt;

  CampusServiceRecord copyWith({
    String? id,
    CampusServiceKind? kind,
    String? name,
    String? description,
    String? secondary,
    CampusRecordStatus? status,
    String? date,
    Map<String, String>? details,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? type,
    String? category,
    String? time,
    String? color,
    String? imageUrl,
    String? reportedBy,
    String? reportedByUserId,
    String? contact,
    String? reviewedBy,
    DateTime? reviewedAt,
  }) => CampusServiceRecord(
    id: id ?? this.id,
    kind: kind ?? this.kind,
    name: name ?? this.name,
    description: description ?? this.description,
    secondary: secondary ?? this.secondary,
    status: status ?? this.status,
    date: date ?? this.date,
    details: details ?? this.details,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    type: type ?? this.type,
    category: category ?? this.category,
    time: time ?? this.time,
    color: color ?? this.color,
    imageUrl: imageUrl ?? this.imageUrl,
    reportedBy: reportedBy ?? this.reportedBy,
    reportedByUserId: reportedByUserId ?? this.reportedByUserId,
    contact: contact ?? this.contact,
    reviewedBy: reviewedBy ?? this.reviewedBy,
    reviewedAt: reviewedAt ?? this.reviewedAt,
  );

  factory CampusServiceRecord.fromMap(
    Map<String, dynamic> map,
    String id,
    CampusServiceKind kind,
  ) => CampusServiceRecord(
    id: id,
    kind: kind,
    name: map['name'] as String? ?? '',
    description: map['description'] as String? ?? '',
    secondary: map['secondary'] as String? ?? '',
    status: CampusRecordStatusLabel.fromValue(map['status'] as String?),
    date: map['date'] as String? ?? '',
    details:
        (map['details'] as Map?)?.map(
          (key, value) => MapEntry('$key', '$value'),
        ) ??
        const <String, String>{},
    createdAt: map['createdAt'] is Timestamp
        ? (map['createdAt'] as Timestamp).toDate()
        : map['createdAt'] as DateTime?,
    updatedAt: map['updatedAt'] is Timestamp
        ? (map['updatedAt'] as Timestamp).toDate()
        : map['updatedAt'] as DateTime?,
    type: map['type'] as String? ?? '',
    category: map['category'] as String? ?? '',
    time: map['time'] as String? ?? '',
    color: map['color'] as String? ?? '',
    imageUrl: map['imageUrl'] as String?,
    reportedBy: map['reportedBy'] as String? ?? '',
    reportedByUserId: map['reportedByUserId'] as String? ?? '',
    contact: map['contact'] as String? ?? '',
    reviewedBy: map['reviewedBy'] as String?,
    reviewedAt: map['reviewedAt'] is Timestamp
        ? (map['reviewedAt'] as Timestamp).toDate()
        : map['reviewedAt'] as DateTime?,
  );

  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{
      'name': name,
      'description': description,
      'secondary': secondary,
      'status': status.name,
      'date': date,
      'details': details,
      'createdAt': createdAt ?? FieldValue.serverTimestamp(),
    };
    if (kind == CampusServiceKind.lostFound) {
      map.addAll({
        'updatedAt': updatedAt ?? FieldValue.serverTimestamp(),
        'type': type,
        'category': category,
        'time': time,
        'color': color,
        'imageUrl': imageUrl,
        'reportedBy': reportedBy,
        'reportedByUserId': reportedByUserId,
        'contact': contact,
        'reviewedBy': reviewedBy,
        'reviewedAt': reviewedAt,
      });
    }
    return map;
  }
}
