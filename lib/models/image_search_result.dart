class ImageSearchResult {
  final bool isSuccess;
  final String? code;
  final String? message;
  final int? id; // 종목 아이디
  final String? name; // 종목 이름
  final String? imageUrl; // 종목 이미지

  const ImageSearchResult({
    required this.isSuccess,
    this.code,
    this.message,
    this.id,
    this.name,
    this.imageUrl,
  });

  factory ImageSearchResult.fromJson(Map<String, dynamic> json) {
    final result = (json['result'] as Map?) ?? {};
    return ImageSearchResult(
      isSuccess: json['isSuccess'] == true,
      code: json['code'] as String?,
      message: json['message'] as String?,
      id:
          result['id'] is int
              ? result['id'] as int
              : int.tryParse('${result['id']}'),
      name: result['name'] as String?,
      imageUrl: result['imageUrl'] as String?,
    );
  }
}
