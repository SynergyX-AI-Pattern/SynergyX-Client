import 'package:dio/dio.dart';
import 'package:stockapp/models/stock_detail_model.dart';

final Dio dio = Dio();

Future<StockDetailResponse> fetchStockDetail(String stockId) async {
  try {
    final String url = 'http://52.79.115.136:8080/stocks/$stockId/detail';
    final response = await dio.get(url);

    print('API 응답: ${response.data}');

    if (response.statusCode == 200) {
      final jsonData = response.data['result'];
      return StockDetailResponse.fromJson({'result': jsonData});
    } else {
      throw Exception('서버 오류: ${response.statusCode}');
    }
  } on DioException catch (e) {
    throw Exception('API 요청 실패: ${e.message}');
  }
}

