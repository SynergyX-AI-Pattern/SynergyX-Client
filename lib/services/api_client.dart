// lib/services/api_client.dart
import 'package:dio/dio.dart';
import 'auth_state.dart';

class ApiClient {
  static final Dio dio = Dio(
    BaseOptions(
      baseUrl: const String.fromEnvironment(
        'API_BASE_URL',
        defaultValue: 'http://52.79.115.136:8080',
      ),
      contentType: Headers.jsonContentType,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 20),
      headers: {'Accept': 'application/json'},
    ),
  )
    ..interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          final token = AuthState.accessToken;
          if (token == null || token.isEmpty) {
            print('🔴 No access token on request: ${options.method} ${options.uri}');
          } else {
            print('🟢 Using token (len=${token.length}) for ${options.method} ${options.uri}');
            options.headers['Authorization'] = 'Bearer $token'; // 공백 반드시 유지
          }
          handler.next(options);
        },
      ),
    )
    ..interceptors.add(
      LogInterceptor(
        request: true,
        requestBody: true,
        requestHeader: true,
        responseBody: true,
        error: true,
      ),
    );

}
