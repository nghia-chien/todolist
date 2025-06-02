import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../models/task.dart';
import '../services/alarm_service.dart';
import 'screens/chatbot_page.dart';
import '../../models/priority.dart' as priority_model;

class TodoHomePage extends StatefulWidget {
  const TodoHomePage({super.key});

  @override
  State<TodoHomePage> createState() => _TodoHomePageState();
}

class _TodoHomePageState extends State<TodoHomePage> {
  final List<Task> _tasks = [];
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  DateTime? _selectedTime;
  DateTime? _selectedDueDate;
  bool _setAlarm = false;
  ThemeMode _themeMode = ThemeMode.system;
  priority_model.Priority _selectedPriority = priority_model.Priority.normal;
  String _searchQuery = '';
  TaskFilter _currentFilter = TaskFilter.all;

  void _addTask() async {
    final title = _titleController.text.trim();
    if (title.isEmpty) return;

    final newTask = Task(
      id: const Uuid().v4(),
      title: title,
      description: _descriptionController.text.trim(),
      startTime: _selectedTime,
      dueDate: _selectedDueDate,
      setAlarm: _setAlarm,
      priority: _selectedPriority,
    );

    if (newTask.setAlarm && newTask.startTime != null) {
      try {
        await AlarmService.setPlatformAlarm(newTask.startTime!, newTask.title);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Báo thức đã được tạo (không thể xoá)'),
            backgroundColor: Colors.orange,
          ),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi khi tạo báo thức: $e'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }
    }

    setState(() {
      _tasks.add(newTask);
      _resetForm();
    });
  }

  void _resetForm() {
    _titleController.clear();
    _descriptionController.clear();
    _selectedTime = null;
    _selectedDueDate = null;
    _setAlarm = false;
    _selectedPriority = priority_model.Priority.normal;
  }

  void _markDone(String id) {
    setState(() {
      final taskIndex = _tasks.indexWhere((task) => task.id == id);
      if (taskIndex != -1) {
        _tasks[taskIndex] = _tasks[taskIndex].copyWith(
          isDone: true,
          completedAt: DateTime.now(),
        );
      }
    });
  }

  void _deleteTask(String id) {
    setState(() {
      _tasks.removeWhere((task) => task.id == id);
    });
  }

  Future<void> _pickTime() async {
    final now = TimeOfDay.now();
    final picked = await showTimePicker(context: context, initialTime: now);
    if (picked != null) {
      final nowDate = DateTime.now();
      setState(() {
        _selectedTime = DateTime(
          nowDate.year,
          nowDate.month,
          nowDate.day,
          picked.hour,
          picked.minute,
        );
      });
    }
  }

