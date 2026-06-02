enum UserRole { admin, user }

class UserModel {
  const UserModel({
    required this.uid,
    required this.name,
    required this.email,
    required this.role,
  });

  final String uid;
  final String name;
  final String email;
  final UserRole role;

  bool get isAdmin => role == UserRole.admin;

  factory UserModel.fromMap({
    required String uid,
    required Map<String, dynamic> data,
  }) {
    return UserModel(
      uid: uid,
      name: (data['name'] ?? '') as String,
      email: (data['email'] ?? '') as String,
      role: (data['role'] ?? 'user') == 'admin' ? UserRole.admin : UserRole.user,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'name': name,
      'email': email,
      'role': role == UserRole.admin ? 'admin' : 'user',
    };
  }

  UserModel copyWith({
    String? uid,
    String? name,
    String? email,
    UserRole? role,
  }) {
    return UserModel(
      uid: uid ?? this.uid,
      name: name ?? this.name,
      email: email ?? this.email,
      role: role ?? this.role,
    );
  }
}
