import 'dart:convert';
import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;
import '../models/task.dart';


class TaskApi {
  static const String _baseUrl = 'http://localhost:8008';
  static const String _tasksEndpoint = '/tasks';

  static Future<List<Task>> fetchTasks() async {
    final response = await http.get(Uri.parse('$_baseUrl$_tasksEndpoint'));
    if (response.statusCode == 200) {
      final List<dynamic> jsonData = json.decode(response.body);
      return jsonData.map((task) => Task.fromJson(task)).toList();
    } else {
      throw Exception('Failed to load tasks');
    }
  }

  static Future<void> addTask(Task task) async {
    final response = await http.post(
      Uri.parse('$_baseUrl$_tasksEndpoint'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'name': task.name,
        'description': task.description,
        'status': task.status,
        'created_at': DateTime.now().toIso8601String(),
      }),
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to add task');
    }
  }

  static Future<Task> getTaskDetails(String taskId) async {
    final response = await http.get(Uri.parse('$_baseUrl$_tasksEndpoint/$taskId'));
    if (response.statusCode != 200) {
      throw Exception('Failed to load task details');
    }
    debugPrint('Response body: ${response.body}');
    return Task.fromJson(json.decode(response.body));
  }

  static Future<void> setTaskStatus(String taskId, String taskStatus) async {
    final response = await http.patch(Uri.parse('$_baseUrl$_tasksEndpoint/$taskId/status?status=$taskStatus'));
    if (response.statusCode != 200) {
      throw Exception('Failed to update status');
    }
  }
}
