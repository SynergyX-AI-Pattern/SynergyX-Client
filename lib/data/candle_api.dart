import 'package:dio/dio.dart';
import 'package:interactive_chart/interactive_chart.dart';
import '../models/CandelChartModel.dart';

import 'package:stockapp/services/api_client.dart';

// ApiClient의 공용 Dio 인스턴스를 사용해 요청을 보낸다.
final Dio _dio = ApiClient.dio;

Future<List<CandleData>> fetchCandles({
  required String stockId,
  required String interval,
}) async {
  try {
    // baseUrl을 활용해 상대 경로와 쿼리 파라미터만 전달한다.
    final response = await _dio.get(
      '/stocks/stocks/$stockId/candles',
      queryParameters: {'interval': interval},
    );

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