  Future<void> _pickDueDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: now,
      lastDate: now.add(const Duration(days: 365)),
    );
    if (picked != null) {
      setState(() {
        _selectedDueDate = picked;
      });
    }
  }

  void _showTaskDetails(Task task) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        maxChildSize: 0.95,
        minChildSize: 0.5,
        builder: (context, scrollController) => Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                task.title,
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              if (task.description != null) ...[
                const SizedBox(height: 8),
                Text(task.description!),
              ],
              const SizedBox(height: 16),
              Row(
                children: [
                  Icon(Icons.flag, color: task.priority.color),
                  const SizedBox(width: 8),
                  Text('Độ ưu tiên: ${task.priority.label}'),
                ],
              ),
              if (task.startTime != null) ...[
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.access_time),
                    const SizedBox(width: 8),
                    Text(
                      'Bắt đầu: ${task.startTime!.hour}:${task.startTime!.minute.toString().padLeft(2, '0')}',
                    ),
                  ],
                ),
              ],
              if (task.dueDate != null) ...[
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.calendar_today),
                    const SizedBox(width: 8),
                    Text(
                      'Hạn cuối: ${task.dueDate!.day}/${task.dueDate!.month}/${task.dueDate!.year}',
                    ),
                  ],
                ),
              ],
              const Spacer(),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                      _deleteTask(task.id);
                    },
                    icon: const Icon(Icons.delete),
                    label: const Text('Xóa'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                    ),
                  ),
                  if (!task.isDone)
                    ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pop(context);
                        _markDone(task.id);
                      },
                      icon: const Icon(Icons.check),
                      label: const Text('Hoàn thành'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<Task> get _filteredTasks {
    return _tasks.where((task) {
      final matchesSearch = task.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          (task.description?.toLowerCase().contains(_searchQuery.toLowerCase()) ?? false);

      final matchesFilter = switch (_currentFilter) {
        TaskFilter.all => true,
        TaskFilter.active => !task.isDone,
        TaskFilter.completed => task.isDone,
        TaskFilter.today => task.dueDate?.isAtSameMomentAs(DateTime.now()) ?? false,
      };

      return matchesSearch && matchesFilter;
    }).toList();
  }

  void _toggleTheme() {
    setState(() {
      _themeMode = _themeMode == ThemeMode.light
          ? ThemeMode.dark
          : ThemeMode.light;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Todo + Báo thức'),
        actions: [
          IconButton(
            icon: Icon(
              _themeMode == ThemeMode.dark
                  ? Icons.light_mode
                  : Icons.dark_mode,
            ),
            onPressed: _toggleTheme,
          ),
          IconButton(
            icon: const Icon(Icons.chat),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ChatbotPage(
                    onTasksGenerated: (tasks) {
                      setState(() {
                        _tasks.addAll(tasks);
                      });
                    },
                  ),
                ),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                TextField(
                  controller: _titleController,
                  decoration: const InputDecoration(
                    labelText: 'Tên công việc',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _descriptionController,
                  decoration: const InputDecoration(
                    labelText: 'Mô tả (tùy chọn)',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 2,
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        _selectedTime != null
                            ? 'Thời gian: ${_selectedTime!.hour}:${_selectedTime!.minute.toString().padLeft(2, '0')}'
                            : 'Chưa chọn thời gian',
                      ),
                    ),
                    ElevatedButton(
                      onPressed: _pickTime,
                      child: const Text('Chọn giờ'),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        _selectedDueDate != null
                            ? 'Hạn cuối: ${_selectedDueDate!.day}/${_selectedDueDate!.month}/${_selectedDueDate!.year}'
                            : 'Chưa chọn hạn cuối',
                      ),
                    ),
                    ElevatedButton(
                      onPressed: _pickDueDate,
                      child: const Text('Chọn ngày'),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                DropdownButtonFormField<priority_model.Priority>(
                  value: _selectedPriority,
                  decoration: const InputDecoration(
                    labelText: 'Độ ưu tiên',
                    border: OutlineInputBorder(),
                  ),
                  items: priority_model.Priority.values.map((priority) {
                    return DropdownMenuItem(
                      value: priority,
                      child: Row(
                        children: [
                          Icon(Icons.flag, color: priority.color),
                          const SizedBox(width: 8),
                          Text(priority.label),
                        ],
                      ),
                    );
                  }).toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        _selectedPriority = value;
                      });
                    }
                  },
                ),
                const SizedBox(height: 8),
                CheckboxListTile(
                  title: const Text('Đặt báo thức'),
                  value: _setAlarm,
                  onChanged: (val) => setState(() => _setAlarm = val ?? false),
                ),
                ElevatedButton(
                  onPressed: _addTask,
                  child: const Text('Thêm công việc'),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    decoration: const InputDecoration(
                      hintText: 'Tìm kiếm...',
                      prefixIcon: Icon(Icons.search),
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (value) {
                      setState(() {
                        _searchQuery = value;
                      });
                    },
                  ),
                ),
                const SizedBox(width: 8),
                DropdownButton<TaskFilter>(
                  value: _currentFilter,
                  items: TaskFilter.values.map((filter) {
                    return DropdownMenuItem(
                      value: filter,
                      child: Text(filter.label),
                    );
                  }).toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        _currentFilter = value;
                      });
                    }
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: ListView.builder(
              itemCount: _filteredTasks.length,
              itemBuilder: (context, index) {
                final task = _filteredTasks[index];
                return Card(
                  child: ListTile(
                    leading: Icon(Icons.flag, color: task.priority.color),
                    title: Text(
                      task.title,
                      style: TextStyle(
                        decoration: task.isDone ? TextDecoration.lineThrough : null,
                      ),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (task.description != null)
                          Text(task.description!),
                        if (task.startTime != null)
                          Text(
                            'Lúc: ${task.startTime!.hour}:${task.startTime!.minute.toString().padLeft(2, '0')}',
                          ),
                        if (task.dueDate != null)
                          Text(
                            'Hạn cuối: ${task.dueDate!.day}/${task.dueDate!.month}/${task.dueDate!.year}',
                          ),
                      ],
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (task.setAlarm)
                          const Icon(Icons.alarm, color: Colors.orange),
                        IconButton(
                          icon: const Icon(Icons.check),
                          onPressed: () => _markDone(task.id),
                        ),
                      ],
                    ),
                    onTap: () => _showTaskDetails(task),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }
}

enum TaskFilter {
  all,
  active,
  completed,
  today;

  String get label {
    switch (this) {
      case TaskFilter.all:
        return 'Tất cả';
      case TaskFilter.active:
        return 'Đang làm';
      case TaskFilter.completed:
        return 'Đã hoàn thành';
      case TaskFilter.today:
        return 'Hôm nay';
    }
  }
} 