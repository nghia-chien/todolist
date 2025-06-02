import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:provider/provider.dart';
import '../../services/task_service.dart';
import '../../models/task.dart';
import '../../models/priority.dart';

class StatisticsScreen extends StatelessWidget {
  const StatisticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Thống kê công việc'),
      ),
      body: Consumer<TaskService>(
        builder: (context, taskService, child) {
          final tasks = taskService.currentList?.tasks ?? [];
          
          if (tasks.isEmpty) {
            return const Center(
              child: Text('Không có dữ liệu'),
            );
          }

          return _StatisticsContent(tasks: tasks);
        },
      ),
    );
  }
}

class _StatisticsContent extends StatelessWidget {
  final List<Task> tasks;

  const _StatisticsContent({required this.tasks});

  int get completedCount => tasks.where((t) => t.isDone).length;
  int get remainingCount => tasks.length - completedCount;

  Map<String, int> get priorityCounts => {
    'Cao': tasks.where((t) => t.priority == Priority.high).length,
    'Trung bình': tasks.where((t) => t.priority == Priority.normal).length,
    'Thấp': tasks.where((t) => t.priority == Priority.low).length,
  };

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Tổng cộng: ${tasks.length} công việc',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 20),
          Expanded(
            child: Center(
              child: AspectRatio(
                aspectRatio: 1.3,
                child: PieChart(
                  PieChartData(
                    sections: [
                      PieChartSectionData(
                        value: completedCount.toDouble(),
                        title: 'Hoàn thành\n$completedCount',
                        color: Colors.green,
                        radius: 60,
                        titleStyle: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      PieChartSectionData(
                        value: remainingCount.toDouble(),
                        title: 'Chưa xong\n$remainingCount',
                        color: Colors.red,
                        radius: 60,
                        titleStyle: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ],
                    sectionsSpace: 0,
                    centerSpaceRadius: 40,
                    startDegreeOffset: -90,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
          _buildPriorityStats(),
        ],
      ),
    );
  }

  Widget _buildPriorityStats() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Phân bố theo độ ưu tiên:',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 10),
        ...priorityCounts.entries.map((entry) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Row(
              children: [
                Container(
                  width: 16,
                  height: 16,
                  decoration: BoxDecoration(
                    color: _getPriorityColor(entry.key),
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 8),
                Text('${entry.key}: ${entry.value} công việc'),
              ],
            ),
          );
        }),
      ],
    );
  }

  Color _getPriorityColor(String priority) {
    switch (priority) {
      case 'Cao':
        return Colors.red;
      case 'Trung bình':
        return Colors.orange;
      case 'Thấp':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }
} 