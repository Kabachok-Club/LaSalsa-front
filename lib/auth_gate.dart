import "package:firebase_auth/firebase_auth.dart";
import "package:flutter/material.dart";
import "package:kabachok_lasalsa_front/screens/task_list_screen.dart";

import 'api/task_api.dart';    
import 'screens/login_screen.dart';
class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {

    final taskApiService = TaskApi();

    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const LoginScreen();
        }
        return TaskListScreen(taskApi: taskApiService);
      },
    );
  }
}
