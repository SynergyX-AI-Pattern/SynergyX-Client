import 'package:dio/dio.dart';
import 'package:stockapp/services/api_client.dart';

class EmotionDiaryApi {
  final Dio _dio = ApiClient.dio;

  /// 요청
  Future<Map<String, dynamic>> postDiary(String content) async {
    try {
      final response = await _dio.post('/diaries', data: {
        'content': content,
      });

      return response.data['result']; // ✅ 감정 분석 결과 리턴
    } catch (e) {
      print('❌ 요청 실패: $e');
      rethrow;
    }
  }

  /// 목록
  Future<List<Map<String, dynamic>>> fetchDiaries() async {
    try {
      final response = await _dio.get('/diaries');
      return List<Map<String, dynamic>>.from(response.data['result']);
    } catch (e) {
      print('❌ 일기 목록 불러오기 실패: $e');
      rethrow;
    }
  }
}
