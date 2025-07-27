import 'package:dio/dio.dart';
import 'package:stockapp/models/pattern.dart';

class ApiService {
  static final Dio _dio = Dio(BaseOptions(
    baseUrl: 'http://52.79.115.136:8080',
    headers: {'Content-Type': 'application/json'},
    connectTimeout: const Duration(seconds: 10),
    receiveTimeout: const Duration(seconds: 10),
  ));

  static Future<void> sendPatternToServer(PatternRequest pattern) async {
    try {
      final response = await _dio.post(
        '/patterns',
        data: pattern.toJson(),
      );

      if (response.statusCode != 200 && response.statusCode != 201) {
        throw Exception(
            '서버 응답 실패: 상태코드 ${response.statusCode}, 내용: ${response.data}');
      }
    } catch (e) {
      throw Exception('API 요청 중 오류 발생: $e');
    }
  }

  static Future<List<PatternRequest>> fetchPatternList() async {
    try {
      final response = await _dio.get('/patterns');
      if (response.statusCode == 200) {
        final data = response.data;
        if (data is List) {
          return data
              .map((json) => PatternRequest.fromJson(json))
              .toList();
        } else {
          throw Exception('서버 응답이 List 형식이 아님: ${data.runtimeType}');
        }
      } else {
        throw Exception('패턴 목록 조회 실패: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('서버에서 패턴 목록 불러오기 실패: $e');
    }
  }
}
