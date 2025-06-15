import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/task.dart';

class TaskApi {
  final http.Client client;
  TaskApi({required this.client});
  static const String _url = 'http://localhost:8000/tasks';
  

  

  Future<List<Task>> fetchTasks() async {
    final response = await client.get(Uri.parse(_url));
    if (response.statusCode == 200) {
      final List<dynamic> jsonData = json.decode(response.body);
      return jsonData.map((task) => Task.fromJson(task)).toList();
    } else {
      throw Exception('Failed to load tasks');
    }
  }

  Future<Task> addTask(Task task) async {
    final response = await client.post(
      Uri.parse(_url),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'name': task.name,
        'description': task.description,
        'status': task.status,
        'planned_at': task.plannedAt?.toIso8601String(),
      }),
    );
    if (response.statusCode != 201) {
      throw Exception('Failed to add task');
    }
    return Task.fromJson(json.decode(response.body));
  }

  Future<Task> getTaskDetails(String taskId) async {
    final response = await client.get(
      Uri.parse('$_url/$taskId'),
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to load task details');
    }
    return Task.fromJson(json.decode(response.body));
  }

  Future<void> setTaskStatus(String taskId, String taskStatus) async {
    final response = await client.patch(
      Uri.parse('$_url/status'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        'status': taskStatus,
        'id': taskId,
      }),
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to update status');
    }
  }

  Future<void> deleteTask(String taskId) async {
    final response = await client.delete(
      Uri.parse('$_url/'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        'id': taskId,
      }),
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to delete task');
    }
  }
}
