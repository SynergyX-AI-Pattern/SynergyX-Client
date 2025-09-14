import 'package:dio/dio.dart';
import '../models/auth_response.dart';
// 인증 상태를 관리하는 전역 싱글턴 클래스
import 'package:stockapp/services/auth_state.dart';
import 'package:stockapp/services/api_client.dart';

/// 인증 관련 API 호출을 담당하는 서비스
class AuthService {
  final Dio _dio = ApiClient.dio;

  /// 로그인 요청
  /// POST /auth/login
  /// [email]과 [password]를 받아 토큰 정보를 반환합니다.
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

  /// 회원가입 요청
  /// POST /auth/signup
  /// [name], [email], [password]와 함께 마케팅([marketing])·이벤트([event])
  /// 수신 동의 여부를 전달하고, 서버의 결과를 [SimpleResponse]로 반환합니다.
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
    if (res.data == null) {
      throw Exception('서버 응답이 비어있습니다.');
    }
    return SimpleResponse.fromJson(res.data!);
  }

  /// 로그아웃 요청
  /// POST /auth/logout
  /// 모든 요청에 토큰이 자동으로 포함되므로 별도 인자 불필요
  Future<SimpleResponse> logout() async {
    final res = await _dio.post<Map<String, dynamic>>(
      '/auth/logout',
      options: Options(validateStatus: (s) => s != null && s < 500),
    );
    if (res.data == null) {
      throw Exception('서버 응답이 비어있습니다.');
    }
    return SimpleResponse.fromJson(res.data!);
  }

  /// 회원 탈퇴 요청
  /// POST /auth/withdraw
  /// 저장된 토큰이 자동으로 헤더에 포함됩니다.
  Future<SimpleResponse> withdraw() async {
    final res = await _dio.post<Map<String, dynamic>>(
      '/auth/withdraw',
      options: Options(validateStatus: (s) => s != null && s < 500),
    );
    if (res.data == null) {
      throw Exception('서버 응답이 비어있습니다.');
    }
    return SimpleResponse.fromJson(res.data!);
  }
}