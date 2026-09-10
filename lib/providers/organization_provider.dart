import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/auth_service.dart';
import '../models/organization_model.dart';

class OrganizationProvider  with ChangeNotifier {
  OrganizationModel? _organization;
  bool _isLoading = false;

  OrganizationModel? get organization => _organization;
  bool get isLoading => _isLoading;

  Future<void> loadOrganizationFromCache() async {
    final prefs = await SharedPreferences.getInstance();
    final cached = prefs.getString('cached_organization_data');
    if (cached != null) {
      try {
        _organization = OrganizationModel.fromJson(jsonDecode(cached));
        notifyListeners();
      } catch (e) {
        debugPrint ('Error parsing cached organization: $e');
      }
    }
  }

  Future<void> fetchOrganization() async {
    if (organization == null) {
      _isLoading = true;
      notifyListeners();
    }

    try {
      final jsonResponse = await AuthService.fetchOrganization();
      final fresh = OrganizationModel.fromJson(jsonResponse);
      _organization = fresh;

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('cached_organization_data', jsonEncode(fresh.toJson()));
    } catch (e) {
      debugPrint('Error fetching organization $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> clearOrganization() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('cached_organization_data');
    _organization = null;
    notifyListeners();
  }
}