import 'package:dio/dio.dart';
import 'package:stockapp/data/dio_client.dart';
import 'package:stockapp/models/StockItemModel.dart';

class StockApiService {
  final Dio _dio = dio;

  Future<List<StockItem>> fetchTopStocks() async {
    try {
      final response = await _dio.get('/top20');
      final List<dynamic> result = response.data['result'];
      return result.map((e) => StockItem.fromJson(e)).toList();
    } catch (e) {
      throw Exception('Top 20 종목 불러오기 실패: $e');
    }
  }

  Future<List<StockItem>> fetchAiTopStocks() async {
    try {
      final response = await _dio.get('/ai-top20');
      final List<dynamic> result = response.data['result'];
      return result.map((e) => StockItem.fromJson(e)).toList();
    } catch (e) {
      throw Exception('AI Top 20 종목 불러오기 실패: $e');
    }
  }
}
