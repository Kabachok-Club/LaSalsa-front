import 'package:flutter/material.dart';
import '../models/task.dart';
import 'task_card.dart';
import '../api/task_api.dart';

class CompletedTaskList extends StatelessWidget {
  final List<Task> tasks;
  final void Function(Task task, bool? checked) onStatusToggle;
  final TaskApi taskApi;
  final Function(Task updatedTask) onTaskUpdated; // Добавляем callback

  const CompletedTaskList({
    super.key,
    required this.tasks,
    required this.onStatusToggle,
    required this.taskApi,
    required this.onTaskUpdated,
  });

  @override
  Widget build(BuildContext context) {
    return ExpansionTile(
      title: const Text('Выполненные задачи'),
      initiallyExpanded: false,
      children: tasks.map(
        (task) => TaskCard(
          task: task,
          onStatusToggle: (checked) => onStatusToggle(task, checked),
          taskApi: taskApi,
          onTaskUpdated: onTaskUpdated,
        ),
      ).toList(),
    );
  }
}
