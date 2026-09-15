import 'package:flutter/material.dart';
import '../models/users_list_model.dart';
import '../services/auth_service.dart';

class UsersListProvider with ChangeNotifier {
  List<UserListItemModel> _users = [];
  int _totalElements = 0;
  bool _isLoading = false;
  String _searchQuery = '';

  List<UserListItemModel> get users => _users;
  int get totalElements => _totalElements;
  bool get isLoading => _isLoading;

  Future<void> fetchUsers({String? searchQuery}) async {
    if (searchQuery != null) {
      _searchQuery = searchQuery;
    }

    _isLoading = true;
    notifyListeners();

    try {
      final json = await AuthService.fetchOrganizationUsers(
        searchValue: _searchQuery,
      );

      final result = UserListResponse.fromJson(json);
      _users = result.users;
      _totalElements = result.totalElements;
    } catch (e) {
      debugPrint('Error fetching users: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}