import 'package:flutter/material.dart';
import '../../models/task.dart';
import '../../models/priority.dart';
import '../../utils/date_formatter.dart';

class TaskDetailPage extends StatefulWidget {
  final Task task;
  final ValueChanged<Task> onUpdate;

  const TaskDetailPage({
    super.key,
    required this.task,
    required this.onUpdate,
  });

  @override
  State<TaskDetailPage> createState() => _TaskDetailPageState();
}

class _TaskDetailPageState extends State<TaskDetailPage> {
  late TextEditingController titleController;
  late TextEditingController descriptionController;
  late DateTime? selectedDate;
  late Priority selectedPriority;
  late bool setAlarm;

  @override
  void initState() {
    super.initState();
    titleController = TextEditingController(text: widget.task.title);
    descriptionController = TextEditingController(text: widget.task.description);
    selectedDate = widget.task.dueDate;
    selectedPriority = widget.task.priority;
    setAlarm = widget.task.setAlarm;
  }

  @override
  void dispose() {
    titleController.dispose();
    descriptionController.dispose();
    super.dispose();
  }

  void _saveTask() {
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

    final updatedTask = Task(
      id: widget.task.id,
      title: newTitle,
      description: descriptionController.text.trim(),
      dueDate: selectedDate,
      priority: selectedPriority,
      setAlarm: setAlarm,
      isDone: widget.task.isDone,
    );

    widget.onUpdate(updatedTask);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chỉnh sửa công việc'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _saveTask,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
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
    );
  }
} 