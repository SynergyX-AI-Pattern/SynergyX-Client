import 'package:shared_preferences/shared_preferences.dart';
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
    final prefs = await SharedPreferences.getInstance();
    accessToken = prefs.getString(_tokenKey);
    username = prefs.getString(_usernameKey);
    email = prefs.getString(_emailKey);
    isNewUser = prefs.getBool(_isNewUserKey);
  }

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

  static Future<void> _clearPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
    await prefs.remove(_usernameKey);
    await prefs.remove(_emailKey);
    await prefs.remove(_isNewUserKey);
  }
}