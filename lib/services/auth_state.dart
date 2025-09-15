import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../models/auth_response.dart';

class AuthState {
  static String? accessToken;
  static String? username;
  static String? email;
  static bool? isNewUser;

  static const _tokenKey = 'accessToken';
  static const _usernameKey = 'username';
  static const _emailKey = 'email';
  static const _isNewUserKey = 'isNewUser';

  // 민감한 토큰은 보안 저장소에 저장한다.
  static const _secure = FlutterSecureStorage();

  static Future<void> updateFromLogin(
      LoginResponse res,
      String userEmail,
      ) async {
    accessToken = res.accessToken;
    username = res.username;
    isNewUser = res.isNewUser;
    email = userEmail;
    await _saveToPrefs();
  }

  static Future<void> clear() async {
    accessToken = null;
    username = null;
    email = null;
    isNewUser = null;
    await _clearPrefs();
  }

  static Future<void> loadFromPrefs() async {
    accessToken = await _secure.read(key: _tokenKey);
    username   = await _secure.read(key: _usernameKey);
    email      = await _secure.read(key: _emailKey);
    final b    = await _secure.read(key: _isNewUserKey);
    isNewUser  = (b == '1' || b == 'true');
  }

  static Future<void> _saveToPrefs() async {
    (accessToken != null)
        ? await _secure.write(key: _tokenKey, value: accessToken!)
           : await _secure.delete(key: _tokenKey);
        (username != null)
            ? await _secure.write(key: _usernameKey, value: username!)
            : await _secure.delete(key: _usernameKey);
        (email != null)
            ? await _secure.write(key: _emailKey, value: email!)
            : await _secure.delete(key: _emailKey);
        (isNewUser != null)
            ? await _secure.write(key: _isNewUserKey, value: isNewUser! ? '1' : '0')
            : await _secure.delete(key: _isNewUserKey);
      }

  static Future<void> _clearPrefs() async {
        await _secure.delete(key: _tokenKey);
        await _secure.delete(key: _usernameKey);
        await _secure.delete(key: _emailKey);
        await _secure.delete(key: _isNewUserKey);
      }
}