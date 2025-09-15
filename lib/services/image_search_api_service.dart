import 'dart:io';
import 'package:dio/dio.dart';
import 'package:http_parser/http_parser.dart';
import 'package:mime/mime.dart';
import '../models/image_search_result.dart';
import 'api_client.dart';

class ImageSearchApiService {
  final Dio _dio;

  ImageSearchApiService({Dio? dio}) : _dio = dio ?? ApiClient.dio;


  Future<ImageSearchResult> searchStockByImage({
    required File imageFile,
    String? bearerToken, // TODO: access token
    CancelToken? cancelToken,
  }) async {
    final filename = imageFile.path.split('/').last;

    final mimeType = lookupMimeType(imageFile.path) ?? 'image/jpeg';
    final typeSplit = mimeType.split('/');

    print('[UPLOAD] filename=$filename, mimeType=$mimeType, path=${imageFile.path}');

    final formData = FormData.fromMap({
      'image': await MultipartFile.fromFile(
        imageFile.path,
        filename: filename,
        contentType: MediaType(typeSplit[0], typeSplit[1]),
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
        },
        // 4xx도 throw하지 않음 → UI에서 code/isSuccess로 분기
        validateStatus: (s) => s != null && s < 500,
      ),
      cancelToken: cancelToken,
    );

    if (res.data == null) throw Exception('서버 응답이 비어있습니다.');
    return ImageSearchResult.fromJson(res.data!);
  }
}
