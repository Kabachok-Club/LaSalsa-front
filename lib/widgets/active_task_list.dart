import 'package:flutter/material.dart';
import '../models/task.dart';
import 'task_card.dart';
import '../api/task_api.dart';


class ActiveTaskList extends StatelessWidget {
  final List<Task> tasks;
  final void Function(Task task, bool? checked) onStatusToggle;
  final void Function(int oldIndex, int newIndex) onReorder;
  final void Function(int index) onDismiss;
  final Function(Task updatedTask) onTaskUpdated; // Добавляем callback
  final TaskApi taskApi;

  const ActiveTaskList({
    super.key,
    required this.tasks,
    required this.onStatusToggle,
    required this.onReorder,
    required this.onDismiss,
    required this.taskApi,
    required this.onTaskUpdated,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Текущие задачи', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        ReorderableListView(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          onReorder: onReorder,
          children: [
            for (int index = 0; index < tasks.length; index++)
              Dismissible(
                key: ValueKey(tasks[index].id),
                background: Container(color: Colors.red),
                onDismissed: (_) => onDismiss(index),
                child: TaskCard(
                  task: tasks[index],
                  onStatusToggle: (checked) => onStatusToggle(tasks[index], checked),
                  taskApi: taskApi,
                  onTaskUpdated: onTaskUpdated,
                ),
              ),
          ],
        ),
      ],
    );
  }
}
