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
  )..interceptors.add(LogInterceptor(requestBody: true, responseBody: true)
  );

  // 패턴 목록 조회 (GET)
  static Future<List<Pattern>> getPatterns() async {
    final res = await _dio.get('/patterns');
    print('패턴 목록 응답: ${res.data}');

    if (res.data == null || res.data is! Map) {
      throw Exception("패턴 응답이 null이거나 올바른 Map이 아님: ${res.data}");
    }

    final map = res.data as Map<String, dynamic>;
    final dataRaw = map['result'];

    if (dataRaw == null || dataRaw is! List) {
      return []; // 패턴이 없을 경우
    }

    return dataRaw.map((json) => Pattern.fromJson(json)).toList();
  }

  static Future<Pattern> getPatternDetail(int id) async {         // ✅ int
    final res = await _dio.get('/patterns/$id');
    return Pattern.fromJson(res.data);
  }

  static Future<void> createPattern(PatternRequest request) async {
    await _dio.post('/patterns', data: request.toJson());
  }

  static Future<void> updatePattern(int id, PatternRequest request) async { // ✅ int
    await _dio.patch('/patterns/$id', data: request.toJson());
  }

  static Future<void> deletePattern(int id) async {                // ✅ int
    await _dio.delete('/patterns/$id');
  }

}
