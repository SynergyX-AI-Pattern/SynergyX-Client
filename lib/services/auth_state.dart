import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../models/auth_response.dart';

class AuthState {
  static String? accessToken;
  static String? refreshToken;
  static String? username;
  static String? email;
  static bool? isNewUser;

  // 앱 실행 중 임시로만 보관되는 비밀번호 (secure storage에 저장 ❌)
  static String? _tempPassword;

  static const _tokenKey = 'accessToken';
  static const _refreshTokenKey = 'refreshToken';
  static const _usernameKey = 'username';
  static const _emailKey = 'email';
  static const _isNewUserKey = 'isNewUser';

  static const _secure = FlutterSecureStorage();

  /// 로그인 후 상태 갱신
  static Future<void> updateFromLogin(LoginResponse res, String userEmail) async {
    accessToken = res.accessToken;
    refreshToken = res.refreshToken;
    username = res.username;
    isNewUser = res.isNewUser;
    email = userEmail;
    await _saveToPrefs();
  }

  /// 토큰만 갱신 시 사용
  static Future<void> updateTokens({
    required String newAccessToken,
    String? newRefreshToken,
  }) async {
    accessToken = newAccessToken;
    if (newRefreshToken != null && newRefreshToken.isNotEmpty) {
      refreshToken = newRefreshToken;
    }
    await _saveToPrefs();
  }

  /// 앱 실행 중 임시 비밀번호 설정 (optional)
  static void setTempPassword(String? pw) => _tempPassword = pw;
  static void clearTempPassword() => _tempPassword = null;

  static Future<void> clear() async {
    accessToken = null;
    refreshToken = null;
    username = null;
    email = null;
    isNewUser = null;
    _tempPassword = null;
    await _clearPrefs();
  }

  static Future<void> loadFromPrefs() async {
    accessToken = await _secure.read(key: _tokenKey);
    refreshToken = await _secure.read(key: _refreshTokenKey);
    username = await _secure.read(key: _usernameKey);
    email = await _secure.read(key: _emailKey);
    final b = await _secure.read(key: _isNewUserKey);
    isNewUser = (b == '1' || b == 'true');
  }

  static Future<void> _saveToPrefs() async {
    if (accessToken != null) {
      await _secure.write(key: _tokenKey, value: accessToken!);
    } else {
      await _secure.delete(key: _tokenKey);
    }

    if (refreshToken != null) {
      await _secure.write(key: _refreshTokenKey, value: refreshToken!);
    } else {
      await _secure.delete(key: _refreshTokenKey);
    }

    if (username != null) {
      await _secure.write(key: _usernameKey, value: username!);
    } else {
      await _secure.delete(key: _usernameKey);
    }

    if (email != null) {
      await _secure.write(key: _emailKey, value: email!);
    } else {
      await _secure.delete(key: _emailKey);
    }

    if (isNewUser != null) {
      await _secure.write(
        key: _isNewUserKey,
        value: isNewUser! ? '1' : '0',
      );
    } else {
      await _secure.delete(key: _isNewUserKey);
    }
  }

  static Future<void> _clearPrefs() async {
    await _secure.delete(key: _tokenKey);
    await _secure.delete(key: _refreshTokenKey);
    await _secure.delete(key: _usernameKey);
    await _secure.delete(key: _emailKey);
    await _secure.delete(key: _isNewUserKey);
  }
}
