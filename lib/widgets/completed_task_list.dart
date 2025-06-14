import 'package:flutter/material.dart';
import '../models/task.dart';
import 'task_card.dart';

class CompletedTaskList extends StatelessWidget {
  final List<Task> tasks;
  final void Function(Task task, bool? checked) onStatusToggle;

  const CompletedTaskList({
    super.key,
    required this.tasks,
    required this.onStatusToggle,
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
        ),
      ).toList(),
    );
  }
}
