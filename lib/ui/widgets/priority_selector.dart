import 'package:flutter/material.dart';
import '../../models/priority.dart';

class PrioritySelector extends StatelessWidget {
  final Priority value;
  final ValueChanged<Priority> onChanged;

  const PrioritySelector({
    super.key,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<Priority>(
      value: value,
      decoration: const InputDecoration(
        labelText: 'Độ ưu tiên',
        border: OutlineInputBorder(),
      ),
      items: Priority.values.map((priority) {
        return DropdownMenuItem(
          value: priority,
          child: Row(
            children: [
              Icon(priority.icon, color: priority.color),
              const SizedBox(width: 8),
              Text(priority.label),
            ],
          ),
        );
      }).toList(),
      onChanged: (value) {
        if (value != null) {
          onChanged(value);
        }
      },
    );
  }
} 