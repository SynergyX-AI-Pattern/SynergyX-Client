import 'package:dio/dio.dart';

class WatchlistApiService {
  final Dio _dio = Dio(
    BaseOptions(baseUrl: 'http://52.79.115.136:8080'),
  );

  /* 관심 종목 등록 */
  Future<void> addToWatchlist(String stockId) async {
    try {
      final response = await _dio.post('/watchlist/$stockId');
      print('✅ 관심종목 등록 성공: ${response.statusCode} ${response.data}');
    } catch (e) {
      print('❌ 관심종목 등록 실패: $e');
      rethrow;
    }
  }

  /* 관심 종목 삭제 */
  Future<void> removeFromWatchlist(String stockId) async {
    try {
      final response = await _dio.delete('/watchlist/$stockId');
      print('✅ 관심종목 해제 성공: ${response.statusCode} ${response.data}');
    } catch (e) {
      print('❌ 관심종목 해제 실패: $e');
      rethrow;
    }
  }
}
