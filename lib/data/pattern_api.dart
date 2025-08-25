import 'package:dio/dio.dart';
import 'package:stockapp/models/pattern.dart';
import 'package:stockapp/models/pattern_request.dart';
export 'package:stockapp/models/pattern_request.dart';

class PatternApi {
  static final Dio _dio = Dio(
    BaseOptions(
      baseUrl: 'http://52.79.115.136:8080',
      headers: {'Content-Type': 'application/json'},
      connectTimeout: Duration(seconds: 10),
      receiveTimeout: Duration(seconds: 10),
    ),
  )..interceptors.add(LogInterceptor(requestBody: true, responseBody: true));

  // 패턴 목록 조회 (GET)
  static Future<List<Pattern>> getPatterns() async {
    final res = await _dio.get('/patterns');
    if (res.data is! Map) {
      throw Exception('패턴 목록 응답이 Map이 아님: ${res.data}');
    }
    final map = res.data as Map<String, dynamic>;
    final dataRaw = map['result'];
    if (dataRaw is! List) {
      return [];
    }
    return dataRaw.map<Pattern>((e) => Pattern.fromJson(e as Map<String, dynamic>)).toList();
  }

  // 패턴 상세 조회 (GET /patterns/{id} -> 래퍼의 result 언래핑)
  static Future<PatternDetail> getPatternDetail(int patternId) async {
    final res = await _dio.get('/patterns/$patternId');
    if (res.data is! Map) {
      throw Exception('패턴 상세 응답이 Map이 아님: ${res.data}');
    }
    final map = res.data as Map<String, dynamic>;
    final result = map['result'];
    if (result == null || result is! Map) {
      throw Exception('패턴 상세 result가 비었거나 형식이 아님: $result');
    }
    return PatternDetail.fromJson(result as Map<String, dynamic>);
  }

  // 패턴 생성
  static Future<void> createPattern(PatternRequest request) async {
    await _dio.post('/patterns', data: request.toJson());
  }

  // 패턴 수정 (PATCH /patterns/{id})
  static Future<void> updatePattern(int patternId, PatternRequest request) async {
    await _dio.patch('/patterns/$patternId', data: request.toJson());
  }

  // 패턴 삭제 (DELETE /patterns/{id})
  static Future<void> deletePattern(int patternId) async {
    await _dio.delete('/patterns/$patternId');
  }

}
