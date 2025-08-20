import 'package:dio/dio.dart';
import '../models/pattern_apply.dart';

class PatternApi {
  final Dio _dio = Dio(
    BaseOptions(
      baseUrl: 'http://pattern-catcher.net:8080',
      // ★ 4xx도 응답은 받게 하고 우리가 직접 분기
      validateStatus: (s) => s != null && s >= 200 && s < 500,
      connectTimeout: const Duration(seconds: 8),
      receiveTimeout: const Duration(seconds: 8),
    ),
  );

  /// 패턴이 없으면 null 반환
  Future<PatternApply?> fetchPatternApply(int stockId) async {
    try {
      final res = await _dio.get('/pattern-applies/stocks/$stockId');

      // 404 => 패턴 없음
      if (res.statusCode == 404) return null;

      if (res.data is Map<String, dynamic>) {
        final data = res.data as Map<String, dynamic>;

        // 성공
        if (data['isSuccess'] == true) {
          return PatternApply.fromJson(data);
        }

        // 서버가 200으로 내려도 isSuccess=false + code로 구분
        final code = data['code']?.toString() ?? '';
        if (code == 'PATTERN_APPLY404') {
          return null; // 패턴 없음
        }

        // 그 외는 진짜 에러
        throw Exception(data['message'] ?? '패턴 조회 실패');
      }

      throw Exception('예상치 못한 응답 형식');
    } on DioException catch (e) {
      // 네트워크/타임아웃 등은 에러
      if (e.response?.statusCode == 404) return null; // 혹시 여기로 온 404도 처리
      rethrow;
    }
  }
}
