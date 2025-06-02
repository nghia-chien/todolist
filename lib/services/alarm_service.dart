import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/task.dart';

class AlarmService {
  static const platform = MethodChannel('com.example.td1/alarm');

  /// Set an alarm for the given time with the specified title
  static Future<void> setPlatformAlarm(DateTime time, String title) async {
    try {
      await platform.invokeMethod('setAlarm', {
        'hour': time.hour,
        'minute': time.minute,
        'title': title,
      });
    } catch (e) {
      print('Error setting alarm: $e');
      rethrow;
    }
  }

  /// Cancel an alarm by its ID
  static Future<void> cancelPlatformAlarm(int id) async {
    try {
      await platform.invokeMethod('cancelAlarm', {'id': id});
    } catch (e) {
      print('Error canceling alarm: $e');
      rethrow;
    }
  }

  /// Check if alarm permission is granted
  static Future<bool> hasAlarmPermission() async {
    try {
      final result = await platform.invokeMethod('hasAlarmPermission');
      return result as bool;
    } on PlatformException catch (e) {
      debugPrint('Lỗi kiểm tra quyền báo thức: ${e.message}');
      return false;
    }
  }

  /// Request alarm permission
  static Future<bool> requestAlarmPermission() async {
    try {
      final result = await platform.invokeMethod('requestAlarmPermission');
      return result as bool;
    } on PlatformException catch (e) {
      debugPrint('Lỗi yêu cầu quyền báo thức: ${e.message}');
      return false;
    }
  }

  /// Initialize the alarm service
  static Future<void> initialize() async {
    try {
      await platform.invokeMethod('initialize');
    } catch (e) {
      print('Error initializing alarm service: $e');
    }
  }

  /// Get all scheduled alarms
  static Future<List<Map<String, dynamic>>> getScheduledAlarms() async {
    try {
      final result = await platform.invokeMethod('getScheduledAlarms');
      return List<Map<String, dynamic>>.from(result);
    } on PlatformException catch (e) {
      debugPrint('Lỗi lấy danh sách báo thức: ${e.message}');
      return [];
    }
  }

  /// Mock implementation for testing without native code
  static Future<void> setAlarmMock(DateTime dateTime, String title) async {
    // Simulate delay for setting alarm
    await Future.delayed(const Duration(milliseconds: 500));
    
    // In a real implementation, this would interact with native Android/iOS code
    debugPrint('Mock: Đã tạo báo thức cho $title lúc $dateTime');
    
    // For demo purposes, we'll just show a debug message
    // In real app, you would use packages like:
    // - android_alarm_manager_plus
    // - flutter_local_notifications
    // - alarm package
  }

  Future<void> setAlarm(Task task) async {
    if (task.dueDate == null) return;
    
    // TODO: Implement actual alarm setting logic
    debugPrint('Setting alarm for task: ${task.title} at ${task.dueDate}');
  }

  Future<void> cancelAlarm(String taskId) async {
    // TODO: Implement actual alarm cancellation logic
    debugPrint('Cancelling alarm for task: $taskId');
  }
}