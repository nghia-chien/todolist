import 'package:flutter/material.dart';
import '../../models/task.dart';
import '../../utils/date_formatter.dart';

class TaskDetailPage extends StatelessWidget {
  final Task task;
  final VoidCallback onComplete;
  final VoidCallback onDelete;

  const TaskDetailPage({
    super.key,
    required this.task,
    required this.onComplete,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chi tiết công việc'),
        actions: [
          if (!task.isDone)
            IconButton(
              icon: const Icon(Icons.check),
              onPressed: () {
                onComplete();
                Navigator.pop(context);
              },
            ),
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () {
              onDelete();
              Navigator.pop(context);
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              task.title,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    decoration: task.isDone ? TextDecoration.lineThrough : null,
                    color: task.isOverdue ? Colors.red : null,
                  ),
            ),
            const SizedBox(height: 16),
            if (task.description != null) ...[
              Text(
                'Mô tả:',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              Text(task.description!),
              const SizedBox(height: 16),
            ],
            Row(
              children: [
                Icon(task.priority.icon, color: task.priority.color),
                const SizedBox(width: 8),
                Text('Độ ưu tiên: ${task.priority.label}'),
              ],
            ),
            const SizedBox(height: 8),
            if (task.startTime != null) ...[
              Row(
                children: [
                  const Icon(Icons.access_time),
                  const SizedBox(width: 8),
                  Text(
                    'Bắt đầu: ${DateFormatter.formatTime(task.startTime!)}',
                  ),
                ],
              ),
              const SizedBox(height: 8),
            ],
            if (task.dueDate != null) ...[
              Row(
                children: [
                  const Icon(Icons.calendar_today),
                  const SizedBox(width: 8),
                  Text(
                    'Hạn cuối: ${DateFormatter.formatDate(task.dueDate!)}',
                    style: TextStyle(
                      color: task.isOverdue ? Colors.red : null,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
            ],
            if (task.remainingTime != null && !task.isDone) ...[
              Row(
                children: [
                  const Icon(Icons.timer),
                  const SizedBox(width: 8),
                  Text(
                    'Còn lại: ${task.remainingTime!.inDays} ngày',
                    style: TextStyle(
                      color: task.isOverdue ? Colors.red : null,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
            ],
            if (task.setAlarm)
              const Row(
                children: [
                  Icon(Icons.alarm, color: Colors.orange),
                  SizedBox(width: 8),
                  Text('Đã đặt báo thức'),
                ],
              ),
            const SizedBox(height: 16),
            Text(
              'Trạng thái: ${task.isDone ? 'Đã hoàn thành' : 'Chưa hoàn thành'}',
              style: TextStyle(
                color: task.isDone ? Colors.green : Colors.orange,
                fontWeight: FontWeight.bold,
              ),
            ),
            if (task.completedAt != null) ...[
              const SizedBox(height: 8),
              Text(
                'Hoàn thành lúc: ${DateFormatter.formatDateTime(task.completedAt!)}',
              ),
            ],
            const SizedBox(height: 8),
            Text(
              'Tạo lúc: ${DateFormatter.formatDateTime(task.createdAt)}',
            ),
          ],
        ),
      ),
    );
  }
} 