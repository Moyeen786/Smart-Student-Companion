enum UserRole { student, faculty, parent, admin }

extension UserRoleExtension on UserRole {
  String toFirestoreValue() {
    switch (this) {
      case UserRole.student:
        return 'student';
      case UserRole.faculty:
        return 'faculty';
      case UserRole.parent:
        return 'parent';
      case UserRole.admin:
        return 'admin';
    }
  }

  static UserRole fromFirestoreValue(String? value) {
    switch (value) {
      case 'student':
        return UserRole.student;
      case 'teacher':
      case 'faculty':
        return UserRole.faculty;
      case 'parent':
        return UserRole.parent;
      case 'admin':
        return UserRole.admin;
      default:
        return UserRole.student;
    }
  }
}

class UserModel {
  const UserModel({
    required this.uid,
    required this.name,
    required this.email,
    required this.role,
    required this.department,
    required this.semester,
    required this.createdAt,
    this.rollNumber = '',
  });

  final String uid;
  final String name;
  final String email;
  final UserRole role;
  final String department;
  final int semester;
  final DateTime createdAt;
  final String rollNumber;

  UserModel copyWith({
    String? uid,
    String? name,
    String? email,
    UserRole? role,
    String? department,
    int? semester,
    DateTime? createdAt,
    String? rollNumber,
  }) {
    return UserModel(
      uid: uid ?? this.uid,
      name: name ?? this.name,
      email: email ?? this.email,
      role: role ?? this.role,
      department: department ?? this.department,
      semester: semester ?? this.semester,
      createdAt: createdAt ?? this.createdAt,
      rollNumber: rollNumber ?? this.rollNumber,
    );
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      uid: map['uid'] as String? ?? '',
      name: map['name'] as String? ?? '',
      email: map['email'] as String? ?? '',
      role: UserRoleExtension.fromFirestoreValue(map['role'] as String?),
      department: map['department'] as String? ?? '',
      semester: map['semester'] as int? ?? 0,
      createdAt: map['createdAt'] is DateTime
          ? map['createdAt'] as DateTime
          : DateTime.now(),
      rollNumber:
          map['rollNumber'] as String? ?? map['accountId'] as String? ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'name': name,
      'email': email,
      'role': role.toFirestoreValue(),
      'department': department,
      'semester': semester,
      'createdAt': createdAt,
      'rollNumber': rollNumber,
    };
  }
}
