import 'package:dio/dio.dart';
import '../models/stock_brief.dart';

class RecentApi {
  final Dio _dio = Dio(
    BaseOptions(
      baseUrl: 'http://pattern-catcher.net:8080',
      connectTimeout: const Duration(seconds: 8),
      receiveTimeout: const Duration(seconds: 8),
      headers: {'Content-Type': 'application/json'},
    ),
  );

  Future<List<StockBrief>> fetchRecent() async {
    final res = await _dio.get('/stocks/recent');

    if (res.statusCode == 200 &&
        res.data is Map<String, dynamic> &&
        res.data['isSuccess'] == true &&
        res.data['result'] is List) {
      final list = (res.data['result'] as List)
          .map((e) => StockBrief.fromJson(e as Map<String, dynamic>))
          .toList();
      return list;
    }
    throw Exception('최근 목록 불러오기 실패: ${res.statusCode} ${res.data}');
  }
}
