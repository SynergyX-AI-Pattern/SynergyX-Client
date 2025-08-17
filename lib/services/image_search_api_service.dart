import 'dart:io';
import 'package:dio/dio.dart';
import 'package:http_parser/http_parser.dart';
import '../models/image_search_result.dart';

class ImageSearchApiService {
  final Dio _dio;

  ImageSearchApiService({Dio? dio})
    : _dio =
          dio ??
          Dio(
            BaseOptions(
              baseUrl: const String.fromEnvironment(
                'API_BASE_URL',
                defaultValue: 'http://pattern-catcher.net:8080',
              ),
              connectTimeout: const Duration(seconds: 10),
              receiveTimeout: const Duration(seconds: 20),
            ),
          ) {
    // 생성자 body에서 인터셉터 추가
    _dio.interceptors.add(
      LogInterceptor(
        request: true,
        requestHeader: true,
        requestBody: true,
        responseHeader: false,
        responseBody: true,
        error: true,
      ),
    );
  }

  Future<ImageSearchResult> searchStockByImage({
    required File imageFile,
    String? bearerToken, // TODO: access token
    CancelToken? cancelToken,
  }) async {
    final filename = imageFile.path.split('/').last;

    final formData = FormData.fromMap({
      'image': await MultipartFile.fromFile(
        imageFile.path,
        filename: filename,
        contentType: MediaType('image', 'jpeg'),
      ),
    });

    final res = await _dio.post<Map<String, dynamic>>(
      '/stocks/search/image',
      data: formData,
      options: Options(
        headers: {
          'accept': '*/*',
          if (bearerToken != null && bearerToken.isNotEmpty)
            'Authorization': 'Bearer $bearerToken',
          // Content-Type 생략 (multipart boundary를 Dio가 자동으로 붙임)
        },
      ),
      cancelToken: cancelToken,
    );

    if (res.data == null) {
      throw Exception('서버 응답이 비어있습니다.');
    }
    return ImageSearchResult.fromJson(res.data!);
  }
}
