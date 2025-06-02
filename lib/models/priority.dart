import 'package:flutter/material.dart';

enum Priority {
  low,
  normal,
  high,
  urgent;

  String get label {
    switch (this) {
      case Priority.low:
        return 'Thấp';
      case Priority.normal:
        return 'Bình thường';
      case Priority.high:
        return 'Cao';
      case Priority.urgent:
        return 'Khẩn cấp';
    }
  }

  Color get color {
    switch (this) {
      case Priority.low:
        return Colors.green;
      case Priority.normal:
        return Colors.blue;
      case Priority.high:
        return Colors.orange;
      case Priority.urgent:
        return Colors.red;
    }
  }

  IconData get icon {
    switch (this) {
      case Priority.low:
        return Icons.arrow_downward;
      case Priority.normal:
        return Icons.remove;
      case Priority.high:
        return Icons.arrow_upward;
      case Priority.urgent:
        return Icons.priority_high;
    }
  }
} 