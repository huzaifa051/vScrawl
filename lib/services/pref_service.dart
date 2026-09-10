import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class PrefService {
  PrefService._();

  static const String _keyISLoggedIn = 'isLogin';
  static const String _keyUserEmail = 'userEmail';
  static const String _keyUserData = 'userData';

  static Future<void> saveLoginSession({
    required String email,
    required Map<String, dynamic> userData,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyISLoggedIn, true);
    await prefs.setString(_keyUserEmail, email);
    await prefs.setString(_keyUserData, jsonEncode(userData));
  }

  static Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyISLoggedIn) ?? false;
  }

  static Future<String?> getUserEmail() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyUserEmail);
  }

  static Future<Map<String, dynamic>?> getUserData() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_keyUserData);
    if (jsonString == null) return null;
    return jsonDecode(jsonString) as Map<String, dynamic>;
  }

  static Future<void> clearLoginSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyISLoggedIn, false);
    await prefs.remove(_keyUserEmail);
    await prefs.remove(_keyUserData);
  }
}
