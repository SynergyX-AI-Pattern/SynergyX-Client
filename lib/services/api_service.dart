import 'package:dio/dio.dart';
import 'package:logger/logger.dart';

final Logger _logger = Logger();

// API 응답에 대한 기본 모델 (필요에 따라 더 구체적인 모델 생성)
class ApiResponse<T> {
  final bool success;
  final T? data;
  final String? errorMessage;
  final int? statusCode;

  ApiResponse({
    required this.success,
    this.data,
    this.errorMessage,
    this.statusCode,
  });
}

class ApiService {
  // --- 중요: BASE_URL을 Swagger UI에서 확인한 서버 주소로 변경 ---
  // Swagger UI 주소가 http://52.79.115.136:8080/swagger-ui/index.html 이므로,
  // API의 기본 경로는 http://52.79.115.136:8080/ 일 가능성이 높습니다.
  // 실제 API 엔드포인트가 /api/v1/... 와 같이 시작한다면 그에 맞게 조정해야 합니다.
  final Dio _dio = Dio(BaseOptions(
    baseUrl: "http://52.79.115.136:8080", // <-- API 서버의 기본 URL
    connectTimeout: const Duration(seconds: 5), // 연결 타임아웃
    receiveTimeout: const Duration(seconds: 3), // 응답 타임아웃
  ));

  // 생성자에서 인터셉터 등을 설정할 수 있습니다.
  ApiService() {
    _dio.interceptors.add(LogInterceptor(
      requestBody: true, // 요청 본문 로깅
      responseBody: true, // 응답 본문 로깅
      error: true,
    ));

    // 필요시 인증 토큰 등을 위한 인터셉터 추가
    // _dio.interceptors.add(InterceptorsWrapper(
    //   onRequest: (options, handler) async {
    //     // 여기에 저장된 토큰을 가져와 헤더에 추가하는 로직
    //     // String? token = await getAuthToken(); // 예시 함수
    //     // if (token != null) {
    //     //   options.headers['Authorization'] = 'Bearer $token';
    //     // }
    //     return handler.next(options); // 요청 계속 진행
    //   },
    // ));
  }

  Future<List<dynamic>> getPatterns() async {
    final response = await _dio.get('/patterns');
    return response.data;
  }

  Future<void> createPattern(Map<String, dynamic> patternData) async {
    final response = await _dio.post('/patterns', data: patternData);
    _logger.i('패턴 생성 완료: ${response.data}');
  }

  Future<Map<String, dynamic>> getPatternDetail(String patternId) async {
    final response = await _dio.get('/patterns/$patternId');
    return response.data;
  }

  Future<void> updatePattern(String patternId,
      Map<String, dynamic> updatedData) async {
    final response = await _dio.patch(
        '/patterns/$patternId', data: updatedData);
    _logger.i('패턴 수정 완료: ${response.data}');
  }

  Future<void> deletePattern(String patternId) async {
    final response = await _dio.delete('/patterns/$patternId');
    _logger.e('패턴 삭제 완료: ${response.statusCode}');
  }
}
