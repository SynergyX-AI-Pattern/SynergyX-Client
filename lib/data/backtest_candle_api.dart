// backtest_candle_api.dart
import 'package:dio/dio.dart';
import 'package:interactive_chart/interactive_chart.dart';
import '../models/CandelChartModel.dart';
import 'package:stockapp/services/api_client.dart';

final Dio _dio = ApiClient.dio;

/// 백테스트 결과에 대한 캔들 데이터를 조회하기 위한 별도 API
/// 기존 캔들 API를 수정할 수 없는 경우 사용한다.

/// 백테스트 결과에 대한 캔들 데이터를 조회한다.
/// [margin]은 하이라이트 구간 앞뒤로 가져올 캔들 개수이며 기본값은 20이다.
Future<List<CandleData>> fetchBacktestCandles({
  required int backtestId,
  int margin = 20,
}) async {
  try {
    // API 명세에 따라 margin 파라미터만 전달한다.
    final response = await _dio.get(
      '/backtests/results/$backtestId/candles',
      queryParameters: {'margin': margin},
    );
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
