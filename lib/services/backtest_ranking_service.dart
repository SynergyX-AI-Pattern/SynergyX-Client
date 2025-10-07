import 'package:dio/dio.dart';

import 'package:stockapp/data/ranking_mock.dart';
import 'package:stockapp/models/backtest_ranking.dart';
import 'package:stockapp/services/api_client.dart';

class BacktestRankingService {
  BacktestRankingService({Dio? dio}) : _dio = dio ?? ApiClient.dio;
  final Dio _dio;

  Future<List<BacktestRanking>> fetchRankings({int limit = 100}) async {
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        '/backtests/rankings',
        queryParameters: {'limit': limit},
        options: Options(validateStatus: (status) => status != null && status < 500),
      );

      final data = response.data;
      if (data == null) {
        throw Exception('서버 응답이 비어있습니다.');
      }

      final result = data['result'];
      if (result is! List || result.isEmpty) {
        // 서버에서 데이터가 비어있는 경우에는 목데이터를 활용해 UI를 확인할 수 있도록 한다.
        return _provideMockData(limit);
      }

      return result
          .whereType<Map<String, dynamic>>()
          .map(BacktestRanking.fromJson)
          .toList();
    } catch (e) {
      // API가 준비되지 않았거나 호출에 실패한 경우에도 화면을 확인할 수 있도록 목데이터를 반환한다.
      return _provideMockData(limit);
    }
  }

  List<BacktestRanking> _provideMockData(int limit) {
    return mockBacktestRankings.take(limit).toList();
  }
}