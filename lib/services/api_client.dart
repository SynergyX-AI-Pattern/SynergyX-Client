// lib/services/api_client.dart
import 'dart:async';

import 'package:dio/dio.dart';

import '../models/auth_response.dart';
import 'auth_state.dart';

class ApiClient {
  static final String _baseUrl = const String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://52.79.115.136:8080',
  );

  static final Dio dio = Dio(
    BaseOptions(
      baseUrl: _baseUrl,
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
            // 최신 토큰이 없는 경우, 서버에 인증 없이 접근하도록 둔다.
            print('🔴 No access token on request: ${options.method} ${options.uri}');
          } else {
            // 항상 최신 access token을 헤더에 주입한다.
            print('🟢 Using token (len=${token.length}) for ${options.method} ${options.uri}');
            options.headers['Authorization'] = 'Bearer $token';
          }
          handler.next(options);
        },
        onError: (error, handler) async {
          final statusCode = error.response?.statusCode ?? 0;
          final requestOptions = error.requestOptions;

          final hasRetried = requestOptions.extra['retried'] == true;
          final isUnauthorized = statusCode == 401;
          final isAuthEndpoint = requestOptions.path.contains('/auth/login');

          if (isUnauthorized && !hasRetried && !isAuthEndpoint) {
            try {
              await _refreshAccessToken();
              final newToken = AuthState.accessToken;
              if (newToken == null || newToken.isEmpty) {
                return handler.next(error);
              }

              requestOptions.headers['Authorization'] = 'Bearer $newToken';
              requestOptions.extra['retried'] = true;

              final response = await dio.fetch<dynamic>(requestOptions);
              return handler.resolve(response);
            } catch (refreshError) {
              // refresh token 갱신에 실패하면 기존 에러를 그대로 전달한다.
              handler.next(error);
              return;
            }
          }

          handler.next(error);
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

  static final Dio _refreshDio = Dio(
    BaseOptions(
      baseUrl: _baseUrl,
      contentType: Headers.jsonContentType,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 20),
      headers: {'Accept': 'application/json'},
    ),
  );

  static Future<void>? _refreshFuture;

  /// refresh token으로 access token을 재발급한다.
  static Future<void> _refreshAccessToken() {
    if (_refreshFuture != null) {
      return _refreshFuture!;
    }

    final completer = Completer<void>();
    _refreshFuture = completer.future;

    _performTokenRefresh().then((_) {
      completer.complete();
    }).catchError((error, stackTrace) {
      completer.completeError(error, stackTrace);
    }).whenComplete(() {
      _refreshFuture = null;
    });

    return completer.future;
  }

  static Future<void> _performTokenRefresh() async {
    final refreshToken = AuthState.refreshToken;
    final savedEmail = AuthState.email;
    final savedPassword = AuthState.password;

    if (refreshToken == null || refreshToken.isEmpty) {
      await AuthState.clear();
      throw DioException(
        requestOptions: RequestOptions(path: '/auth/login'),
        error: 'No refresh token',
        type: DioExceptionType.unknown,
      );
    }

    if (savedEmail == null || savedEmail.isEmpty ||
        savedPassword == null || savedPassword.isEmpty) {
      // 이메일/비밀번호가 없으면 자동 재로그인을 수행할 수 없다.
      await AuthState.clear();
      throw DioException(
        requestOptions: RequestOptions(path: '/auth/login'),
        error: 'Missing cached credentials',
        type: DioExceptionType.unknown,
      );
    }

    final response = await _refreshDio.post<Map<String, dynamic>>(
      '/auth/login',
      data: {
        'email': savedEmail,
        'password': savedPassword,
        'refreshToken': refreshToken,
      },
      options: Options(validateStatus: (s) => s != null && s < 500),
    );

    final data = response.data;
    if (data == null || data['result'] is! Map<String, dynamic>) {
      await AuthState.clear();
      throw DioException(
        requestOptions: response.requestOptions,
        response: response,
        error: 'Invalid refresh response',
        type: DioExceptionType.badResponse,
      );
    }

    final loginResponse = LoginResponse.fromJson(data);

    if (!loginResponse.isSuccess ||
        (loginResponse.accessToken ?? '').isEmpty) {
      await AuthState.clear();
      throw DioException(
        requestOptions: response.requestOptions,
        response: response,
        error: 'Failed to refresh token',
        type: DioExceptionType.badResponse,
      );
    }

    await AuthState.updateFromLogin(
      loginResponse,
      savedEmail,
      userPassword: savedPassword,
    );
  }
}