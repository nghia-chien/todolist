import 'package:flutter/material.dart';
import '../../models/task.dart';
import '../../models/priority.dart';
import '../screens/task_detail_page.dart';

class TaskList extends StatelessWidget {
  final List<Task> tasks;
  final Function(Task) onTaskTap;
  final Function(Task) onTaskComplete;
  final Function(Task) onTaskDelete;
  final Function(Task, Task) onTaskUpdate;

  const TaskList({
    super.key,
    required this.tasks,
    required this.onTaskTap,
    required this.onTaskComplete,
    required this.onTaskDelete,
    required this.onTaskUpdate,
  });

  void _editTaskDialog(BuildContext context, Task task) async {
    final titleController = TextEditingController(text: task.title);
    final descriptionController = TextEditingController(text: task.description);
    DateTime? selectedDate = task.dueDate;
    Priority selectedPriority = task.priority;
    bool setAlarm = task.setAlarm;

    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Chỉnh sửa công việc'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: titleController,
                  autofocus: true,
                  decoration: const InputDecoration(
                    labelText: 'Tên công việc',
                    hintText: 'Nhập tên công việc',
                    prefixIcon: Icon(Icons.edit),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: descriptionController,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    labelText: 'Mô tả',
                    hintText: 'Nhập mô tả (không bắt buộc)',
                    prefixIcon: Icon(Icons.description),
                  ),
                ),
                const SizedBox(height: 16),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.calendar_today),
                            const SizedBox(width: 8),
                            const Text('Hạn hoàn thành:'),
                            const Spacer(),
                            TextButton.icon(
                              onPressed: () async {
                                final picked = await showDatePicker(
                                  context: context,
                                  initialDate: selectedDate ?? DateTime.now(),
                                  firstDate: DateTime(2020),
                                  lastDate: DateTime(2100),
                                  builder: (context, child) {
                                    return Theme(
                                      data: Theme.of(context).copyWith(
                                        colorScheme: ColorScheme.light(
                                          primary: Theme.of(context).primaryColor,
                                        ),
                                      ),
                                      child: child!,
                                    );
                                  },
                                );
                                if (picked != null) {
                                  setState(() {
                                    selectedDate = picked;
                                  });
                                }
                              },
                              icon: const Icon(Icons.edit_calendar),
                              label: Text(
                                selectedDate != null
                                    ? '${selectedDate!.day}/${selectedDate!.month}/${selectedDate!.year}'
                                    : 'Chọn ngày',
                              ),
                            ),
                          ],
                        ),
                        if (selectedDate != null)
                          TextButton.icon(
                            onPressed: () {
                              setState(() {
                                selectedDate = null;
                              });
                            },
                            icon: const Icon(Icons.clear),
                            label: const Text('Xóa hạn'),
                          ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Mức độ ưu tiên',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        DropdownButtonFormField<Priority>(
                          value: selectedPriority,
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            contentPadding: EdgeInsets.symmetric(horizontal: 16),
                          ),
                          items: Priority.values.map((priority) {
                            return DropdownMenuItem(
                              value: priority,
                              child: Row(
                                children: [
                                  Icon(priority.icon, color: priority.color),
                                  const SizedBox(width: 8),
                                  Text(priority.name),
                                ],
                              ),
                            );
                          }).toList(),
                          onChanged: (value) {
                            if (value != null) {
                              setState(() {
                                selectedPriority = value;
                              });
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Card(
                  child: SwitchListTile(
                    title: const Text('Đặt nhắc nhở'),
                    subtitle: const Text('Nhận thông báo khi đến hạn'),
                    secondary: const Icon(Icons.notifications),
                    value: setAlarm,
                    onChanged: (value) {
                      setState(() {
                        setAlarm = value;
                      });
                    },
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton.icon(
              onPressed: () => Navigator.of(context).pop(null),
              icon: const Icon(Icons.cancel),
              label: const Text('Hủy'),
            ),
            ElevatedButton.icon(
              onPressed: () {
                final newTitle = titleController.text.trim();
                if (newTitle.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Tên công việc không được để trống'),
                      backgroundColor: Colors.red,
                    ),
                  );
                  return;
                }
                Navigator.of(context).pop({
                  'title': newTitle,
                  'description': descriptionController.text.trim(),
                  'dueDate': selectedDate,
                  'priority': selectedPriority,
                  'setAlarm': setAlarm,
                });
              },
              icon: const Icon(Icons.save),
              label: const Text('Lưu'),
            ),
          ],
        ),
      ),
    );

    if (result != null) {
      final updatedTask = Task(
        id: task.id,
        title: result['title'] as String,
        description: result['description'] as String,
        dueDate: result['dueDate'] as DateTime?,
        priority: result['priority'] as Priority,
        setAlarm: result['setAlarm'] as bool,
        isDone: task.isDone,
      );
      onTaskUpdate(task, updatedTask);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.check_circle, color: Colors.white),
              const SizedBox(width: 8),
              const Text('Đã cập nhật công việc'),
            ],
          ),
          backgroundColor: Colors.blue,
          behavior: SnackBarBehavior.floating,
          action: SnackBarAction(
            label: 'OK',
            textColor: Colors.white,
            onPressed: () {},
          ),
        ),
      );
    }
  }

  void _openTaskDetail(BuildContext context, Task task) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => TaskDetailPage(
          task: task,
          onUpdate: (updatedTask) => onTaskUpdate(task, updatedTask),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (tasks.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.task_alt,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'Chưa có công việc nào',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      itemCount: tasks.length,
      itemBuilder: (context, index) {
        final task = tasks[index];
        return Dismissible(
          key: Key(task.id),
          background: Container(
            color: Colors.green,
            alignment: Alignment.centerLeft,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: const Row(
              children: [
                Icon(Icons.check, color: Colors.white),
                SizedBox(width: 8),
                Text(
                  'Hoàn thành',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          secondaryBackground: Container(
            color: Colors.red,
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                  'Xóa',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(width: 8),
                Icon(Icons.delete, color: Colors.white),
              ],
            ),
          ),
          confirmDismiss: (direction) async {
            if (direction == DismissDirection.startToEnd) {
              // Vuốt từ trái sang phải ➜ hoàn thành
              onTaskComplete(task);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Row(
                    children: [
                      const Icon(Icons.check_circle, color: Colors.white),
                      const SizedBox(width: 8),
                      Text('Đã hoàn thành "${task.title}"'),
                    ],
                  ),
                  backgroundColor: Colors.green,
                  behavior: SnackBarBehavior.floating,
                  action: SnackBarAction(
                    label: 'Hoàn tác',
                    textColor: Colors.white,
                    onPressed: () {
                      // TODO: Implement undo complete
                    },
                  ),
                ),
              );
              return false; // Không xóa khỏi danh sách
            } else {
              // Vuốt từ phải sang trái ➜ xóa
              return await showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Xóa công việc?'),
                  content: Text('Bạn có chắc muốn xóa "${task.title}"?'),
                  actions: [
                    TextButton.icon(
                      onPressed: () => Navigator.of(context).pop(false),
                      icon: const Icon(Icons.cancel),
                      label: const Text('Không'),
                    ),
                    TextButton.icon(
                      onPressed: () => Navigator.of(context).pop(true),
                      icon: const Icon(Icons.delete),
                      label: const Text('Xóa'),
                    ),
                  ],
                ),
              );
            }
          },
          onDismissed: (direction) {
            if (direction == DismissDirection.endToStart) {
              onTaskDelete(task);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Row(
                    children: [
                      const Icon(Icons.delete, color: Colors.white),
                      const SizedBox(width: 8),
                      Text('Đã xóa "${task.title}"'),
                    ],
                  ),
                  backgroundColor: Colors.red,
                  behavior: SnackBarBehavior.floating,
                  action: SnackBarAction(
                    label: 'Hoàn tác',
                    textColor: Colors.white,
                    onPressed: () {
                      // TODO: Implement undo delete
                    },
                  ),
                ),
              );
            }
          },
          child: GestureDetector(
            onTap: () => _openTaskDetail(context, task),
            child: Card(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(
                  color: task.isDone ? Colors.green : Colors.grey.shade300,
                  width: 1,
                ),
              ),
              child: ListTile(
                leading: Icon(
                  task.isDone ? Icons.check_circle : Icons.circle_outlined,
                  color: task.isDone ? Colors.green : Colors.grey,
                  size: 28,
                ),
                title: Text(
                  task.title,
                  style: TextStyle(
                    decoration: task.isDone ? TextDecoration.lineThrough : null,
                    color: task.isDone ? Colors.grey : null,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (task.description != null && task.description!.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(
                          task.description!,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 13,
                          ),
                        ),
                      ),
                    if (task.dueDate != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Row(
                          children: [
                            Icon(
                              Icons.calendar_today,
                              size: 14,
                              color: task.isOverdue ? Colors.red : Colors.grey,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'Hạn: ${task.dueDate!.day}/${task.dueDate!.month}/${task.dueDate!.year}',
                              style: TextStyle(
                                color: task.isOverdue ? Colors.red : Colors.grey,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: task.priority.color.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            task.priority.icon,
                            color: task.priority.color,
                            size: 16,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            task.priority.name,
                            style: TextStyle(
                              color: task.priority.color,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (task.setAlarm)
                      Padding(
                        padding: const EdgeInsets.only(left: 8.0),
                        child: Icon(
                          Icons.alarm,
                          color: Colors.orange,
                          size: 20,
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
} 