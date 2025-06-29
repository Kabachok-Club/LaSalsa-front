import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:side_sheet/side_sheet.dart';
import '../models/task.dart';
import '../api/task_api.dart';
import 'task_detail_view.dart'; // Импортируем наш новый виджет

class TaskCard extends StatelessWidget {
  final Task task;
  final ValueChanged<bool?>? onStatusToggle;
  final TaskApi taskApi;
  final Function(Task updatedTask) onTaskUpdated; // Добавляем callback

  const TaskCard({
    super.key,
    required this.task,
    this.onStatusToggle,
    required this.taskApi,
    required this.onTaskUpdated, // Добавляем в конструктор
  });

  // Логика цвета остается без изменений
  Color getPlannedDateColor(DateTime? plannedAt) {
    if (plannedAt == null) return Colors.grey;
    final now = DateTime.now();
    if (plannedAt.isBefore(now)) return Colors.red;
    if (plannedAt.isAfter(now.add(const Duration(days: 7)))) return Colors.green;
    return Colors.orange;
  }

  // Наш новый метод для адаптивного показа
  void _showTaskDetails(BuildContext context) {
    // Получаем ширину экрана
    final screenWidth = MediaQuery.of(context).size.width;

    // Определяем точку перелома (breakpoint)
    const breakpoint = 768.0;

    if (screenWidth > breakpoint) {
      // --- ДЕСКТОПНАЯ ВЕРСИЯ: ПОКАЗЫВАЕМ БОКОВУЮ ПАНЕЛЬ ---
      SideSheet.right(
        context: context,
        width: MediaQuery.of(context).size.width * 0.4, // Например, 40% ширины экрана
        body: TaskDetailView(
          task: task,
          taskApi: taskApi,
          onTaskUpdated: onTaskUpdated,
        ),
      );
    } else {
      // --- МОБИЛЬНАЯ ВЕРСИЯ: ПОКАЗЫВАЕМ НИЖНЮЮ ПАНЕЛЬ ---
      showModalBottomSheet(
        context: context,
        // Позволяем панели занимать почти весь экран
        isScrollControlled: true, 
        builder: (context) {
          return ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.9,
            ),
            child: TaskDetailView(
              task: task,
              taskApi: taskApi,
              onTaskUpdated: onTaskUpdated,
            ),
          );
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final DateFormat dateFormat = DateFormat.yMMMMd('ru_RU');
    String dateText = '';
    if ((task.plannedAt != null) && (task.status != 'DONE')) {
      dateText = 'Планируется: ${dateFormat.format(task.plannedAt!.toLocal())}';
    } else if (task.closedAt != null) {
      dateText = 'Завершена: ${dateFormat.format(task.closedAt!.toLocal())}';
    }

    return Card(
      child: ListTile(
        leading: IconButton(
          onPressed: onStatusToggle != null
              ? () => onStatusToggle!(task.status == 'DONE' ? false : true)
              : null,
          icon: Icon(
            task.status == 'DONE' ? Icons.check_circle : Icons.radio_button_unchecked,
            color: task.status == 'DONE' ? Colors.green : Colors.grey,
          ),
        ),
        title: Text(task.name),
        subtitle: dateText.isNotEmpty
            ? Text(
                dateText,
                style: TextStyle(
                  color: task.closedAt != null ? Colors.blueAccent : getPlannedDateColor(task.plannedAt),
                  fontStyle: FontStyle.italic,
                ),
              )
            : null,
        onTap: () {
          // Вызываем наш новый адаптивный метод
          _showTaskDetails(context);
        },
      ),
    );
  }
}
