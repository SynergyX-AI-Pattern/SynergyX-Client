import 'package:dio/dio.dart';
import 'package:stockapp/models/stock_detail_model.dart';
import 'package:stockapp/services/api_client.dart';

class StockDetailApiService {
  // 공용 Dio 인스턴스를 사용해 중복 생성을 방지한다.
  final Dio _dio = ApiClient.dio;
  Future<StockDetailResponse> fetchStockDetail(String stockId) async {
    try {
      final response = await _dio.get(
        '/stocks/$stockId/detail',
        options: Options(
          validateStatus: (status) => status != null && status < 600,
        ),
      );

      print('📡 StockDetail 응답: ${response.data}');

      if (response.statusCode == 200) {
        return StockDetailResponse.fromJson({'result': response.data['result']});
      } else {
        // 서버에서 에러 메시지를 내려주는 경우를 대비해 추가
        final errorMsg = response.data['message'] ?? '서버 오류';
        throw Exception('서버 오류: ${response.statusCode} - $errorMsg');
      }
    } on DioException catch (e) {
      print('❌ 요청 실패: ${e.message}');
      throw Exception('API 요청 실패: ${e.message}');
    }
  }
}
