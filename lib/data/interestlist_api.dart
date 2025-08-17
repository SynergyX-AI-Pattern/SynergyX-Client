// lib/data/watchlist_api.dart
import 'package:dio/dio.dart';
import '../models/stock_brief.dart';

class InterestlistApi {
  final Dio _dio = Dio(
    BaseOptions(
      baseUrl: 'http://pattern-catcher.net:8080',
      connectTimeout: const Duration(seconds: 8),
      receiveTimeout: const Duration(seconds: 8),
      headers: {'Content-Type': 'application/json'},
    ),
  );

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
