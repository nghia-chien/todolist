import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:uuid/uuid.dart';
import '../models/task.dart';
import '../models/priority.dart';

class GeminiService {
  static const String _baseUrl = 'https://generativelanguage.googleapis.com/v1beta/models/gemini-pro:generateContent';
  static const String _apiKey = 'YOUR_GEMINI_API_KEY_HERE'; // Replace with your actual API key

  /// Generate tasks from user input using Gemini AI
  static Future<List<Task>> generateTasks(String userInput) async {
    try {
      final response = await _makeRequest(userInput);
      return _parseTasksFromResponse(response);
    } catch (e) {
      throw Exception('Lỗi khi tạo công việc từ AI: $e');
    }
  }

  /// Make request to Gemini API
  static Future<String> _makeRequest(String userInput) async {
    final prompt = _buildPrompt(userInput);
    
    final requestBody = {
      'contents': [
        {
          'parts': [
            {'text': prompt}
          ]
        }
      ],
      'generationConfig': {
        'temperature': 0.7,
        'topK': 40,
        'topP': 0.95,
        'maxOutputTokens': 1024,
      }
    };

    final response = await http.post(
      Uri.parse('$_baseUrl?key=$_apiKey'),
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode(requestBody),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['candidates'][0]['content']['parts'][0]['text'];
    } else {
      throw Exception('API request failed: ${response.statusCode}');
    }
  }

  /// Build prompt for Gemini
  static String _buildPrompt(String userInput) {
    return '''
Dựa trên yêu cầu sau, hãy tạo danh sách các công việc cần làm (todo list) dưới dạng JSON:

"$userInput"

Hãy trả về một JSON array với format sau:
[
  {
    "title": "Tên công việc",
    "description": "Mô tả chi tiết (có thể null)",
    "priority": "low|normal|high|urgent",
    "estimatedDuration": "số phút ước tính",
    "tags": ["tag1", "tag2"]
  }
]

Quy tắc:
- Chia nhỏ công việc lớn thành các công việc nhỏ hơn
- Đặt tên công việc ngắn gọn, rõ ràng
- Mô tả chi tiết cách thực hiện
- Đánh giá độ ưu tiên phù hợp
- Ước tính thời gian thực hiện
- Thêm tags phù hợp

Chỉ trả về JSON array, không có text khác.
''';
  }

  /// Parse tasks from Gemini response
  static List<Task> _parseTasksFromResponse(String response) {
    try {
      // Remove any markdown formatting
      String cleanedResponse = response.trim();
      if (cleanedResponse.startsWith('```json')) {
        cleanedResponse = cleanedResponse.substring(7);
      }
      if (cleanedResponse.startsWith('```')) {
        cleanedResponse = cleanedResponse.substring(3);
      }
      if (cleanedResponse.endsWith('```')) {
        cleanedResponse = cleanedResponse.substring(0, cleanedResponse.length - 3);
      }

      final List<dynamic> taskData = jsonDecode(cleanedResponse);
      
      return taskData.map((item) {
        return Task(
          id: const Uuid().v4(),
          title: item['title'] ?? 'Công việc',
          description: item['description'],
          priority: _parsePriority(item['priority']),
          tags: List<String>.from(item['tags'] ?? []),
        );
      }).toList();
    } catch (e) {
      // Fallback: create tasks from mock data if parsing fails
      return _generateMockTasks();
    }
  }

  /// Parse priority from string
  static Priority _parsePriority(String? priorityString) {
    switch (priorityString?.toLowerCase()) {
      case 'low':
        return Priority.low;
      case 'high':
        return Priority.high;
      case 'urgent':
        return Priority.urgent;
      default:
        return Priority.normal;
    }
  }

  /// Generate mock tasks for demo purposes
  static List<Task> _generateMockTasks() {
    return [
      Task(
        id: const Uuid().v4(),
        title: 'Lên kế hoạch học tập',
        description: 'Tạo lịch học chi tiết cho tuần này',
        priority: Priority.high,
        tags: ['học tập', 'kế hoạch'],
      ),
      Task(
        id: const Uuid().v4(),
        title: 'Ôn tập bài cũ',
        description: 'Xem lại các bài học đã học',
        priority: Priority.normal,
        tags: ['học tập'],
      ),
      Task(
        id: const Uuid().v4(),
        title: 'Làm bài tập',
        description: 'Hoàn thành bài tập được giao',
        priority: Priority.high,
        tags: ['học tập', 'bài tập'],
      ),
    ];
  }

  /// Mock implementation for testing without API key
  static Future<List<Task>> generateTasksMock(String userInput) async {
    // Simulate API delay
    await Future.delayed(const Duration(seconds: 2));
    
    // Generate tasks based on input keywords
    List<Task> tasks = [];
    
    if (userInput.toLowerCase().contains('học') || userInput.toLowerCase().contains('study')) {
      tasks.addAll([
        Task(
          id: const Uuid().v4(),
          title: 'Lên kế hoạch học tập',
          description: 'Tạo lịch học chi tiết và phân bổ thời gian hợp lý',
          priority: Priority.high,
          tags: ['học tập', 'kế hoạch'],
        ),
        Task(
          id: const Uuid().v4(),
          title: 'Ôn tập kiến thức cũ',
          description: 'Xem lại các bài học và ghi chú đã học',
          priority: Priority.normal,
          tags: ['học tập', 'ôn tập'],
        ),
      ]);
    }
    
    if (userInput.toLowerCase().contains('việc nhà') || userInput.toLowerCase().contains('dọn dẹp')) {
      tasks.addAll([
        Task(
          id: const Uuid().v4(),
          title: 'Dọn dẹp phòng ngủ',
          description: 'Sắp xếp đồ đạc và lau chùi phòng ngủ',
          priority: Priority.normal,
          tags: ['việc nhà', 'dọn dẹp'],
        ),
        Task(
          id: const Uuid().v4(),
          title: 'Giặt quần áo',
          description: 'Giặt và phơi quần áo bẩn',
          priority: Priority.low,
          tags: ['việc nhà'],
        ),
      ]);
    }
    
    if (userInput.toLowerCase().contains('mua sắm') || userInput.toLowerCase().contains('shopping')) {
      tasks.addAll([
        Task(
          id: const Uuid().v4(),
          title: 'Lập danh sách mua sắm',
          description: 'Liệt kê những thứ cần mua',
          priority: Priority.normal,
          tags: ['mua sắm', 'kế hoạch'],
        ),
        Task(
          id: const Uuid().v4(),
          title: 'Đi siêu thị',
          description: 'Mua các món đồ theo danh sách',
          priority: Priority.normal,
          tags: ['mua sắm'],
        ),
      ]);
    }
    
    // If no specific keywords found, return general tasks
    if (tasks.isEmpty) {
      tasks = _generateMockTasks();
    }
    
    return tasks;
  }
}