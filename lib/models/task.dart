import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'priority.dart';

class Task {
  final String id;
  final String title;
  final String? description;
  final DateTime? startTime;
  final DateTime? dueDate;
  final bool setAlarm;
  final Priority priority;
  final bool isDone;
  final List<String> tags;
  final DateTime createdAt;
  final DateTime? completedAt;

  Task({
    required this.id,
    required this.title,
    this.description,
    this.startTime,
    this.dueDate,
    this.setAlarm = false,
    required this.priority,
    this.isDone = false,
    this.tags = const [],
    DateTime? createdAt,
    this.completedAt,
  }) : createdAt = createdAt ?? DateTime.now();

  Task copyWith({
    String? id,
    String? title,
    String? description,
    DateTime? startTime,
    DateTime? dueDate,
    bool? setAlarm,
    Priority? priority,
    bool? isDone,
    List<String>? tags,
    DateTime? createdAt,
    DateTime? completedAt,
  }) {
    return Task(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      startTime: startTime ?? this.startTime,
      dueDate: dueDate ?? this.dueDate,
      setAlarm: setAlarm ?? this.setAlarm,
      priority: priority ?? this.priority,
      isDone: isDone ?? this.isDone,
      tags: tags ?? this.tags,
      createdAt: createdAt ?? this.createdAt,
      completedAt: completedAt ?? this.completedAt,
    );
  }

  Task clone() {
    return Task(
      id: const Uuid().v4(), // có thể dùng `id: id` nếu không cần thay đổi
      title: title,
      description: description,
      startTime: startTime,
      dueDate: dueDate,
      setAlarm: setAlarm,
      priority: priority,
      isDone: isDone,
      tags: List<String>.from(tags),
      createdAt: createdAt,
      completedAt: completedAt,
    );
  }

  bool get isOverdue {
    if (dueDate == null || isDone) return false;
    return DateTime.now().isAfter(dueDate!);
  }

  bool get isDueToday {
    if (dueDate == null) return false;
    final now = DateTime.now();
    return dueDate!.year == now.year &&
        dueDate!.month == now.month &&
        dueDate!.day == now.day;
  }

  Duration? get remainingTime {
    if (dueDate == null || isDone) return null;
    return dueDate!.difference(DateTime.now());
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'startTime': startTime?.toIso8601String(),
      'dueDate': dueDate?.toIso8601String(),
      'setAlarm': setAlarm,
      'priority': priority.index,
      'isDone': isDone,
      'tags': tags,
      'createdAt': createdAt.toIso8601String(),
      'completedAt': completedAt?.toIso8601String(),
    };
  }

  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String?,
      startTime: json['startTime'] != null
          ? DateTime.parse(json['startTime'] as String)
          : null,
      dueDate: json['dueDate'] != null
          ? DateTime.parse(json['dueDate'] as String)
          : null,
      setAlarm: json['setAlarm'] as bool,
      priority: Priority.values[json['priority'] as int],
      isDone: json['isDone'] as bool,
      tags: (json['tags'] as List).map((e) => e as String).toList(),
      createdAt: DateTime.parse(json['createdAt'] as String),
      completedAt: json['completedAt'] != null
          ? DateTime.parse(json['completedAt'] as String)
          : null,
    );
  }
}
