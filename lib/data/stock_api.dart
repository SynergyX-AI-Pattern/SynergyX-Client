import 'package:dio/dio.dart';
import 'package:stockapp/models/stock.dart';
import 'package:stockapp/services/api_client.dart';

final Dio _dio = ApiClient.dio;

Future<List<Stock>> fetchSearchedStocks(String keyword) async {
  try {
    final response = await _dio.get(
      '/stocks/search',
      queryParameters: {'query': keyword},
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
