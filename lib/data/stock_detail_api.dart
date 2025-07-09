import 'package:dio/dio.dart';
import 'package:stockapp/data/dio_client.dart';
import 'package:stockapp/models/stock_detail_model.dart';

class StockDetailApiService {
  final Dio _dio = dio;

  Future<StockDetailResponse> fetchStockDetail(String stockId) async {
    try {
      final response = await _dio.get('/$stockId/detail');

      print('📡 StockDetail 응답: ${response.data}');

      if (response.statusCode == 200) {
        return StockDetailResponse.fromJson({'result': response.data['result']});
      } else {
        throw Exception('서버 오류: ${response.statusCode}');
      }
    } on DioException catch (e) {
      print('❌ 요청 실패: ${e.message}');
      throw Exception('API 요청 실패: ${e.message}');
    }
  }
}
