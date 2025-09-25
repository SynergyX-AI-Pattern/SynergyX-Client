import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../models/auth_response.dart';

class AuthState {
  static String? accessToken;
  static String? refreshToken;
  static String? username;
  static String? email;
  static String? password; // 자동 재로그인을 위해 보안 저장소에만 저장되는 비밀번호
  static bool? isNewUser;

  static const _tokenKey = 'accessToken';
  static const _refreshTokenKey = 'refreshToken';
  static const _usernameKey = 'username';
  static const _emailKey = 'email';
  static const _passwordKey = 'password';
  static const _isNewUserKey = 'isNewUser';

  // 민감한 토큰은 보안 저장소에 저장한다.
  static const _secure = FlutterSecureStorage();

  /// 로그인 API 응답을 받아 메모리/로컬 상태를 갱신한다.
  static Future<void> updateFromLogin(
      LoginResponse res,
      String userEmail, {
        String? userPassword,
      }) async {
    accessToken = res.accessToken;
    refreshToken = res.refreshToken;
    username = res.username;
    isNewUser = res.isNewUser;
    email = userEmail;
    password = userPassword ?? password;
    await _saveToPrefs();
  }

  /// 토큰 갱신 API 호출 이후 최신 토큰을 반영한다.
  /// 토큰만 별도 갱신하는 경우에 사용한다.
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

  static Future<void> clear() async {
    accessToken = null;
    refreshToken = null;
    username = null;
    email = null;
    password = null;
    isNewUser = null;
    await _clearPrefs();
  }

  static Future<void> loadFromPrefs() async {
    accessToken = await _secure.read(key: _tokenKey);
    refreshToken = await _secure.read(key: _refreshTokenKey);
    username   = await _secure.read(key: _usernameKey);
    email      = await _secure.read(key: _emailKey);
    password   = await _secure.read(key: _passwordKey);
    final b    = await _secure.read(key: _isNewUserKey);
    isNewUser  = (b == '1' || b == 'true');
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

    if (password != null) {
      await _secure.write(key: _passwordKey, value: password!);
    } else {
      await _secure.delete(key: _passwordKey);
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
    await _secure.delete(key: _passwordKey);
    await _secure.delete(key: _isNewUserKey);
  }
}