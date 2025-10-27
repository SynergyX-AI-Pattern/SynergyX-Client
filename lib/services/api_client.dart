import 'dart:async';
import 'package:dio/dio.dart';
import '../models/auth_response.dart';
import 'auth_state.dart';
import '../screens/login_screen.dart';
import 'package:stockapp/main.dart';
import 'package:flutter/material.dart';

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
          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          } else {
            print('🔴 No access token for ${options.method} ${options.uri}');
          }
          handler.next(options);
        },
        onError: (error, handler) async {
          final statusCode = error.response?.statusCode ?? 0;
          final requestOptions = error.requestOptions;

          final hasRetried = requestOptions.extra['retried'] == true;
          final isUnauthorized = statusCode == 401;
          final isAuthEndpoint = requestOptions.path.contains('/auth');

          // refresh 로직
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
            } catch (_) {
              await AuthState.clear();
              // 🔥 refresh 실패 → 로그인 화면으로 이동
              navigatorKey.currentState?.pushAndRemoveUntil(
                MaterialPageRoute(builder: (_) => const LoginScreen()),
                    (route) => false,
              );
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

  /// Refresh token으로 access token을 갱신
  static Future<void> _refreshAccessToken() {
    if (_refreshFuture != null) return _refreshFuture!;

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

    if (refreshToken == null || refreshToken.isEmpty) {
      await AuthState.clear();
      throw DioException(
        requestOptions: RequestOptions(path: '/auth/refresh'),
        error: 'No refresh token found',
        type: DioExceptionType.unknown,
      );
    }

    // ✅ refresh 전용 API 호출
    final response = await _refreshDio.post<Map<String, dynamic>>(
      '/auth/refresh',
      data: {'refreshToken': refreshToken},
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
    if (!loginResponse.isSuccess || (loginResponse.accessToken ?? '').isEmpty) {
      await AuthState.clear();
      throw DioException(
        requestOptions: response.requestOptions,
        response: response,
        error: 'Failed to refresh token',
        type: DioExceptionType.badResponse,
      );
    }

    await AuthState.updateTokens(
      newAccessToken: loginResponse.accessToken!,
      newRefreshToken: loginResponse.refreshToken,
    );
  }
}
