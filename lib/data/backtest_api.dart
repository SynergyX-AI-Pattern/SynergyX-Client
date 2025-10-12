// backtest_api.dart
import 'package:dio/dio.dart';
export 'package:stockapp/models/backtest_result.dart';
import 'package:stockapp/services/api_client.dart';
import 'package:stockapp/services/stock_image_resolver.dart';

class BacktestService {
  static final Dio _dio = ApiClient.dio;


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
      final list = await _fetchBacktestSummaries(patternId: patternId);

      if (list.isEmpty && backtestId != null) {
        final detail = await fetchBacktestResult(backtestId);
        return [await _summaryFromDetail(detail, backtestId)];
      }

      if (backtestId != null) {
        final targetIndex = list.indexWhere((item) {
          final id = item['backtestId'];
          if (id == null) return false;
          if (id is num) {
            return id.toInt() == backtestId;
          }
          return id.toString() == backtestId.toString();
        });
        if (targetIndex > 0) {
          final selected = list.removeAt(targetIndex);
          list.insert(0, selected);
        } else if (targetIndex == -1) {
          final detail = await fetchBacktestResult(backtestId);
          list.insert(0, await _summaryFromDetail(detail, backtestId));
        }
      }

      return list;
    } catch (e) {
      throw Exception('백테스트 목록 조회 실패: $e');
    }
  }

  static Future<List<Map<String, dynamic>>> _fetchBacktestSummaries({
    int? patternId,
  }) async {
    final res = await _dio.get(
      '/backtests/results',
      queryParameters: patternId == null ? null : {'patternId': patternId},
    );
    final data = res.data;
    final container =
    (data is Map) ? (data['result'] ?? data['data'] ?? data) : null;
    final listRaw =
        (container is Map ? container['content'] : null) as List? ?? const [];
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

      // 백엔드 응답에 이미지가 검색 API로 보완한다.
      await _fillStockImage(m);
    }

    return list;
  }

  /// 백테스트 상세 응답을 목록 아이템 형식으로 변환한다.
  static Future<Map<String, dynamic>> _summaryFromDetail(
      Map<String, dynamic> detail,
      int backtestId,
      ) async {
    final summary = <String, dynamic>{
      'backtestId': detail['backtestId'] ?? backtestId,
      'executedAt': detail['executedAt'],
      'matchedCount': detail['matchedCount'],
      'stockImage': detail['stockImage'],
      'stockName': detail['stockName'],
      'stockId':
      (detail['stockId'] is num)
          ? (detail['stockId'] as num).toInt()
          : detail['stockId'],
      'symbol': detail['symbol'],
      'startDate': detail['startDate'],
      'averageReturn': detail['averageReturn'],
      'winRate': detail['winRate'],
      'maxReturn': detail['maxReturn'],
      'maxReturnDate': detail['maxReturnDate'],
    };

    await _fillStockImage(summary);
    return summary;
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

      if (map['stockId'] == null &&
          map['stock'] is Map &&
          (map['stock']['id'] is num)) {
        map['stockId'] = (map['stock']['id'] as num).toInt();
      }
      map['stockId'] ??= stockId;
      if (map['stockName'] == null &&
          map['stock'] is Map &&
          map['stock']['name'] != null) {
        map['stockName'] = map['stock']['name'].toString();
      }
      if (map['stockImage'] == null &&
          map['stock'] is Map &&
          map['stock']['imageUrl'] != null) {
        map['stockImage'] = map['stock']['imageUrl'].toString();
      }

      await _fillStockImage(map);

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
        queryParameters: {'patternId': patternId, 'stockId': stockId},
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

Future<void> _fillStockImage(Map<String, dynamic> map) async {
  final current = map['stockImage']?.toString() ?? '';
  if (current.trim().isNotEmpty) {
    return;
  }

  final stock = map['stock'];
  final dynamic rawId = map['stockId'] ?? (stock is Map ? stock['id'] : null);
  final id = _parseId(rawId);
  final name = (map['stockName'] ?? (stock is Map ? stock['name'] : null))
      ?.toString()
      .trim() ??
      '';
  if (name.isEmpty) {
    return;
  }

  final resolved = await StockImageResolver.fetchImageUrl(
    stockId: id,
    stockName: name,
  );
  if (resolved.trim().isEmpty) {
    return;
  }

  // 검색 결과가 존재하면 바로 주입한다.
  map['stockImage'] = resolved;
}

/// 숫자나 문자열로 내려오는 종목 ID를 안전하게 파싱한다.
int? _parseId(dynamic value) {
  if (value == null) {
    return null;
  }
  if (value is num) {
    return value.toInt();
  }
  return int.tryParse(value.toString());
}