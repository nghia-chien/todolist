import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import '../models/task_model.dart';
import '../models/priority.dart';

class TaskDatabase {
  static Database? _db;
  static const String tableName = 'tasks';

  static Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await initDB();
    return _db!;
  }

  static Future<Database> initDB() async {
    Directory documentsDir = await getApplicationDocumentsDirectory();
    String path = join(documentsDir.path, 'task.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: (Database db, int version) async {
        await db.execute('''
          CREATE TABLE $tableName (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            title TEXT NOT NULL,
            description TEXT,
            startTime TEXT,
            dueDate TEXT,
            setAlarm INTEGER NOT NULL,
            priority INTEGER NOT NULL,
            isDone INTEGER NOT NULL,
            completedAt TEXT,
            createdAt TEXT NOT NULL,
            tags TEXT NOT NULL
          )
        ''');
      },
    );
  }

  static Future<int> insertTask(Task task) async {
    final db = await database;
    return await db.insert(tableName, task.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  static Future<List<Task>> getTasks() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(tableName);
    return maps.map((map) => Task.fromMap(map)).toList();
  }

  static Future<int> updateTask(Task task) async {
    final db = await database;
    return await db.update(
      tableName,
      task.toMap(),
      where: 'id = ?',
      whereArgs: [task.id],
    );
  }

  static Future<int> deleteTask(int id) async {
    final db = await database;
    return await db.delete(
      tableName,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  static Future<List<Task>> getTasksByPriority(Priority priority) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      tableName,
      where: 'priority = ?',
      whereArgs: [priority.index],
    );
    return maps.map((map) => Task.fromMap(map)).toList();
  }

  static Future<List<Task>> getTasksByTag(String tag) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(tableName);
    return maps
        .map((map) => Task.fromMap(map))
        .where((task) => task.tags.contains(tag))
        .toList();
  }

  static Future<List<Task>> searchTasks(String query) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(tableName);
    final lowercaseQuery = query.toLowerCase();
    return maps
        .map((map) => Task.fromMap(map))
        .where((task) {
          return task.title.toLowerCase().contains(lowercaseQuery) ||
              (task.description?.toLowerCase().contains(lowercaseQuery) ?? false) ||
              task.tags.any((tag) => tag.toLowerCase().contains(lowercaseQuery));
        })
        .toList();
  }
} 