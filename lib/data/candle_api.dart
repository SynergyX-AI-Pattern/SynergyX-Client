import 'package:dio/dio.dart';
import 'package:interactive_chart/interactive_chart.dart';
import '../models/CandelChartModel.dart';

import 'package:stockapp/services/api_client.dart';

final Dio _dio = ApiClient.dio;

Future<List<CandleData>> fetchCandles({
  required String stockId,
  required String interval,
}) async {
  final url =
      'http://52.79.115.136:8080/stocks/stocks/$stockId/candles?interval=$interval';

  try {
    final response = await _dio.get(url);

    if (response.statusCode == 200) {
      final data = response.data;
      final List result = data['result'];
      return result
          .map((e) => CandleApiResponse.fromJson(e).toCandleData())
          .toList();
    } else {
      throw Exception("캔들 데이터 불러오기 실패: ${response.statusCode}");
    }
  } catch (e) {
    print("❌ Dio 요청 에러: $e");
    throw Exception("네트워크 오류 또는 서버 오류 발생");
  }
}
