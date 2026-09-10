import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../models/business_app_model.dart';

class BusinessAppProvider with ChangeNotifier {
  List<BusinessAppModel> _apps = [];
  int _totalElements = 0;
  bool _isloading = false;

  List<BusinessAppModel> get apps => _apps;

  int get totalElements => _totalElements;

  bool get isLoading => _isloading;

  Future<void> fetchBusinessApps() async {
    _isloading = true;
    notifyListeners();
    try {
      final jsonResponse = await AuthService.fetchBusinessApps();
      final result = BusinessAppListResponse.fromJson(jsonResponse);
      _apps = result.apps;
      _totalElements = result.totalElements;
    } catch (e) {
      debugPrint('Error fetching business apps: $e');
    } finally {
      _isloading = false;
      notifyListeners();
    }
  }
}
