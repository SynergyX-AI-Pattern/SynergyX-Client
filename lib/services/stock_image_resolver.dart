import 'package:dio/dio.dart';
import 'package:stockapp/models/backtest_result.dart';
import 'package:stockapp/services/api_client.dart';

class StockImageResolver {
  StockImageResolver._();

  static final Dio _dio = ApiClient.dio;

  static Future<String> fetchImageUrl({
    int? stockId,
    required String stockName,
  }) async {
    final query = stockName.trim();
    if (query.isEmpty) {
      return '';
    }

    try {
      final res = await _dio.get(
        '/stocks/search',
        queryParameters: {'query': query},
      );
      final data = res.data;
      final results = (data is Map) ? data['result'] : null;
      if (results is! List) {
        return '';
      }

      for (final item in results) {
        if (item is! Map) {
          continue;
        }
        final stockMap = Map<String, dynamic>.from(item as Map);
        final stock = StockResult.fromJson(stockMap);

        if (stock.imageUrl.isEmpty) {
          continue;
        }
        if (stockId != null && stock.id == stockId) {
          return stock.imageUrl;
        }
        if (stock.name == stockName || stockName.isEmpty) {
          return stock.imageUrl;
        }
      }
    } catch (_) {
      // 네트워크 오류가 나더라도 화면이 깨지지 않도록 빈 문자열을 반환한다.
      return '';
    }

    return '';
  }
}