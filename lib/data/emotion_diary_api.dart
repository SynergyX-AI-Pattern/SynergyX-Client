import 'package:dio/dio.dart';

class EmotionDiaryApi {
  final Dio _dio = Dio(
    BaseOptions(
      baseUrl: 'http://pattern-catcher.net:8080', // ✅ 실제 baseURL
      headers: {'Content-Type': 'application/json'},
    ),
  );

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
