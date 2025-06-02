import 'package:flutter/material.dart';
import '../../models/task.dart';
import '../../models/priority.dart';

class TaskPreviewSheet extends StatefulWidget {
  final List<Task> tasks;
  final Function(List<Task>) onTasksGenerated;
  final VoidCallback onAccept;
  final VoidCallback onReject;

  const TaskPreviewSheet({
    super.key,
    required this.tasks,
    required this.onTasksGenerated,
    required this.onAccept,
    required this.onReject,
  });

  @override
  State<TaskPreviewSheet> createState() => _TaskPreviewSheetState();
}

class _TaskPreviewSheetState extends State<TaskPreviewSheet> {
  late List<Task> editableTasks;

  @override
  void initState() {
    super.initState();
    editableTasks = List.from(widget.tasks);
  }

  void _editTask(int index) async {
    final task = editableTasks[index];
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
      setState(() {
        editableTasks[index] = Task(
          id: task.id,
          title: result['title'] as String,
          description: result['description'] as String,
          dueDate: result['dueDate'] as DateTime?,
          priority: result['priority'] as Priority,
          setAlarm: result['setAlarm'] as bool,
          isDone: task.isDone,
        );
      });
    }
  }

  void _removeTask(int index) {
    setState(() {
      editableTasks.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.75,
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Xem trước và chỉnh sửa công việc',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 16),
          Expanded(
            child: ListView.builder(
              itemCount: editableTasks.length,
              itemBuilder: (context, index) {
                final task = editableTasks[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    leading: Icon(task.priority.icon, color: task.priority.color),
                    title: Text(task.title),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (task.description != null && task.description!.isNotEmpty)
                          Text(task.description!),
                        if (task.dueDate != null)
                          Row(
                            children: [
                              const Icon(Icons.calendar_today, size: 16),
                              const SizedBox(width: 4),
                              Text(
                                '${task.dueDate!.day}/${task.dueDate!.month}/${task.dueDate!.year}',
                              ),
                            ],
                          ),
                      ],
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit),
                          onPressed: () => _editTask(index),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete),
                          onPressed: () => _removeTask(index),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: widget.onReject,
                  child: const Text('Từ chối'),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    widget.onTasksGenerated(editableTasks);
                    widget.onAccept();
                  },
                  child: const Text('Thêm vào danh sách'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
} 