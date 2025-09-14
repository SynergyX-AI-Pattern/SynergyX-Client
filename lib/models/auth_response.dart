/// 인증 관련 공통 응답 모델들
/// API 명세에 맞춘 필드 구조를 정의합니다.

/// 기본 응답 모델
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
  final String? accessToken; // 발급된 JWT
  final int? expiresIn; // 토큰 만료 시간(초)
  final String? username; // 사용자 이름
  final bool? isNewUser; // 신규 사용자 여부

  const LoginResponse({
    required bool isSuccess,
    String? code,
    String? message,
    Map<String, dynamic>? result,
    this.accessToken,
    this.expiresIn,
    this.username,
    this.isNewUser,
  }) : super(
    isSuccess: isSuccess,
    code: code,
    message: message,
    result: result,
  );

  /// JSON으로부터 LoginResponse 인스턴스를 생성합니다.
  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    final result = (json['result'] as Map?) ?? {};
    final userInfo = (result['userInfo'] as Map?) ?? {};
    return LoginResponse(
      isSuccess: json['isSuccess'] == true,
      code: json['code'] as String?,
      message: json['message'] as String?,
      result: result.cast<String, dynamic>(),
      accessToken: result['accessToken'] as String?,
      expiresIn: result['expiresIn'] is int
          ? result['expiresIn'] as int
          : int.tryParse('${result['expiresIn']}'),
      username: userInfo['username'] as String?,
      isNewUser: userInfo['isNewUser'] == true,
    );
  }
}