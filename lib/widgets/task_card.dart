import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/task.dart';
import '../api/task_api.dart';

class TaskCard extends StatefulWidget {
  final Task task;
  final ValueChanged<bool?>? onStatusToggle;

  const TaskCard({super.key, required this.task, this.onStatusToggle});

  @override
  State<TaskCard> createState() => _TaskCardState();
}

class _TaskCardState extends State<TaskCard> {
  Color getStatusColor(String status) {
    switch (status) {
      case 'DONE':
        return Colors.green;
      case 'IN_PROGRESS':
        return Colors.amber;
      default:
        return Colors.grey;
    }
  }

  void _showTaskDialog(BuildContext context, Task taskDetails) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(taskDetails.name),
          content: Text(
            taskDetails.description.isNotEmpty
                ? taskDetails.description
                : 'Нет описания',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Закрыть'),
            ),
          ],
        );
      },
    );
  }

  void showTaskDetails() {
    TaskApi.getTaskDetails(widget.task.id)
        .then((taskDetails) {
          if (mounted) {
            _showTaskDialog(context, taskDetails);
          }
        })
        .catchError((error) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Ошибка загрузки деталей задачи')),
            );
          }
        });
  }

  @override
  Widget build(BuildContext context) {
    final DateFormat dateFormat = DateFormat.yMMMMd('ru_RU');
    return Card(
      child: ListTile(
        leading: IconButton(
          onPressed: widget.onStatusToggle != null
              ? () => widget.onStatusToggle!(
                  widget.task.status == 'DONE' ? false : true,
                )
              : null,
          icon: Icon(
            widget.task.status == 'DONE'
                ? Icons.check_circle
                : Icons.radio_button_unchecked,
            color: widget.task.status == 'DONE' ? Colors.green : Colors.grey,
          ),
        ),
        title: Text(widget.task.name),
        subtitle: Text(
          dateFormat.format(widget.task.createdAt.toLocal()),
          style: TextStyle(
            color: getStatusColor(widget.task.status),
            fontStyle: FontStyle.italic,
          ),
        ),
        onTap: () {
          showTaskDetails();
        },
      ),
    );
  }
}
