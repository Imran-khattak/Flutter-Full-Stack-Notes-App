class UserModel {
  final String? id; // Make nullable
  final String? username;
  final String? email;
  final String? password;
  final String? uid; // Make nullable

  UserModel({
    this.id, // Remove required
    this.username,
    this.email,
    this.password,
    this.uid, // Remove required
  });

  // Factory constructor to create User from JSON
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['_id']?.toString(), // Handle potential ObjectId
      username: json['username'] ?? '',
      email: json['email'] ?? '',
      password: json['password'] ?? '',
      uid: json['uid']?.toString(),
    );
  }
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {'username': username, 'email': email};

    // Include password if it's not null and not empty
    if (password != null && password!.isNotEmpty) {
      data['password'] = password;
    }

    // Only include _id if it's not null and not empty
    if (id != null && id!.isNotEmpty) {
      data['_id'] = id;
    }

    // Only include uid if it's not null and not empty
    if (uid != null && uid!.isNotEmpty) {
      data['uid'] = uid;
    }

    return data;
  }

  // Method to create a copy of User with updated fields
  UserModel copyWith({
    String? id,
    String? username,
    String? email,
    String? password,
    String? uid,
  }) {
    return UserModel(
      id: id ?? this.id,
      username: username ?? this.username,
      email: email ?? this.email,
      password: password ?? this.password,
      uid: uid ?? this.uid,
    );
  }

  // Override toString for better debugging
  @override
  String toString() {
    return 'User(id: $id, username: $username, email: $email, uid: $uid)';
  }

  // Override equality operators
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is UserModel &&
        other.id == id &&
        other.username == username &&
        other.email == email &&
        other.password == password &&
        other.uid == uid;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        username.hashCode ^
        email.hashCode ^
        password.hashCode ^
        uid.hashCode;
  }
}
