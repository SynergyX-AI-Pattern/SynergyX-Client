// backtest_api.dart
import 'package:dio/dio.dart';
export 'package:stockapp/models/backtest_result.dart';

class BacktestService {
  static final Dio _dio = Dio(
    BaseOptions(
      baseUrl: 'http://52.79.115.136:8080',
      headers: {'Content-Type': 'application/json'},
    ),
  );

  static Future<List<Map<String, dynamic>>> fetchBacktestList({int? patternId}) async {
    try {
      final res = await _dio.get(
        '/backtests/results',
        queryParameters: patternId == null ? null : {'patternId': patternId},
      );
      final data = res.data;
      final list = List<Map<String, dynamic>>.from(data['result']['content']);

      for (final m in list) {
        if (m['stockId'] == null && m['stock'] is Map && (m['stock']['id'] is num)) {
          m['stockId'] = (m['stock']['id'] as num).toInt();
        }
      }
      return list;
    } catch (e) {
      throw Exception('백테스트 목록 조회 실패: $e');
    }
  }


  static Future<Map<String, dynamic>> fetchBacktestResult(
      int backtestId, {
        int? stockId,
      }) async {
    try {
      final res = await _dio.get('/backtests/results/$backtestId');
      final map = Map<String, dynamic>.from(res.data['result']);

      if (map['stockId'] == null && map['stock'] is Map && (map['stock']['id'] is num)) {
        map['stockId'] = (map['stock']['id'] as num).toInt();
      }
      map['stockId'] ??= stockId;

      return map;
    } catch (e) {
      throw Exception('백테스트 상세 조회 실패: $e');
    }
  }

  static Future<Map<String, dynamic>> run({
    required int patternId,
    required int stockId,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    try {
      final response = await _dio.post(
        '/backtests',
        queryParameters: {
          'patternId': patternId,
          'stockId': stockId,
        },
        data: {
          'startDate': startDate.toIso8601String().split('T').first,
          'endDate': endDate.toIso8601String().split('T').first,
        },
      );

      if (response.statusCode == 200) {
        return Map<String, dynamic>.from(response.data);
      } else {
        throw Exception('백테스트 실패: 상태코드 ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('백테스트 실행 오류: $e');
    }
  }
}
