class ImageSearchResult {
  final bool isSuccess;
  final String? code;
  final String? message;
  final ImageSearchData? result;

  const ImageSearchResult({
    required this.isSuccess,
    this.code,
    this.message,
    this.result,
  });

  factory ImageSearchResult.fromJson(Map<String, dynamic> json) {
    return ImageSearchResult(
      isSuccess: json['isSuccess'] == true,
      code: json['code'] as String?,
      message: json['message'] as String?,
      result: json['result'] != null
          ? ImageSearchData.fromJson(json['result'] as Map<String, dynamic>)
          : null,
    );
  }
}

class ImageSearchData {
  final int? id; // 종목 아이디
  final String? name; // 종목 이름
  final String? imageUrl; // 종목 이미지
  final String? status; // 종목 상태

  const ImageSearchData({
    this.id,
    this.name,
    this.imageUrl,
    this.status,
  });

  factory ImageSearchData.fromJson(Map<String, dynamic> json) {
    return ImageSearchData(
      id: json['id'] is int
          ? json['id'] as int
          : int.tryParse('${json['id']}'),
      name: json['name'] as String?,
      imageUrl: json['imageUrl'] as String?,
      status: json['status'] as String?,
    );
  }
}
