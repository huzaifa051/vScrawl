import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../models/templates_model.dart';

class TemplatesProvider with ChangeNotifier {
  List<TemplateFolderModel> _folders = [];
  List<TemplateItemModel> _templates = [];
  int _totalElements = 0;
  bool _isLoading = false;

  List<TemplateFolderModel> get folders => _folders;

  List<TemplateItemModel> get templates => _templates;

  int get totalElements => _totalElements;

  bool get isLoading => _isLoading;

  Future<void> fetchTemplates() async {
    _isLoading = true;
    notifyListeners();
    try {
      final results = await Future.wait([
        AuthService.fetchTemplateFolders(),
        AuthService.fetchTemplates(),
      ]);

      final foldersJson = results[0] as List<dynamic>;
      _folders = foldersJson
      .map((e) => TemplateFolderModel.fromJson(e as Map<String, dynamic>))
      .toList();

      final templatesJson = results[1] as Map<String, dynamic>;
      final result = TemplateListResponse.fromJson(templatesJson);
      _templates = result.templates;
      _totalElements = result.totalElements;
    } catch (e) {
      debugPrint('Error fetching templates $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
