//pattern_applies_api

import 'package:dio/dio.dart';
import '../models/pattern_applies.dart';

/// 패턴 적용 관련 API 호출 모음
class PatternApplyApi {
  static final Dio _dio = Dio(
    BaseOptions(
      baseUrl: 'http://pattern-catcher.net:8080',
      headers: {'Content-Type': 'application/json'},
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
    ),
  )..interceptors.add(LogInterceptor(requestBody: true, responseBody: true));

  /// 패턴을 특정 종목에 적용 (POST /pattern-applies)
  static Future<void> createPatternApply({
    required int patternId,
    required int stockId,
    required DateTime entryAt,
    required int minValidReturn,
  }) async {
    await _dio.post(
      '/pattern-applies',
      data: {
        'patternId': patternId,
        'stockId': stockId,
        'entryAt': entryAt.toIso8601String(),
        'minValidReturn': minValidReturn,
      },
    );
  }

  /// 패턴 적용 해제 (DELETE /pattern-applies/{patternApplyId})
  static Future<void> deletePatternApply(int patternApplyId) async {
    await _dio.delete('/pattern-applies/$patternApplyId');
  }

  /// 패턴 적용 정보 수정 (PATCH /pattern-applies/{patternApplyId})
  static Future<void> updatePatternApply({
    required int patternApplyId,
    DateTime? entryAt,
    int? minValidReturn,
  }) async {
    final data = <String, dynamic>{};
    if (entryAt != null) data['entryAt'] = entryAt.toIso8601String();
    if (minValidReturn != null) data['minValidReturn'] = minValidReturn;
    await _dio.patch('/pattern-applies/$patternApplyId', data: data);
  }

  /// 패턴 적용 알림 토글 (PATCH /pattern-applies/{patternApplyId}/notification)
  static Future<void> toggleNotification(int patternApplyId) async {
    await _dio.patch('/pattern-applies/$patternApplyId/notification');
  }

  /// 종목-패턴 상세 조회 (GET /pattern-applies/stocks/{stockId})
  static Future<PatternApplies?> getPatternApplyByStock(int stockId) async {
    final res = await _dio.get('/pattern-applies/stocks/$stockId');
    if (res.statusCode == 404) return null;
    if (res.data is Map<String, dynamic>) {
      return PatternApplies.fromJson(res.data as Map<String, dynamic>);
    }
    throw Exception('응답 형식이 올바르지 않습니다');
  }
}