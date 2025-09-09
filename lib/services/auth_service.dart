import 'package:dio/dio.dart';

/// 인증 관련 API 호출을 담당하는 서비스
class AuthService {
  final Dio _dio = Dio(
    BaseOptions(
      baseUrl: 'https://example.com', // TODO: 서버 주소로 변경
    ),
  );

  /// 로그인 요청
  Future<bool> login(String email, String password) async {
    // TODO: 서버 연동 후 목데이터 로직 제거
    if (email == 'example@email.com' && password == '12345') {
      return true;
    }
    return false;

    // 실제 서버
    // try {
    //   final response = await _dio.post('/auth/login',
    //       data: {'email': email, 'password': password});
    //   return response.statusCode == 200;
    // } catch (_) {
    //   return false;
    // }
  }

  /// 회원가입 요청
  Future<bool> signup(String name, String email, String password) async {
    try {
      final response = await _dio.post('/auth/signup',
          data: {'name': name, 'email': email, 'password': password});
      return response.statusCode == 200;
    } catch (_) {
      return false;
    }
  }
}