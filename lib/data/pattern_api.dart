import 'package:dio/dio.dart';
import 'package:stockapp/models/pattern.dart';
import 'package:stockapp/models/pattern_request.dart';
export 'package:stockapp/models/pattern_request.dart';


class PatternApi {
  static final Dio _dio = Dio(
    BaseOptions(
      baseUrl: 'http://52.79.115.136:8080',
      headers: {'Content-Type': 'application/json'},
    ),
  );

  // 패턴 목록 조회 (GET)
  static Future<List<Pattern>> getPatterns() async {
    final res = await _dio.get('/patterns');
    return (res.data as List)
        .map((json) => Pattern.fromJson(json))
        .toList();
  }

  // 패턴 상세 조회 (GET)
  static Future<Pattern> getPatternDetail(String id) async {
    final res = await _dio.get('/patterns/$id');
    return Pattern.fromJson(res.data);
  }

  // 패턴 생성 (POST)
  static Future<void> createPattern(PatternRequest request) async {
    await _dio.post('/patterns', data: request.toJson());
  }

  // 패턴 수정 (PATCH)
  static Future<void> updatePattern(String id, PatternRequest request) async {
    await _dio.patch('/patterns/$id', data: request.toJson());
  }

  // 패턴 삭제 (DELETE)
  static Future<void> deletePattern(String id) async {
    await _dio.delete('/patterns/$id');
  }
}
