import 'package:dio/dio.dart';
import 'package:stockapp/models/stock.dart';

final Dio dio = Dio();

Future<List<Stock>> fetchSearchedStocks(String keyword) async {
  try {
    final response = await dio.get(
      'http://52.79.115.136:8080/stocks/search',
      queryParameters: {'query': keyword}, // ✅ 파라미터 이름 정확히 맞춤
    );

    if (response.statusCode == 200 && response.data['isSuccess'] == true) {
      final List<dynamic> result = response.data['result'];
      return result.map((json) => Stock.fromJson(json)).toList();
    } else {
      throw Exception('API 오류: ${response.data['message']}');
    }
  } on DioException catch (e) {
    throw Exception('서버 요청 실패: ${e.message}');
  }
}
