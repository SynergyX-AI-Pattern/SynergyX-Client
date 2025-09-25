import 'package:dio/dio.dart';
import 'package:stockapp/models/auth_response.dart';
import 'package:stockapp/services/api_client.dart';

/// 사용자 관련 API 호출을 담당하는 서비스
/// - FCM 토큰 저장
/// - 프로필 조회 및 수정
class UserService {
  final Dio _dio = ApiClient.dio;

  /// FCM 토큰을 서버에 저장
  Future<SimpleResponse> saveFcmToken(String fcmToken) async {
    final res = await _dio.post<Map<String, dynamic>>(
      '/users/fcm-token',
      data: {'fcmToken': fcmToken},
      options: Options(validateStatus: (s) => s != null && s < 500),
    );
    if (res.data == null) {
      throw Exception('서버 응답이 비어있습니다.');
    }
    return SimpleResponse.fromJson(res.data!);
  }

  /// 프로필(사용자 이름) 조회
  Future<String> fetchProfile() async {
    final res = await _dio.get<Map<String, dynamic>>(
      '/users/profile',
      options: Options(validateStatus: (s) => s != null && s < 500),
    );
    if (res.data == null) {
      throw Exception('서버 응답이 비어있습니다.');
    }
    return res.data!['result'] as String? ?? '';
  }

  /// 프로필(사용자 이름) 수정
  Future<SimpleResponse> updateProfile(String name) async {
    final res = await _dio.post<Map<String, dynamic>>(
      '/users/profile',
      data: {'name': name},
      options: Options(validateStatus: (s) => s != null && s < 500),
    );
    if (res.data == null) {
      throw Exception('서버 응답이 비어있습니다.');
    }
    return SimpleResponse.fromJson(res.data!);
  }
}
