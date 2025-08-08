import 'package:dio/dio.dart';

/// 백테스트 실행을 담당하는 서비스 클래스
class BacktestService {
  /// 백엔드 서버와 통신하기 위한 Dio 인스턴스
  static final Dio _dio = Dio(
    BaseOptions(
      baseUrl: 'http://52.79.115.136:8080',
      headers: {'Content-Type': 'application/json'},
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
    ),
  );

  static Future<Map<String, dynamic>> run({
    required Map<String, dynamic> pattern,
    required String symbol,
    required String stockName,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    try {
      // 서버에 백테스트 실행 요청
      final response = await _dio.post(
        '/backtests',
        data: {
          'pattern': pattern,
          'symbol': symbol,
          'stockName': stockName,
        },
      );

      if (response.statusCode == 200) {
        // 성공적으로 결과를 받으면 Map 형태로 반환
        return Map<String, dynamic>.from(response.data);
      } else {
        throw Exception(
            '백테스트 실패: 상태코드 ' + response.statusCode.toString());
      }
    } catch (e) {
      // 오류 발생 시 예외 전달
      throw Exception('백테스트 API 호출 오류: ' + e.toString());
    }
  }
}