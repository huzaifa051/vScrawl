import 'package:flutter/material.dart';
import '../services/auth_service.dart';

class OrganizationStatsProvider with ChangeNotifier {
  int _templatesCount = 0;
  int _usersCount = 0;
  int _businessAppsCount = 0;
  bool _isLoading = false;

  int get templatesCount => _templatesCount;

  int get usersCount => _usersCount;

  int get businessAppsCount => _businessAppsCount;

  bool get isLoading => _isLoading;

  Future<void> fetchOrganizationStats() async {
    _isLoading = true;
    notifyListeners();
    try {
      final json = await AuthService.fetchOrganizationStats();
      _templatesCount = json['templatesCount'] ?? 0;
      _usersCount = json['orgUsersCount'] ?? 0;
      _businessAppsCount = json['businessAppsCount'] ?? 0;
    } catch (e) {
      debugPrint('Error fetching organization stats: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
