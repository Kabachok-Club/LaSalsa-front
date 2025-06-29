import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:kabachok_lasalsa_front/api/task_api.dart';
import 'package:kabachok_lasalsa_front/models/task.dart';

class TaskDetailView extends StatefulWidget {
  final Task task;
  final TaskApi taskApi;

  final Function(Task updatedTask) onTaskUpdated;

  const TaskDetailView({
    super.key,
    required this.task,
    required this.taskApi,
    required this.onTaskUpdated,
  });

  @override
  State<StatefulWidget> createState() => _TaskDetailViewState();
}

class _TaskDetailViewState extends State<TaskDetailView> {
  late TextEditingController _nameController;
  late TextEditingController _descriptionController;
  late String _currentStatus;
  late DateTime? _plannedAt; // <-- НОВОЕ: состояние для даты
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.task.name);
    _descriptionController = TextEditingController(
      text: widget.task.description,
    );
    _currentStatus = widget.task.status;
    _plannedAt = widget.task.plannedAt;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _plannedAt ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != _plannedAt) {
      setState(() {
        _plannedAt = picked;
      });
    }
  }

  Future<void> _saveTask() async {
    // Проверяем, есть ли изменения
    if (_nameController.text == widget.task.name &&
        _descriptionController.text == widget.task.description &&
        _currentStatus == widget.task.status) {
      Navigator.of(context).pop(); // Просто закрываем, если изменений нет
      return;
    }

    setState(() => _isLoading = true);

    try {
      // Создаем обновленную задачу
      // ВАЖНО: нужно иметь метод copyWith в вашей модели Task для удобства
      final updatedTask = widget.task.copyWith(
        name: _nameController.text,
        description: _descriptionController.text,
        status: _currentStatus,
        plannedAt: _plannedAt,
      );
      // Отправляем на бэкенд
      // Вам нужно будет создать метод updateTask в вашем TaskApi
      final savedTask = await widget.taskApi.updateTask(
        updatedTask,
        widget.task.id,
      );

      if (mounted) {
        // Вызываем callback, чтобы обновить UI на главном экране
        widget.onTaskUpdated(savedTask);
        Navigator.of(context).pop(); // Закрываем панель
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Ошибка сохранения задачи')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final DateFormat dateFormat = DateFormat.yMMMMd('ru_RU');
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Заголовок
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Детали задачи',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          ),
          const Divider(height: 32),

          // Поля для редактирования
          TextField(
            controller: _nameController,
            decoration: const InputDecoration(
              labelText: 'Название',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),
          // Выбор статуса
          DropdownButtonFormField<String>(
            value: _currentStatus,
            decoration: const InputDecoration(
              labelText: 'Статус',
              border: OutlineInputBorder(),
            ),
            items: ['TODO', 'IN_PROGRESS', 'CANCELLED', 'DONE']
                .map(
                  (status) =>
                      DropdownMenuItem(value: status, child: Text(status)),
                )
                .toList(),
            onChanged: (value) {
              if (value != null) {
                setState(() => _currentStatus = value);
              }
            },
          ),
          const SizedBox(height: 8,),
          TextField(
            controller: _descriptionController,
            decoration: const InputDecoration(
              labelText: 'Описание',
              border: OutlineInputBorder(),
            ),
            maxLines: 5,
          ),
          const SizedBox(height: 16),
          // --- НОВЫЙ БЛОК ДЛЯ ВЫБОРА ДАТЫ ---
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade400),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _plannedAt == null
                      ? 'Не задана'
                      : dateFormat.format(_plannedAt!.toLocal()),
                  style: const TextStyle(fontSize: 16),
                ),
                Row(
                  children: [
                    // Кнопка сброса даты
                    if (_plannedAt != null)
                      IconButton(
                        icon: const Icon(Icons.clear, color: Colors.grey),
                        tooltip: 'Сбросить дату',
                        onPressed: () => setState(() => _plannedAt = null),
                      ),
                    // Кнопка вызова календаря
                    IconButton(
                      icon: const Icon(
                        Icons.calendar_today,
                        color: Colors.blue,
                      ),
                      tooltip: 'Выбрать дату',
                      onPressed: () => _selectDate(context),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const Spacer(), // Занимает все доступное пространство
          // Кнопка сохранения
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _isLoading ? null : _saveTask,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: _isLoading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text('Сохранить'),
            ),
          ),
        ],
      ),
    );
  }
}
