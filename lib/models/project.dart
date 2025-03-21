import 'package:flutter/foundation.dart';

enum ProjectStatus {
  notStarted,
  inProgress,
  completed,
  delayed,
  cancelled,
}

class Project {
  final int? id;
  final String title;
  final String? description;
  final DateTime? startDate;
  final DateTime? endDate;
  final ProjectStatus status;
  final int userId;
  final DateTime createdAt;
  final DateTime? updatedAt;

  Project({
    this.id,
    required this.title,
    this.description,
    this.startDate,
    this.endDate,
    required this.status,
    required this.userId,
    DateTime? createdAt,
    this.updatedAt,
  }) : this.createdAt = createdAt ?? DateTime.now();

  // تحويل Project إلى Map لحفظه في قاعدة البيانات
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'start_date': startDate?.toIso8601String(),
      'end_date': endDate?.toIso8601String(),
      'status': status.toString().split('.').last,
      'user_id': userId,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  // إنشاء كائن Project من Map مسترجع من قاعدة البيانات
  factory Project.fromMap(Map<String, dynamic> map) {
    return Project(
      id: map['id'],
      title: map['title'],
      description: map['description'],
      startDate: map['start_date'] != null
          ? DateTime.parse(map['start_date'])
          : null,
      endDate: map['end_date'] != null
          ? DateTime.parse(map['end_date'])
          : null,
      status: _getStatusFromString(map['status']),
      userId: map['user_id'],
      createdAt: map['created_at'] != null
          ? DateTime.parse(map['created_at'])
          : null,
      updatedAt: map['updated_at'] != null
          ? DateTime.parse(map['updated_at'])
          : null,
    );
  }

  // مساعد لتحويل النص إلى حالة المشروع
  static ProjectStatus _getStatusFromString(String status) {
    switch (status) {
      case 'notStarted':
        return ProjectStatus.notStarted;
      case 'inProgress':
        return ProjectStatus.inProgress;
      case 'completed':
        return ProjectStatus.completed;
      case 'delayed':
        return ProjectStatus.delayed;
      case 'cancelled':
        return ProjectStatus.cancelled;
      default:
        return ProjectStatus.notStarted;
    }
  }

  // نسخة جديدة من المشروع مع تحديث بعض الحقول
  Project copyWith({
    int? id,
    String? title,
    String? description,
    DateTime? startDate,
    DateTime? endDate,
    ProjectStatus? status,
    int? userId,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Project(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      status: status ?? this.status,
      userId: userId ?? this.userId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() {
    return 'Project(id: $id, title: $title, status: $status)';
  }
}