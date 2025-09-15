// backtest_candle_api.dart
import 'package:dio/dio.dart';
import 'package:interactive_chart/interactive_chart.dart';
import '../models/CandelChartModel.dart';

import 'package:stockapp/services/api_client.dart';

final Dio _dio = ApiClient.dio;

Future<List<CandleData>> fetchBacktestCandles({
  required int backtestId,
  required String stockId,
  String interval = '1D',
  String? startDate,
  String? endDate,
}) async {
  // 백테스트 차트 구간을 지정하기 위한 쿼리 파라미터 구성
  final query = {
    'stockId': stockId,
    'interval': interval,
    if (startDate != null && startDate.isNotEmpty) 'startDate': startDate,
    if (endDate != null && endDate.isNotEmpty) 'endDate': endDate,
  };
  final params = query.entries.map((e) => '${e.key}=${Uri.encodeComponent(e.value)}').join('&');
  final url = 'http://52.79.115.136:8080/backtests/results/$backtestId/candles?$params';

  try {
    final response = await _dio.get(url);

    if (response.statusCode == 200) {
      final data = response.data;
      final List result = (data['result'] as List? ?? const []);
      return result
          .map((e) => CandleApiResponse.fromJson(e).toCandleData())
          .toList();
    } else {
      throw Exception("백테스트 캔들 데이터 불러오기 실패: ${response.statusCode}");
    }
  } catch (e) {
    // 디버깅 편의를 위해 에러 출력
    // ignore: avoid_print
    print("❌ Dio 요청 에러: $e");
    throw Exception("네트워크 오류 또는 서버 오류 발생");
  }
}
