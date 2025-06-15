import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/task.dart';
import '../api/task_api.dart';

class TaskCard extends StatefulWidget {
  final Task task;
  final ValueChanged<bool?>? onStatusToggle;
  final TaskApi taskApi;

  const TaskCard({
    super.key,
    required this.task,
    this.onStatusToggle,
    required this.taskApi,
  });

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

  Color getPlannedDateColor(DateTime? plannedAt) {
    if (plannedAt == null) return Colors.grey;
    final now = DateTime.now();
    if (plannedAt.isBefore(now)) {
      return Colors.red; // Просроченная задача
    } else if (plannedAt.isAfter(now.add(const Duration(days: 7)))) {
      return Colors.green; // Задача с плановой датой более чем через неделю
    } else {
      return Colors.orange; // Задача с плановой датой в ближайшую неделю
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
    widget.taskApi
        .getTaskDetails(widget.task.id)
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
    String dateText = '';
    if ((widget.task.plannedAt != null) && (widget.task.status != 'DONE')) {
      dateText = 'Планируется: ${dateFormat.format(widget.task.plannedAt!.toLocal())}';
    } else if (widget.task.closedAt != null) {
      dateText = 'Завершена: ${dateFormat.format(widget.task.closedAt!.toLocal())}';
    }

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
        subtitle: dateText != ''
            ? Text(
                dateText,
                style: TextStyle(
                  color: widget.task.closedAt != null ? Colors.blueAccent : getPlannedDateColor(widget.task.plannedAt),
                  fontStyle: FontStyle.italic,
                ),
              )
            : null,
        onTap: () {
          showTaskDetails();
        },
      ),
    );
  }
}
