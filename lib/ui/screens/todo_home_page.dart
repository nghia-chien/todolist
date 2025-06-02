import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/task.dart';
import '../../models/task_list.dart' as task_list_model;
import '../../services/task_service.dart';
import '../widgets/task_list_selector.dart';
import '../widgets/task_form.dart';
import '../widgets/task_list.dart' as task_list_widget;
import 'chatbot_page.dart';
import 'package:uuid/uuid.dart';
import '../../models/priority.dart' as priority_model;
import 'statistics_screen.dart';

class TodoHomePage extends StatefulWidget {
  final Function(ThemeMode) onThemeChanged;

  const TodoHomePage({
    super.key,
    required this.onThemeChanged,
  });

  @override
  State<TodoHomePage> createState() => _TodoHomePageState();
}

class _TodoHomePageState extends State<TodoHomePage> {
  bool _showTaskForm = false;
  bool _showTaskLists = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(context.read<TaskService>().currentList?.name ?? 'Todo List'),
        actions: [
          IconButton(
            icon: const Icon(Icons.bar_chart),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const StatisticsScreen(),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.brightness_6),
            onPressed: _toggleTheme,
          ),
          IconButton(
            icon: const Icon(Icons.smart_toy),
            onPressed: () => _showChatbotPage(context),
          ),
        ],
      ),
      drawer: Drawer(
        child: Consumer<TaskService>(
          builder: (context, taskService, child) {
            return TaskListSelector(
              taskLists: taskService.taskLists,
              selectedList: taskService.currentList,
              onListSelected: (list) {
                taskService.setCurrentList(list.id);
                Navigator.pop(context);
              },
              onListDeleted: (list) {
                taskService.deleteTaskList(list.id);
              },
              onListArchived: (list) {
                taskService.archiveTaskList(list.id);
              },
              onListUnarchived: (list) {
                taskService.unarchiveTaskList(list.id);
              },
            );
          },
        ),
      ),
      body: Consumer<TaskService>(
        builder: (context, taskService, child) {
          if (taskService.currentList == null) {
            return const Center(
              child: Text('Vui lòng tạo danh sách công việc mới'),
            );
          }

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        decoration: const InputDecoration(
                          hintText: 'Tìm kiếm...',
                          prefixIcon: Icon(Icons.search),
                          border: OutlineInputBorder(),
                        ),
                        onChanged: taskService.setSearchQuery,
                      ),
                    ),
                    const SizedBox(width: 16),
                    DropdownButton<TaskFilter>(
                      value: taskService.currentFilter,
                      items: TaskFilter.values.map((filter) {
                        return DropdownMenuItem(
                          value: filter,
                          child: Text(_getFilterLabel(filter)),
                        );
                      }).toList(),
                      onChanged: (value) {
                        if (value != null) {
                          taskService.setFilter(value);
                        }
                      },
                    ),
                  ],
                ),
              ),
              if (_showTaskForm)
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: TaskForm(
                    onSubmit: ({
                      required String title,
                      required String? description,
                      required DateTime? dueDate,
                      required priority_model.Priority priority,
                      required bool setAlarm,
                      required DateTime? startTime,
                    }) async {
                      final task = Task(
                        id: const Uuid().v4(),
                        title: title,
                        description: description,
                        dueDate: dueDate,
                        priority: priority,
                        setAlarm: setAlarm,
                        startTime: startTime,
                        createdAt: DateTime.now(),
                      );
                      await taskService.addTask(task);
                      setState(() {
                        _showTaskForm = false;
                      });
                    },
                  ),
                ),
              Expanded(
                child: task_list_widget.TaskList(
                  tasks: taskService.filteredTasks,
                  onTaskTap: (task) => _showTaskDetail(context, task),
                  onTaskComplete: (task) {
                    taskService.updateTask(
                      task.copyWith(
                        isDone: !task.isDone,
                        completedAt: !task.isDone ? DateTime.now() : null,
                      ),
                    );
                  },
                  onTaskDelete: (task) {
                    taskService.deleteTask(task.id);
                  },
                  onTaskUpdate: (oldTask, newTask) {
                    taskService.updateTask(newTask);
                  },
                ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          setState(() {
            _showTaskForm = !_showTaskForm;
          });
        },
        child: Icon(_showTaskForm ? Icons.close : Icons.add),
      ),
    );
  }

  void _toggleTheme() {
    final currentTheme = Theme.of(context).brightness;
    final newThemeMode = currentTheme == Brightness.light
        ? ThemeMode.dark
        : ThemeMode.light;
    widget.onThemeChanged(newThemeMode);
  }

  void _showChatbotPage(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ChatbotPage(
          onTasksGenerated: (tasks) {
            final taskService = context.read<TaskService>();
            for (final task in tasks) {
              taskService.addTask(task);
            }
          },
        ),
      ),
    );
  }

  void _showTaskDetail(BuildContext context, Task task) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.9,
        maxChildSize: 0.9,
        minChildSize: 0.5,
        builder: (context, scrollController) {
          return SingleChildScrollView(
            controller: scrollController,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(task.priority.icon, color: task.priority.color),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          task.title,
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),
                      ),
                      IconButton(
                        icon: Icon(
                          task.isDone ? Icons.check_circle : Icons.circle_outlined,
                        ),
                        onPressed: () {
                          final taskService = context.read<TaskService>();
                          taskService.updateTask(
                            task.copyWith(
                              isDone: !task.isDone,
                              completedAt: !task.isDone ? DateTime.now() : null,
                            ),
                          );
                          Navigator.pop(context);
                        },
                      ),
                    ],
                  ),
                  if (task.description != null) ...[
                    const SizedBox(height: 16),
                    Text(
                      task.description!,
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                  ],
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 8,
                    children: task.tags.map((tag) {
                      return Chip(
                        label: Text(tag),
                        backgroundColor: task.priority.color.withOpacity(0.2),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 16),
                  if (task.startTime != null)
                    ListTile(
                      leading: const Icon(Icons.access_time),
                      title: const Text('Thời gian bắt đầu'),
                      subtitle: Text(
                        '${task.startTime!.hour}:${task.startTime!.minute.toString().padLeft(2, '0')}',
                      ),
                    ),
                  if (task.dueDate != null)
                    ListTile(
                      leading: const Icon(Icons.calendar_today),
                      title: const Text('Hạn hoàn thành'),
                      subtitle: Text(
                        '${task.dueDate!.day}/${task.dueDate!.month}/${task.dueDate!.year}',
                      ),
                    ),
                  if (task.setAlarm)
                    const ListTile(
                      leading: Icon(Icons.alarm),
                      title: Text('Đã đặt nhắc nhở'),
                    ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      OutlinedButton.icon(
                        onPressed: () {
                          Navigator.pop(context);
                          setState(() {
                            _showTaskForm = true;
                          });
                        },
                        icon: const Icon(Icons.edit),
                        label: const Text('Chỉnh sửa'),
                      ),
                      OutlinedButton.icon(
                        onPressed: () {
                          final taskService = context.read<TaskService>();
                          taskService.deleteTask(task.id);
                          Navigator.pop(context);
                        },
                        icon: const Icon(Icons.delete),
                        label: const Text('Xóa'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  String _getFilterLabel(TaskFilter filter) {
    switch (filter) {
      case TaskFilter.all:
        return 'Tất cả';
      case TaskFilter.active:
        return 'Đang làm';
      case TaskFilter.completed:
        return 'Hoàn thành';
      case TaskFilter.overdue:
        return 'Quá hạn';
      case TaskFilter.dueToday:
        return 'Hôm nay';
    }
  }

  

  @override
  void initState() {
    super.initState();
    // Initialize any heavy operations here
  }

  @override
  void dispose() {
    // Clean up any resources here
    super.dispose();
  }
} 