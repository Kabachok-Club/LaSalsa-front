import 'package:flutter/material.dart';
import 'package:kabachok_lasalsa_front/api/task_api.dart';
import '../models/task.dart';
import '../widgets/active_task_list.dart';
import '../widgets/completed_task_list.dart';
import '../widgets/task_input_field.dart';

class TaskListScreen extends StatefulWidget {
  final TaskApi taskApi;
  const TaskListScreen({super.key, required this.taskApi});

  @override
  State<TaskListScreen> createState() => _TaskListScreenState();
}

class _TaskListScreenState extends State<TaskListScreen> {
  List<Task> activeTasks = [];
  List<Task> doneTasks = [];
  DateTime? _plannedDate;

  final TextEditingController _newTaskController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadTasks();
  }

  Future<void> _loadTasks() async {
    try {
      final result = await widget.taskApi.fetchTasks();
      setState(() {
        activeTasks = result.where((t) => t.status != 'DONE').toList();
        doneTasks = result.where((t) => t.status == 'DONE').toList();
      });
    } catch (e) {
      debugPrint('Ошибка загрузки задач: $e');
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _plannedDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null && picked != _plannedDate) {
      setState(() {
        _plannedDate = picked;
      });
    }
  }

  void _addTask(String name, DateTime? plannedAt) async {
    if (name.isEmpty) return;

    final newTask = Task(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: name,
      description: '',
      status: 'TODO',
      plannedAt: plannedAt,
    );

    try {
      Task resultTask = await widget.taskApi.addTask(newTask);
      setState(() {
        activeTasks.add(resultTask);
        _newTaskController.clear();
        _plannedDate = null;
      });
    } catch (e) {
      debugPrint('Ошибка добавления задачи: $e');
    }
  }

  void _toggleStatus(Task task, bool? checked) async {
  String newStatus = checked == true ? 'DONE' : 'TODO';
  String previousStatus = task.status;
  Task? originalTask; // Для хранения оригинальной задачи перед изменением UI
  int? originalIndex; // Добавляем переменную для хранения индекса

  setState(() {
    if (checked == true) {
      originalIndex = activeTasks.indexOf(task); // Получаем индекс перед удалением
      originalTask = task; // Сохраняем оригинал
      activeTasks.removeWhere((t) => t.id == task.id);
      doneTasks.add(task.copyWith(status: newStatus)); // Обновляем UI
    } else {
      originalIndex = doneTasks.indexOf(task); // Получаем индекс перед удалением
      originalTask = task; // Сохраняем оригинал
      doneTasks.removeWhere((t) => t.id == task.id);
      activeTasks.insert(0, task.copyWith(status: newStatus)); // Обновляем UI
    }
  });

  final snackBarController = ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text('Задача ${checked == true ? 'выполнена' : 'возвращена'}!'),
      duration: const Duration(seconds: 3),
      action: SnackBarAction(
        label: 'Отменить',
        onPressed: () {
          setState(() {
            if (checked == true && originalIndex != null) {
              doneTasks.removeWhere((t) => t.id == task.id);
              activeTasks.insert(originalIndex!, originalTask!.copyWith(status: previousStatus)); // Вставляем на прежнее место
            } else if (originalIndex != null) {
              activeTasks.removeWhere((t) => t.id == task.id);
              doneTasks.insert(originalIndex!, originalTask!.copyWith(status: previousStatus)); // Вставляем на прежнее место
            }
          });
        },
      ),
    ),
  );

  // Ждем закрытия SnackBar
  final reason = await snackBarController.closed;

  // Если SnackBar закрылся не из-за действия "Отменить", отправляем изменения на бэк
  if (reason != SnackBarClosedReason.action) {
    widget.taskApi.setTaskStatus(task.id, newStatus);
  }
}

  void _reorderActiveTasks(int oldIndex, int newIndex) {
    setState(() {
      if (newIndex > oldIndex) newIndex -= 1;
      final task = activeTasks.removeAt(oldIndex);
      activeTasks.insert(newIndex, task);
    });
  }

  void _dismissTask(int index) {
    widget.taskApi.deleteTask(activeTasks[index].id);
    setState(() => activeTasks.removeAt(index));
  }

  @override
  void dispose() {
    _newTaskController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('LaSalsa – задачи')),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                ActiveTaskList(
                  tasks: activeTasks,
                  onStatusToggle: _toggleStatus,
                  onDismiss: _dismissTask,
                  onReorder: _reorderActiveTasks,
                  taskApi: widget.taskApi,
                ),
                const SizedBox(height: 24),
                CompletedTaskList(
                  tasks: doneTasks,
                  onStatusToggle: _toggleStatus,
                  taskApi: widget.taskApi,
                ),
              ],
            ),
          ),
          const Divider(),
          TaskInputField(
            controller: _newTaskController,
            onAdd: _addTask,
            selectedDate: _plannedDate,
            onSelectDate: () => _selectDate(context),
          ),
        ],
      ),
    );
  }
}
