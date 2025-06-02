 import 'package:flutter/material.dart';
import '../../models/task.dart';
import '../../services/gemini_service.dart';
import 'package:uuid/uuid.dart';
import '../../models/priority.dart' as priority_model;

class ChatbotPage extends StatefulWidget {
  final Function(List<Task>) onTasksGenerated;

  const ChatbotPage({
    super.key,
    required this.onTasksGenerated,
  });

  @override
  State<ChatbotPage> createState() => _ChatbotPageState();
}

class _ChatbotPageState extends State<ChatbotPage> {
  final TextEditingController _messageController = TextEditingController();
  final List<ChatMessage> _messages = [];
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AI Assistant'),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(8.0),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final message = _messages[index];
                return _buildMessageBubble(message);
              },
            ),
          ),
          if (_isLoading)
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: CircularProgressIndicator(),
            ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: const InputDecoration(
                      hintText: 'Nhập tin nhắn...',
                      border: OutlineInputBorder(),
                    ),
                    onSubmitted: (_) => _sendMessage(),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: _sendMessage,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(ChatMessage message) {
    return Align(
      alignment: message.isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
        padding: const EdgeInsets.all(12.0),
        decoration: BoxDecoration(
          color: message.isUser
              ? Theme.of(context).primaryColor
              : Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(20.0),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Text(
          message.text,
          style: TextStyle(
            color: message.isUser ? Colors.white : null,
          ),
        ),
      ),
    );
  }

  Future<void> _sendMessage() async {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;

    setState(() {
      _messages.add(ChatMessage(text: text, isUser: true));
      _messageController.clear();
      _isLoading = true;
    });

    try {
      final tasks = await GeminiService.generateTasks(text);

      setState(() {
        _isLoading = false;
      });

      if (tasks.isEmpty) {
        setState(() {
          _messages.add(ChatMessage(
            text: 'Không tìm thấy công việc phù hợp.',
            isUser: false,
          ));
        });
        return;
      }

      // Hiển thị bottom sheet để xem trước task và chọn tạo hoặc từ chối
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
        ),
        builder: (_) => TaskPreviewSheet(
          tasks: tasks,
          onAccept: () {
            widget.onTasksGenerated(tasks);
            Navigator.pop(context);
            setState(() {
              _messages.add(ChatMessage(
                text: 'Đã thêm ${tasks.length} công việc từ gợi ý của AI!',
                isUser: false,
              ));
            });
          },
          onReject: () {
            Navigator.pop(context);
            setState(() {
              _messages.add(ChatMessage(
                text: 'Bạn đã từ chối danh sách công việc.',
                isUser: false,
              ));
            });
          },
        ),
      );
    } catch (e) {
      setState(() {
        _messages.add(ChatMessage(
          text: 'Xin lỗi, đã có lỗi xảy ra: $e',
          isUser: false,
        ));
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }
}

class ChatMessage {
  final String text;
  final bool isUser;

  ChatMessage({
    required this.text,
    required this.isUser,
  });
}

class TaskPreviewSheet extends StatelessWidget {
  final List<Task> tasks;
  final VoidCallback onAccept;
  final VoidCallback onReject;

  const TaskPreviewSheet({
    super.key,
    required this.tasks,
    required this.onAccept,
    required this.onReject,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.7,
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
            'Xem trước công việc',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 16),
          Expanded(
            child: ListView.builder(
              itemCount: tasks.length,
              itemBuilder: (context, index) {
                final task = tasks[index];
                return Card(
                  child: ListTile(
                    leading: Icon(task.priority.icon, color: task.priority.color),
                    title: Text(task.title),
                    subtitle: task.description != null 
                        ? Text(task.description!)
                        : null,
                    trailing: Chip(
                      label: Text(task.priority.label),
                      backgroundColor: task.priority.color.withOpacity(0.2),
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
                  onPressed: onReject,
                  child: const Text('Từ chối'),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: ElevatedButton(
                  onPressed: onAccept,
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