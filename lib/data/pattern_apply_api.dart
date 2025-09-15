import 'package:dio/dio.dart';
import 'package:stockapp/services/api_client.dart';

class PatternApplyApi {
  // ApiClient의 Dio를 사용하여 중복 인스턴스를 없앤다.
  final Dio _dio = ApiClient.dio;

  /// 적용 패턴 삭제
  Future<void> delete(int patternApplyId) async {
    final res = await _dio.delete(
      '/pattern-applies/$patternApplyId',
      options: Options(validateStatus: (s) => s != null && s < 500),
    );
    if (res.statusCode == 200 && res.data is Map<String, dynamic>) {
      final data = res.data as Map<String, dynamic>;
      if (data['isSuccess'] == true) return;
      throw Exception(data['message'] ?? '패턴 해제 실패');
    }
    throw Exception('HTTP ${res.statusCode}');
  }

  /// 패턴 알림 토글
  /// 성공 시: true/false (서버가 상태를 반환하면), 상태 미반환 시 null
  Future<bool?> toggleNotification(int patternApplyId) async {
    final res = await _dio.patch(
      '/pattern-applies/$patternApplyId/notification',
      options: Options(validateStatus: (s) => s != null && s < 500),
    );
    if (res.statusCode == 200 && res.data is Map<String, dynamic>) {
      final data = res.data as Map<String, dynamic>;
      if (data['isSuccess'] == true) {
        final result = data['result'];
        if (result is Map && result['isAlertEnabled'] is bool) {
          return result['isAlertEnabled'] as bool;
        }
        return null;
      }
      throw Exception(data['message'] ?? '알림 토글 실패');
    }
    throw Exception('HTTP ${res.statusCode}');
  }

  /// ★ 패턴 적용 (POST /pattern-applies)
  /// body: { patternId, stockId, entryAt(ISO8601 UTC), minValidReturn }
  /// 성공 시 생성된 patternApplyId 반환
  Future<int> applySimple({
    required int patternId,
    required int stockId,
    DateTime? entryAt,
    num minValidReturn = 0,
  }) async {
    final body = {
      'patternId': patternId,
      'stockId': stockId,
      'entryAt': (entryAt ?? DateTime.now()).toUtc().toIso8601String(),
      'minValidReturn': minValidReturn,
    };

    final res = await _dio.post(
      '/pattern-applies',
      data: body,
      options: Options(validateStatus: (s) => s != null && s < 500),
    );

    if (res.statusCode == 200 && res.data is Map<String, dynamic>) {
      final data = res.data as Map<String, dynamic>;
      if (data['isSuccess'] == true) {
        final result = data['result'];
        final id = (result is Map)
            ? (result['patternApplyId'] ?? result['id'])
            : null;
        if (id is num) return id.toInt();
        throw Exception('응답에 patternApplyId가 없습니다: ${res.data}');
      }
      throw Exception(data['message'] ?? '패턴 적용 실패');
    }
    throw Exception('HTTP ${res.statusCode}: ${res.data}');
  }
}
