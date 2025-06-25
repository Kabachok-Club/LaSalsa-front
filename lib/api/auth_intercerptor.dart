import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';


class AuthInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      // Если пользователя нет, можно завершить запрос с ошибкой
      handler.reject(DioException(requestOptions: options, message: 'User not authenticated'));
      return;
    }

    // Получаем свежий токен
    final token = await user.getIdToken();
    
    // Добавляем заголовок
    options.headers['Authorization'] = 'Bearer $token';
    // Продолжаем выполнение запроса
    super.onRequest(options, handler);
  }
}