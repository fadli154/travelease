import 'package:cloud_firestore/cloud_firestore.dart';

enum UserRole { admin, user }

class UserModel {
  const UserModel({
    required this.uid,
    required this.name,
    required this.email,
    required this.role,
    this.photoUrl = '',
    this.createdAt,
  });

  final String uid;
  final String name;
  final String email;
  final UserRole role;
  final String photoUrl;
  final DateTime? createdAt;

  bool get isAdmin => role == UserRole.admin;

  factory UserModel.fromMap({
    required String uid,
    required Map<String, dynamic> data,
  }) {
    final createdAtRaw = data['createdAt'];
    return UserModel(
      uid: uid,
      name: (data['name'] ?? '') as String,
      email: (data['email'] ?? '') as String,
      role: (data['role'] ?? 'user') == 'admin' ? UserRole.admin : UserRole.user,
      photoUrl: (data['photoUrl'] ?? '') as String,
      createdAt: createdAtRaw is Timestamp ? createdAtRaw.toDate() : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'name': name,
      'email': email,
      'role': role == UserRole.admin ? 'admin' : 'user',
      'photoUrl': photoUrl,
      'createdAt': createdAt != null
          ? Timestamp.fromDate(createdAt!)
          : FieldValue.serverTimestamp(),
    };
  }

  UserModel copyWith({
    String? uid,
    String? name,
    String? email,
    UserRole? role,
    String? photoUrl,
    DateTime? createdAt,
  }) {
    return UserModel(
      uid: uid ?? this.uid,
      name: name ?? this.name,
      email: email ?? this.email,
      role: role ?? this.role,
      photoUrl: photoUrl ?? this.photoUrl,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
