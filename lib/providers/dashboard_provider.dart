import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/auth_service.dart';
import '../models/dashboard_model.dart';

class DashboardProvider with ChangeNotifier {
  DashboardModel? _dashboardData;
  bool _isLoading = false;

  DashboardModel? get dashboardData => _dashboardData;

  bool get isLoading => _isLoading;

  Future<void> loadDashboardFromCache() async {
    final prefs = await SharedPreferences.getInstance();
    final cached = prefs.getString('cached_dashboard_data');
    if (cached != null) {
      try {
        _dashboardData = DashboardModel.fromJson(jsonDecode(cached));
        notifyListeners();
      } catch (e) {
        debugPrint('Error parsing cached dashboard data: $e');
      }
    }
  }

  Future<void> fetchDashboardData() async {
    if (_dashboardData == null) {
      _isLoading = true;
      notifyListeners();
    }

    try {
      final jsonResponse = await AuthService.fetchDashboardData();
      final freshData = DashboardModel.fromJson(jsonResponse);

      _dashboardData = freshData;

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(
        'cached_dashboard_data',
        jsonEncode(freshData.toJson()),
      );
    } catch (e) {
      debugPrint('Error fetching dashboard stats: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> clearDashboardData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('cached_dashboard_data');
    _dashboardData = null;
    notifyListeners();
  }
}
