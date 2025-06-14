import 'package:flutter/material.dart';
import 'package:kabachok_lasalsa_front/api/task_api.dart';
import '../models/task.dart';
import '../widgets/active_task_list.dart';
import '../widgets/completed_task_list.dart';
import '../widgets/task_input_field.dart';

class TaskListScreen extends StatefulWidget {
  const TaskListScreen({super.key});

  @override
  State<TaskListScreen> createState() => _TaskListScreenState();
}

class _TaskListScreenState extends State<TaskListScreen> {
  List<Task> activeTasks = [];
  List<Task> doneTasks = [];

  final TextEditingController _newTaskController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadTasks();
  }

  Future<void> _loadTasks() async {
    try {
      final result = await TaskApi.fetchTasks();
      setState(() {
        activeTasks = result.where((t) => t.status != 'DONE').toList();
        doneTasks = result.where((t) => t.status == 'DONE').toList();
      });
    } catch (e) {
      debugPrint('Ошибка загрузки задач: $e');
    }
  }

  void _addTask() async {
    final name = _newTaskController.text.trim();
    if (name.isEmpty) return;

    final newTask = Task(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: name,
      description: '',
      status: 'TODO',
      createdAt: DateTime.now(),
    );

    try {
      debugPrint('Добавление задачи: $newTask');
      await TaskApi.addTask(newTask);
      setState(() {
        activeTasks.add(newTask);
        _newTaskController.clear();
      });
    } catch (e) {
      debugPrint('Ошибка добавления задачи: $e');
    }
  }

  void _toggleStatus(Task task, bool? checked) {
    String newStatus = checked == true ? 'DONE' : 'TODO';
    TaskApi.setTaskStatus(task.id, newStatus);

    final updated = Task(
      id: task.id,
      name: task.name,
      description: task.description,
      status: newStatus,
      createdAt: task.createdAt,
    );

    setState(() {
      if (checked == true) {
        activeTasks.removeWhere((t) => t.id == task.id);
        doneTasks.add(updated);
      } else {
        doneTasks.removeWhere((t) => t.id == task.id);
        activeTasks.add(updated);
      }
    });
  }

  void _reorderActiveTasks(int oldIndex, int newIndex) {
    setState(() {
      if (newIndex > oldIndex) newIndex -= 1;
      final task = activeTasks.removeAt(oldIndex);
      activeTasks.insert(newIndex, task);
    });
  }

  void _dismissTask(int index) {
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
      appBar: AppBar(title: const Text('LaSalsa – Мои задачи')),
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
                ),
                const SizedBox(height: 24),
                CompletedTaskList(
                  tasks: doneTasks,
                  onStatusToggle: _toggleStatus,
                ),
              ],
            ),
          ),
          const Divider(),
          TaskInputField(controller: _newTaskController, onAdd: _addTask),
        ],
      ),
    );
  }
}
