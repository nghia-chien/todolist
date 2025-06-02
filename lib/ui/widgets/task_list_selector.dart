import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/task_list.dart';
import '../../services/task_service.dart';

class TaskListSelector extends StatelessWidget {
  final List<TaskList> taskLists;
  final TaskList? selectedList;
  final Function(TaskList) onListSelected;
  final Function(TaskList) onListDeleted;
  final Function(TaskList) onListArchived;
  final Function(TaskList) onListUnarchived;

  const TaskListSelector({
    super.key,
    required this.taskLists,
    required this.selectedList,
    required this.onListSelected,
    required this.onListDeleted,
    required this.onListArchived,
    required this.onListUnarchived,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              const Text(
                'Danh sách công việc',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              IconButton(
                icon: const Icon(Icons.add),
                onPressed: () => _showCreateListDialog(context),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: taskLists.length,
            itemBuilder: (context, index) {
              final list = taskLists[index];
              final isSelected = selectedList?.id == list.id;

              return ListTile(
                leading: Icon(
                  list.icon,
                  color: list.color,
                ),
                title: Text(
                  list.name,
                  style: TextStyle(
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
                subtitle: Text(
                  '${list.activeTasks.length} công việc còn lại',
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (list.isArchived)
                      IconButton(
                        icon: const Icon(Icons.unarchive),
                        onPressed: () => onListUnarchived(list),
                      )
                    else
                      IconButton(
                        icon: const Icon(Icons.archive),
                        onPressed: () => onListArchived(list),
                      ),
                    IconButton(
                      icon: const Icon(Icons.delete),
                      onPressed: () => onListDeleted(list),
                    ),
                  ],
                ),
                selected: isSelected,
                onTap: () => onListSelected(list),
              );
            },
          ),
        ),
      ],
    );
  }

  Future<void> _showCreateListDialog(BuildContext context) async {
    final nameController = TextEditingController();
    IconData selectedIcon = Icons.list;
    Color selectedColor = Colors.blue;

    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Tạo danh sách mới'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Tên danh sách',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  IconButton(
                    icon: Icon(Icons.list, color: selectedIcon == Icons.list ? selectedColor : null),
                    onPressed: () => setState(() => selectedIcon = Icons.list),
                  ),
                  IconButton(
                    icon: Icon(Icons.work, color: selectedIcon == Icons.work ? selectedColor : null),
                    onPressed: () => setState(() => selectedIcon = Icons.work),
                  ),
                  IconButton(
                    icon: Icon(Icons.school, color: selectedIcon == Icons.school ? selectedColor : null),
                    onPressed: () => setState(() => selectedIcon = Icons.school),
                  ),
                  IconButton(
                    icon: Icon(Icons.home, color: selectedIcon == Icons.home ? selectedColor : null),
                    onPressed: () => setState(() => selectedIcon = Icons.home),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _ColorButton(
                    color: Colors.blue,
                    isSelected: selectedColor == Colors.blue,
                    onTap: () => setState(() => selectedColor = Colors.blue),
                  ),
                  _ColorButton(
                    color: Colors.red,
                    isSelected: selectedColor == Colors.red,
                    onTap: () => setState(() => selectedColor = Colors.red),
                  ),
                  _ColorButton(
                    color: Colors.green,
                    isSelected: selectedColor == Colors.green,
                    onTap: () => setState(() => selectedColor = Colors.green),
                  ),
                  _ColorButton(
                    color: Colors.purple,
                    isSelected: selectedColor == Colors.purple,
                    onTap: () => setState(() => selectedColor = Colors.purple),
                  ),
                ],
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Hủy'),
            ),
            ElevatedButton(
              onPressed: () {
                if (nameController.text.isNotEmpty) {
                  Navigator.pop(context, {
                    'name': nameController.text,
                    'icon': selectedIcon,
                    'color': selectedColor,
                  });
                }
              },
              child: const Text('Tạo'),
            ),
          ],
        ),
      ),
    );

    if (result != null) {
      final taskService = context.read<TaskService>();
      await taskService.createTaskList(
        result['name'] as String,
        result['icon'] as IconData,
        result['color'] as Color,
      );
    }
  }
}

class _ColorButton extends StatelessWidget {
  final Color color;
  final bool isSelected;
  final VoidCallback onTap;

  const _ColorButton({
    required this.color,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          border: Border.all(
            color: isSelected ? Colors.black : Colors.transparent,
            width: 2,
          ),
        ),
      ),
    );
  }
} 