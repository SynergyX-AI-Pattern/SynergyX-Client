import 'package:dio/dio.dart';
import '../models/auth_response.dart';
// 인증 상태를 관리하는 전역 싱글턴 클래스
import 'package:stockapp/services/auth_state.dart';

/// 인증 관련 API 호출을 담당하는 서비스
class AuthService {
  /// Dio 인스턴스. baseUrl은 서버의 공통 주소만 설정하고
  /// 각 API 경로는 요청 시에 직접 지정합니다.
  final Dio _dio = Dio(
    BaseOptions(
      // 기본 서버 주소
      baseUrl: const String.fromEnvironment(
        'API_BASE_URL',
        defaultValue: 'http://52.79.115.136:8080',
      ),
      // 모든 요청은 JSON 바디를 사용
      contentType: Headers.jsonContentType,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 20),
    ),
  )
    ..interceptors.add(
      // 모든 요청에 저장된 토큰을 자동으로 헤더에 추가
      InterceptorsWrapper(
        onRequest: (options, handler) {
          final token = AuthState.accessToken;
          if (token != null) {
            options.headers['Authorization'] = 'Bearer ' + token;
          }
          return handler.next(options);
        },
      ),
    )
    ..interceptors.add(
      // 요청/응답 로깅 인터셉터
      LogInterceptor(
        request: true,
        requestHeader: false,
        requestBody: true,
        responseHeader: false,
        responseBody: true,
        error: true,
      ),
    );

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