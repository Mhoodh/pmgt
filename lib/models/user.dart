import 'package:flutter/foundation.dart';

class User {
  final int? id;
  final String name;
  final String email;
  final String password; // في التطبيق الحقيقي، يجب تشفير كلمة المرور
  final String? profileImage;
  final DateTime createdAt;
  final DateTime? lastLogin;

  User({
    this.id,
    required this.name,
    required this.email,
    required this.password,
    this.profileImage,
    DateTime? createdAt,
    this.lastLogin,
  }) : this.createdAt = createdAt ?? DateTime.now();

  // تحويل User إلى Map لحفظه في قاعدة البيانات
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'password': password, // في التطبيق الحقيقي، قم بتخزين كلمة المرور المشفرة
      'profile_image': profileImage,
      'created_at': createdAt.toIso8601String(),
      'last_login': lastLogin?.toIso8601String(),
    };
  }

  // إنشاء كائن User من Map مسترجع من قاعدة البيانات
  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id'],
      name: map['name'],
      email: map['email'],
      password: map['password'],
      profileImage: map['profile_image'],
      createdAt: map['created_at'] != null
          ? DateTime.parse(map['created_at'])
          : null,
      lastLogin: map['last_login'] != null
          ? DateTime.parse(map['last_login'])
          : null,
    );
  }

  // نسخة جديدة من المستخدم مع تحديث بعض الحقول
  User copyWith({
    int? id,
    String? name,
    String? email,
    String? password,
    String? profileImage,
    DateTime? createdAt,
    DateTime? lastLogin,
  }) {
    return User(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      password: password ?? this.password,
      profileImage: profileImage ?? this.profileImage,
      createdAt: createdAt ?? this.createdAt,
      lastLogin: lastLogin ?? this.lastLogin,
    );
  }

  @override
  String toString() {
    return 'User(id: $id, name: $name, email: $email)';
  }
}