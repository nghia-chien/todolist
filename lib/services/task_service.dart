import 'dart:async';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/task.dart';
import '../models/task_list.dart';
import 'alarm_service.dart';

class TaskService extends ChangeNotifier {
  final AlarmService _alarmService;
  final SharedPreferences _prefs;
  List<TaskList> _taskLists = [];
  TaskList? _currentList;
  String _searchQuery = '';
  TaskFilter _currentFilter = TaskFilter.all;

  TaskService(this._prefs, this._alarmService) {
    _loadTaskLists();
  }

  List<TaskList> get taskLists => _taskLists;
  TaskList? get currentList => _currentList;
  String get searchQuery => _searchQuery;
  TaskFilter get currentFilter => _currentFilter;

  List<Task> get filteredTasks {
    if (_currentList == null) return [];
    
    var tasks = _currentList!.tasks;
    
    // Apply search filter
    if (_searchQuery.isNotEmpty) {
      tasks = _currentList!.searchTasks(_searchQuery);
    }
    
    // Apply status filter
    switch (_currentFilter) {
      case TaskFilter.all:
        break;
      case TaskFilter.active:
        tasks = tasks.where((task) => !task.isDone).toList();
        break;
      case TaskFilter.completed:
        tasks = tasks.where((task) => task.isDone).toList();
        break;
      case TaskFilter.overdue:
        tasks = tasks.where((task) => task.isOverdue).toList();
        break;
      case TaskFilter.dueToday:
        tasks = tasks.where((task) => task.isDueToday).toList();
        break;
    }
    
    // Sort by due date and priority
    tasks.sort((a, b) {
      if (a.dueDate == null && b.dueDate == null) {
        return b.priority.index.compareTo(a.priority.index);
      }
      if (a.dueDate == null) return 1;
      if (b.dueDate == null) return -1;
      return a.dueDate!.compareTo(b.dueDate!);
    });
    
    return tasks;
  }

  Future<void> _loadTaskLists() async {
    final jsonString = _prefs.getString('task_lists');
    if (jsonString != null) {
      final List<dynamic> jsonList = jsonDecode(jsonString);
      _taskLists = jsonList.map((json) => TaskList.fromJson(json)).toList();
      if (_taskLists.isNotEmpty) {
        _currentList = _taskLists.first;
      }
      notifyListeners();
    }
  }

  Future<void> _saveTaskLists() async {
    final jsonString = jsonEncode(_taskLists.map((list) => list.toJson()).toList());
    await _prefs.setString('task_lists', jsonString);
  }

  Future<void> createTaskList(String name, IconData icon, Color color) async {
    final newList = TaskList(
      name: name,
      icon: icon,
      color: color,
    );
    _taskLists.add(newList);
    if (_currentList == null) {
      _currentList = newList;
    }
    await _saveTaskLists();
    notifyListeners();
  }

  Future<void> updateTaskList(TaskList updatedList) async {
    final index = _taskLists.indexWhere((list) => list.id == updatedList.id);
    if (index != -1) {
      _taskLists[index] = updatedList;
      if (_currentList?.id == updatedList.id) {
        _currentList = updatedList;
      }
      await _saveTaskLists();
      notifyListeners();
    }
  }

  Future<void> deleteTaskList(String listId) async {
    _taskLists.removeWhere((list) => list.id == listId);
    if (_currentList?.id == listId) {
      _currentList = _taskLists.isNotEmpty ? _taskLists.first : null;
    }
    await _saveTaskLists();
    notifyListeners();
  }

  Future<void> setCurrentList(String listId) async {
    final list = _taskLists.firstWhere((list) => list.id == listId);
    _currentList = list;
    notifyListeners();
  }

  Future<void> addTask(Task task) async {
    if (_currentList == null) return;
    
    final updatedList = _currentList!.addTask(task);
    await updateTaskList(updatedList);
    
    if (task.setAlarm && task.dueDate != null) {
      await _alarmService.setAlarm(task);
    }
  }

  Future<void> updateTask(Task task) async {
    if (_currentList == null) return;
    
    final updatedList = _currentList!.updateTask(task);
    await updateTaskList(updatedList);
    
    if (task.setAlarm && task.dueDate != null) {
      await _alarmService.setAlarm(task);
    } else {
      await _alarmService.cancelAlarm(task.id);
    }
  }

  Future<void> deleteTask(String taskId) async {
    if (_currentList == null) return;
    
    final updatedList = _currentList!.deleteTask(taskId);
    await updateTaskList(updatedList);
    await _alarmService.cancelAlarm(taskId);
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void setFilter(TaskFilter filter) {
    _currentFilter = filter;
    notifyListeners();
  }

  Future<void> archiveTaskList(String listId) async {
    final list = _taskLists.firstWhere((list) => list.id == listId);
    final updatedList = list.archive();
    await updateTaskList(updatedList);
  }

  Future<void> unarchiveTaskList(String listId) async {
    final list = _taskLists.firstWhere((list) => list.id == listId);
    final updatedList = list.unarchive();
    await updateTaskList(updatedList);
  }
}

enum TaskFilter {
  all,
  active,
  completed,
  overdue,
  dueToday,
} 