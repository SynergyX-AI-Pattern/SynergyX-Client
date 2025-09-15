// lib/data/watchlist_api.dart
import 'package:dio/dio.dart';
import '../models/stock_brief.dart';
import 'package:stockapp/services/api_client.dart';

class InterestlistApi {
  final Dio _dio = ApiClient.dio;

  Future<List<StockBrief>> fetchWatchlist() async {
    final res = await _dio.get('/watchlist');

    if (res.statusCode == 200 && res.data is Map<String, dynamic>) {
      final map = res.data as Map<String, dynamic>;
      if (map['isSuccess'] == true && map['result'] is List) {
        final list = (map['result'] as List)
            .map((e) => StockBrief.fromJson(e as Map<String, dynamic>))
            .toList();
        return list;
      }
      throw Exception('API 실패: ${map['message'] ?? 'Unknown'}');
    }
    throw Exception('HTTP ${res.statusCode}');
  }
}
