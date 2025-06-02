import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'task.dart';
import 'priority.dart' as priority_model;

class TaskList {
  final String id;
  final String name;
  final IconData icon;
  final Color color;
  final List<Task> tasks;
  final DateTime createdAt;
  final DateTime? archivedAt;

  TaskList({
    String? id,
    required this.name,
    required this.icon,
    required this.color,
    List<Task>? tasks,
    DateTime? createdAt,
    this.archivedAt,
  })  : id = id ?? const Uuid().v4(),
        tasks = tasks ?? [],
        createdAt = createdAt ?? DateTime.now();

  TaskList copyWith({
    String? id,
    String? name,
    IconData? icon,
    Color? color,
    List<Task>? tasks,
    DateTime? createdAt,
    DateTime? archivedAt,
  }) {
    return TaskList(
      id: id ?? this.id,
      name: name ?? this.name,
      icon: icon ?? this.icon,
      color: color ?? this.color,
      tasks: tasks ?? this.tasks,
      createdAt: createdAt ?? this.createdAt,
      archivedAt: archivedAt ?? this.archivedAt,
    );
  }

  bool get isArchived => archivedAt != null;

  List<Task> get activeTasks => tasks.where((task) => !task.isDone).toList();
  List<Task> get completedTasks => tasks.where((task) => task.isDone).toList();
  List<Task> get overdueTasks => tasks.where((task) => task.isOverdue).toList();
  List<Task> get dueTodayTasks => tasks.where((task) => task.isDueToday).toList();

  List<Task> getTasksByPriority(priority_model.Priority priority) {
    return tasks.where((task) => task.priority == priority).toList();
  }

  List<Task> getTasksByTag(String tag) {
    return tasks.where((task) => task.tags.contains(tag)).toList();
  }

  List<Task> searchTasks(String query) {
    final lowercaseQuery = query.toLowerCase();
    return tasks.where((task) {
      return task.title.toLowerCase().contains(lowercaseQuery) ||
          (task.description?.toLowerCase().contains(lowercaseQuery) ?? false) ||
          task.tags.any((tag) => tag.toLowerCase().contains(lowercaseQuery));
    }).toList();
  }

  TaskList addTask(Task task) {
    return copyWith(tasks: [...tasks, task]);
  }

  TaskList updateTask(Task updatedTask) {
    final index = tasks.indexWhere((task) => task.id == updatedTask.id);
    if (index == -1) return this;
    
    final newTasks = List<Task>.from(tasks);
    newTasks[index] = updatedTask;
    return copyWith(tasks: newTasks);
  }

  TaskList deleteTask(String taskId) {
    return copyWith(
      tasks: tasks.where((task) => task.id != taskId).toList(),
    );
  }

  TaskList archive() {
    return copyWith(archivedAt: DateTime.now());
  }

  TaskList unarchive() {
    return copyWith(archivedAt: null);
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'icon': icon.codePoint,
      'iconFamily': icon.fontFamily,
      'iconPackage': icon.fontPackage,
      'color': color.value,
      'tasks': tasks.map((task) => task.toJson()).toList(),
      'createdAt': createdAt.toIso8601String(),
      'archivedAt': archivedAt?.toIso8601String(),
    };
  }

  factory TaskList.fromJson(Map<String, dynamic> json) {
    return TaskList(
      id: json['id'] as String,
      name: json['name'] as String,
      icon: IconData(
        json['icon'] as int,
        fontFamily: json['iconFamily'] as String?,
        fontPackage: json['iconPackage'] as String?,
      ),
      color: Color(json['color'] as int),
      tasks: (json['tasks'] as List)
          .map((taskJson) => Task.fromJson(taskJson as Map<String, dynamic>))
          .toList(),
      createdAt: DateTime.parse(json['createdAt'] as String),
      archivedAt: json['archivedAt'] != null
          ? DateTime.parse(json['archivedAt'] as String)
          : null,
    );
  }
} 