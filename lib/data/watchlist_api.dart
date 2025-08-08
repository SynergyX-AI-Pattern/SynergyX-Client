import 'package:dio/dio.dart';
import 'package:stockapp/models/StockItemModel.dart';

/// 관심 종목 관련 API를 호출하는 서비스
class WatchlistApiService {
  final Dio _dio = Dio(
    BaseOptions(baseUrl: 'http://52.79.115.136:8080'),
  );

  /// 주어진 종목을 관심 목록에 등록
  Future<void> addToWatchlist(String stockId) async {
    try {
      final response = await _dio.post('/watchlist/$stockId');
      print('✅ 관심종목 등록 성공: ${response.statusCode} ${response.data}');
    } catch (e) {
      print('❌ 관심종목 등록 실패: $e');
      rethrow;
    }
  }

  /// 관심 목록에서 종목 제거
  Future<void> removeFromWatchlist(String stockId) async {
    try {
      final response = await _dio.delete('/watchlist/$stockId');
      print('✅ 관심종목 해제 성공: ${response.statusCode} ${response.data}');
    } catch (e) {
      print('❌ 관심종목 해제 실패: $e');
      rethrow;
    }
  }

  /// 관심 목록에 등록된 종목 목록 조회
  Future<List<StockItem>> fetchWatchlist() async {
    try {
      final response = await _dio.get('/watchlist');
      final List<dynamic> result = response.data['result'];
      return result.map((e) => StockItem.fromJson(e)).toList();
    } catch (e) {
      throw Exception('관심종목 불러오기 실패: $e');
    }
  }
}