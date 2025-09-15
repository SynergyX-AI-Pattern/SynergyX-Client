/// 로그인 후 발급된 토큰과 사용자 정보를 보관하는 클래스
/// 앱 전역에서 접근하기 쉬운 정적 필드와 로컬 저장소를 사용합니다.
import 'package:shared_preferences/shared_preferences.dart';
import '../models/auth_response.dart';

class AuthState {
  /// JWT 액세스 토큰
  static String? accessToken;

  /// 로그인한 사용자의 이름
  static String? username;

  /// 로그인한 사용자의 이메일
  static String? email;

  /// 신규 사용자 여부
  static bool? isNewUser;

  static const _tokenKey = 'accessToken';
  static const _usernameKey = 'username';
  static const _emailKey = 'email';
  static const _isNewUserKey = 'isNewUser';

  /// 로그인 응답으로부터 상태를 갱신합니다.
  static Future<void> updateFromLogin(
      LoginResponse res,
      String userEmail,
      ) async {
    accessToken = res.accessToken;
    username = res.username;
    isNewUser = res.isNewUser;
    email = userEmail;
    // 로그인 성공 시 정보를 디스크에도 저장해 자동로그인을 지원
    await _saveToPrefs();
  }

  /// 저장된 인증 정보를 모두 삭제합니다.
  static Future<void> clear() async {
    accessToken = null;
    username = null;
    email = null;
    isNewUser = null;
    await _clearPrefs();
  }

  /// 앱 시작 시 저장된 인증 정보를 불러옵니다.
  static Future<void> loadFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    accessToken = prefs.getString(_tokenKey);
    username = prefs.getString(_usernameKey);
    email = prefs.getString(_emailKey);
    isNewUser = prefs.getBool(_isNewUserKey);
  }

  /// 현재 메모리에 저장된 정보를 디스크에 기록합니다.
  static Future<void> _saveToPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    if (accessToken != null) {
      await prefs.setString(_tokenKey, accessToken!);
    }
    if (username != null) {
      await prefs.setString(_usernameKey, username!);
    }
    if (email != null) {
      await prefs.setString(_emailKey, email!);
    }
    if (isNewUser != null) {
      await prefs.setBool(_isNewUserKey, isNewUser!);
    }
  }

  /// 로컬 저장소에 보관된 정보를 모두 삭제합니다.
  static Future<void> _clearPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
    await prefs.remove(_usernameKey);
    await prefs.remove(_emailKey);
    await prefs.remove(_isNewUserKey);
  }
}