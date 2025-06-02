import 'package:flutter/material.dart';
import 'priority.dart';

class Task {
  int? id;
  String title;
  String? description;
  DateTime? startTime;
  DateTime? dueDate;
  bool setAlarm;
  Priority priority;
  bool isDone;
  DateTime? completedAt;
  DateTime createdAt;
  List<String> tags;

  Task({
    this.id,
    required this.title,
    this.description,
    this.startTime,
    this.dueDate,
    this.setAlarm = false,
    required this.priority,
    this.isDone = false,
    this.completedAt,
    DateTime? createdAt,
    List<String>? tags,
  })  : createdAt = createdAt ?? DateTime.now(),
        tags = tags ?? [];

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

  Task copyWith({
    int? id,
    String? title,
    String? description,
    DateTime? startTime,
    DateTime? dueDate,
    bool? setAlarm,
    Priority? priority,
    bool? isDone,
    DateTime? completedAt,
    DateTime? createdAt,
    List<String>? tags,
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
      completedAt: completedAt ?? this.completedAt,
      createdAt: createdAt ?? this.createdAt,
      tags: tags ?? this.tags,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'startTime': startTime?.toIso8601String(),
      'dueDate': dueDate?.toIso8601String(),
      'setAlarm': setAlarm ? 1 : 0,
      'priority': priority.index,
      'isDone': isDone ? 1 : 0,
      'completedAt': completedAt?.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
      'tags': tags.join(','),
    };
  }

  factory Task.fromMap(Map<String, dynamic> map) {
    return Task(
      id: map['id'] as int?,
      title: map['title'] as String,
      description: map['description'] as String?,
      startTime: map['startTime'] != null
          ? DateTime.parse(map['startTime'] as String)
          : null,
      dueDate: map['dueDate'] != null
          ? DateTime.parse(map['dueDate'] as String)
          : null,
      setAlarm: map['setAlarm'] == 1,
      priority: Priority.values[map['priority'] as int],
      isDone: map['isDone'] == 1,
      completedAt: map['completedAt'] != null
          ? DateTime.parse(map['completedAt'] as String)
          : null,
      createdAt: DateTime.parse(map['createdAt'] as String),
      tags: (map['tags'] as String).split(',').where((tag) => tag.isNotEmpty).toList(),
    );
  }
} 