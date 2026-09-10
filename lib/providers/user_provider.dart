import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/auth_service.dart';
import '../models/user_model.dart';

class UserProvider with ChangeNotifier {
  UserModel? _user;
  bool _isLoading = false;
  Uint8List? _cachedProfileImageBytes;

  UserModel? get user => _user;

  bool get isLoading => _isLoading;

  Uint8List? get profileImageBytes => _cachedProfileImageBytes;

  Uint8List? _decodeImage(String? base64String) {
    if (base64String == null || base64String.isEmpty) return null;
    try {
      return base64Decode(base64String);
    } catch (e) {
      debugPrint('Failed to decode profile image: $e');
      return null;
    }
  }

  Future<void> loadUserFromCache() async {
    final prefs = await SharedPreferences.getInstance();
    final cached = prefs.getString('cached_user_profile');
    if (cached != null) {
      try {
        _user = UserModel.fromJson(jsonDecode(cached));
        _cachedProfileImageBytes = _decodeImage(_user?.profileImage);
        notifyListeners();
      } catch (e) {
        debugPrint('Error parsing cached user: $e');
      }
    }
  }

  Future<void> fetchUserProfile() async {
    if (_user == null) {
      _isLoading = true;
      notifyListeners();
    }
    try {
      final jsonResponse = await AuthService.fetchUserProfile();
      final freshUser = UserModel.fromJson(jsonResponse);
      _user = freshUser;
      _cachedProfileImageBytes = _decodeImage(freshUser.profileImage);

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(
        'cached_user_profile',
        jsonEncode(freshUser.toJson()),
      );
    } catch (e) {
      debugPrint('Error fetching user profile: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> clearUser() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('cached_user_profile');
    _user = null;
    _cachedProfileImageBytes = null;
    notifyListeners();
  }
}
