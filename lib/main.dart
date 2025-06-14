import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'screens/task_list_screen.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'api/task_api.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized(); // Обязательно для async main
  await initializeDateFormatting('ru_RU', null); // Инициализация локализации дат
  runApp(const LaSalsaApp());
}

class LaSalsaApp extends StatelessWidget {
  const LaSalsaApp({super.key});

  @override
  Widget build(BuildContext context) {
    final httpClient = http.Client();
    final taskApiService = TaskApi(client: httpClient);
    return MaterialApp(
      title: 'LaSalsa – Таски',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color.fromARGB(255, 43, 78, 233)),
        useMaterial3: true,
      ),
      home: TaskListScreen(taskApi: taskApiService),
    );
  }
}
