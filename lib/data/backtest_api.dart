// backtest_api.dart
import 'package:dio/dio.dart';
export 'package:stockapp/models/backtest_result.dart';
import 'package:stockapp/services/api_client.dart';

class BacktestService {
  static final Dio _dio = ApiClient.dio;

  /// periodUnit → interval 매핑 유틸
  /// 서버가 "HOUR"/"DAY" 등을 주면 캔들 조회 interval로 변환해 사용할 수 있음.
  static String intervalFromPeriodUnit(String? periodUnit) {
    switch ((periodUnit ?? '').toUpperCase()) {
      case 'MINUTE':
      case 'MIN':
        return '1m';
      case 'HOUR':
      case 'H':
        return '1H';
      case 'DAY':
      case 'D':
      default:
        return '1D';
    }
  }

  static Future<List<Map<String, dynamic>>> fetchBacktestList({
    int? patternId,
    int? backtestId,
  }) async {
    try {
      if (backtestId != null) {
        final detail = await fetchBacktestResult(backtestId);
        final map = <String, dynamic>{
          'backtestId': detail['backtestId'] ?? backtestId,
          'executedAt': detail['executedAt'],
          'matchedCount': detail['matchedCount'],
          'stockImage': detail['stockImage'],
          'stockName': detail['stockName'],
          'stockId': (detail['stockId'] is num)
              ? (detail['stockId'] as num).toInt()
              : detail['stockId'],
          'symbol': detail['symbol'],
          'startDate': detail['startDate'],
          'averageReturn': detail['averageReturn'],
          'winRate': detail['winRate'],
          'maxReturn': detail['maxReturn'],
          'maxReturnDate': detail['maxReturnDate'],
        };
        return [map];
      }

      final res = await _dio.get(
        '/backtests/results',
        queryParameters: patternId == null ? null : {'patternId': patternId},
      );
      final data = res.data;
      final listRaw = (data['data'] ?? const {})['content'] as List? ?? const [];
      final list = List<Map<String, dynamic>>.from(listRaw);

      for (final m in list) {
        final stock = m['stock'];
        if (stock is Map) {
          if (m['stockId'] == null && stock['id'] is num) {
            m['stockId'] = (stock['id'] as num).toInt();
          }
          if (m['stockName'] == null && stock['name'] != null) {
            m['stockName'] = stock['name'].toString();
          }
          if (m['stockImage'] == null && stock['imageUrl'] != null) {
            m['stockImage'] = stock['imageUrl'].toString();
          }
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
      final res = await _dio.get(
        '/backtests/results/$backtestId',
        queryParameters: stockId == null ? null : {'stockId': stockId},
      );
      final map = Map<String, dynamic>.from(res.data['result']);

      if (map['stockId'] == null && map['stock'] is Map && (map['stock']['id'] is num)) {
        map['stockId'] = (map['stock']['id'] as num).toInt();
      }
      map['stockId'] ??= stockId;
      if (map['stockName'] == null && map['stock'] is Map && map['stock']['name'] != null) {
        map['stockName'] = map['stock']['name'].toString();
      }
      if (map['stockImage'] == null && map['stock'] is Map && map['stock']['imageUrl'] != null) {
        map['stockImage'] = map['stock']['imageUrl'].toString();
      }

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
