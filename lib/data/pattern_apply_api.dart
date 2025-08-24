import 'package:dio/dio.dart';
import 'package:stockapp/data/dio_client.dart';

class PatternApplyApi {
  final dio = Dio(
    BaseOptions(
      baseUrl: 'http://pattern-catcher.net:8080',
      connectTimeout: const Duration(seconds: 8),
      receiveTimeout: const Duration(seconds: 8),
      // 4xx도 우리가 직접 분기해서 처리
      validateStatus: (s) => s != null && s < 500,
    ),
  )..interceptors.add(LogInterceptor(
      requestBody: true, responseBody: true, requestHeader: false, responseHeader: false));

  /// 적용 패턴 삭제
  Future<void> delete(int patternApplyId) async {
    final res = await dio.delete('/pattern-applies/$patternApplyId');
    if (res.statusCode == 200 && res.data is Map<String, dynamic>) {
      final data = res.data as Map<String, dynamic>;
      if (data['isSuccess'] == true) return;
      throw Exception(data['message'] ?? '패턴 해제 실패');
    }
    throw Exception('HTTP ${res.statusCode}');
  }

  /// 성공 시: true/false (서버가 상태를 반환한 경우)
  /// 성공하지만 상태 미반환 시: null
  /// 실패 시: 예외
  Future<bool?> toggleNotification(int patternApplyId) async {
    final res = await dio.patch('/pattern-applies/$patternApplyId/notification');

    // 디버깅 시에 켜두세요
    // print('toggleNotification status=${res.statusCode} data=${res.data}');

    if (res.statusCode == 200 && res.data is Map<String, dynamic>) {
      final data = res.data as Map<String, dynamic>;
      if (data['isSuccess'] == true) {
        final result = data['result'];
        if (result is Map && result['isAlertEnabled'] is bool) {
          return result['isAlertEnabled'] as bool;
        }
        // 성공이지만 상태필드가 없으면 null 반환 (UI는 낙관적 토글 유지)
        return null;
      }
      // 서버가 성공이 아닌 이유 전달
      throw Exception(data['message'] ?? '알림 토글 실패');
    }
    throw Exception('HTTP ${res.statusCode}');
  }
}
