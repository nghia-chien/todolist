import 'package:flutter/material.dart';

enum Priority {
  urgent,
  high, 
  normal,
  low;

  String get label {
    switch (this) {
      case Priority.urgent:
        return 'Khẩn cấp';
      case Priority.high:
        return 'Cao';
      case Priority.normal:
        return 'Bình thường';
      case Priority.low:
        return 'Thấp';
    }
  }

  Color get color {
    switch (this) {
      case Priority.urgent:
        return Colors.red;
      case Priority.high:
        return Colors.orange;
      case Priority.normal:
        return Colors.blue;
      case Priority.low:
        return Colors.green;
    }
  }

  IconData get icon {
    switch (this) {
      case Priority.urgent:
        return Icons.priority_high;
      case Priority.high:
        return Icons.arrow_upward;
      case Priority.normal:
        return Icons.remove;
      case Priority.low:
        return Icons.arrow_downward;
    }
  }
} 