import 'package:dio/dio.dart';
import '../models/auth_response.dart';
import 'package:stockapp/services/api_client.dart';

class AuthService {
  final Dio _dio = ApiClient.dio;

  Future<LoginResponse> login(String email, String password) async {
    final res = await _dio.post<Map<String, dynamic>>(
      '/auth/login',
      data: {'email': email, 'password': password},
      options: Options(validateStatus: (s) => s != null && s < 500),
    );
    if (res.data == null) {
      throw Exception('서버 응답이 비어있습니다.');
    }
    return LoginResponse.fromJson(res.data!);
  }

  Future<SimpleResponse> signup(
      String name,
      String email,
      String password,
      bool marketing,
      bool event,
      ) async {
    final res = await _dio.post<Map<String, dynamic>>(
      '/auth/signup',
      data: {
        'name': name,
        'email': email,
        'password': password,
        'marketing': marketing,
        'event': event,
      },
      options: Options(validateStatus: (s) => s != null && s < 500),
    );
    if (res.data == null) throw Exception('서버 응답이 비어있습니다.');
    return SimpleResponse.fromJson(res.data!);
  }

  Future<SimpleResponse> logout() async {
    final res = await _dio.post<Map<String, dynamic>>(
      '/auth/logout',
      options: Options(validateStatus: (s) => s != null && s < 500),
    );
    if (res.data == null) throw Exception('서버 응답이 비어있습니다.');
    return SimpleResponse.fromJson(res.data!);
  }

  Future<SimpleResponse> withdraw() async {
    final res = await _dio.post<Map<String, dynamic>>(
      '/auth/withdraw',
      options: Options(validateStatus: (s) => s != null && s < 500),
    );
    if (res.data == null) throw Exception('서버 응답이 비어있습니다.');
    return SimpleResponse.fromJson(res.data!);
  }
}
