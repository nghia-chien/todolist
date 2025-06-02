import 'package:flutter/material.dart';
import '../../models/task.dart';
import '../../models/priority.dart';
import '../../utils/date_formatter.dart';

class TaskItem extends StatelessWidget {
  final Task task;
  final VoidCallback onTap;
  final VoidCallback onComplete;
  final VoidCallback onDelete;

  const TaskItem({
    super.key,
    required this.task,
    required this.onTap,
    required this.onComplete,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: Icon(task.priority.icon, color: task.priority.color),
        title: Text(
          task.title,
          style: TextStyle(
            decoration: task.isDone ? TextDecoration.lineThrough : null,
            color: task.isOverdue ? Colors.red : null,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (task.description != null)
              Text(task.description!),
            if (task.startTime != null)
              Text(
                'Lúc: ${DateFormatter.formatTime(task.startTime!)}',
              ),
            if (task.dueDate != null)
              Text(
                'Hạn cuối: ${DateFormatter.formatDate(task.dueDate!)}',
                style: TextStyle(
                  color: task.isOverdue ? Colors.red : null,
                ),
              ),
            if (task.remainingTime != null && !task.isDone)
              Text(
                'Còn lại: ${task.remainingTime!.inDays} ngày',
                style: TextStyle(
                  color: task.isOverdue ? Colors.red : null,
                ),
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
              onPressed: onComplete,
            ),
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: onDelete,
            ),
          ],
        ),
        onTap: onTap,
      ),
    );
  }
} 