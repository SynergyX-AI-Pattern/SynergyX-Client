class SimpleResponse {
  final bool isSuccess; // 요청 성공 여부
  final String? code; // 응답 코드
  final String? message; // 서버 메시지
  final Map<String, dynamic>? result; // 응답에 포함된 추가 데이터

  const SimpleResponse({
    required this.isSuccess,
    this.code,
    this.message,
    this.result,
  });

  /// JSON으로부터 SimpleResponse 인스턴스를 생성합니다.
  factory SimpleResponse.fromJson(Map<String, dynamic> json) {
    return SimpleResponse(
      isSuccess: json['isSuccess'] == true,
      code: json['code'] as String?,
      message: json['message'] as String?,
      result: (json['result'] as Map?)?.cast<String, dynamic>(),
    );
  }
}

/// 로그인 시 반환되는 결과 모델
class LoginResponse extends SimpleResponse {
  final String? accessToken;
  final String? refreshToken;
  final int? expiresIn;
  final String? username;
  final bool? isNewUser;

  const LoginResponse({
    required bool isSuccess,
    String? code,
    String? message,
    Map<String, dynamic>? result,
    this.accessToken,
    this.refreshToken,
    this.expiresIn,
    this.username,
    this.isNewUser,
  }) : super(
    isSuccess: isSuccess,
    code: code,
    message: message,
    result: result,
  );

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    final result = (json['result'] as Map?) ?? {};
    final userInfo = (result['userInfo'] as Map?) ?? {};
    return LoginResponse(
      isSuccess: json['isSuccess'] == true,
      code: json['code'] as String?,
      message: json['message'] as String?,
      result: result.cast<String, dynamic>(),
      accessToken: result['accessToken'] as String?,
      refreshToken: result['refreshToken'] as String?,
      expiresIn: result['expiresIn'] is int
          ? result['expiresIn'] as int
          : int.tryParse('${result['expiresIn']}'),
      username: userInfo['username'] as String?,
      isNewUser: userInfo['isNewUser'] == true,
    );
  }
}