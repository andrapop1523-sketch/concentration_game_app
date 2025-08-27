import 'package:flutter/material.dart';
import '../models/theme_model.dart';
import '../services/theme_repository.dart';

class ThemeController extends ChangeNotifier {
  final ThemeRepository _repository = ThemeRepository();
  
  List<GameThemeModel> _themes = [];
  bool _isLoading = false;
  String? _errorMessage;
  
  // Getters
  List<GameThemeModel> get themes => List.unmodifiable(_themes);
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get hasError => _errorMessage != null;
  bool get hasThemes => _themes.isNotEmpty;
  
  // Initialize themes
  Future<void> loadThemes() async {
    _setLoading(true);
    _clearError();
    
    try {
      final themes = await _repository.fetchThemes();
      _themes = themes;
      _setLoading(false);
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
    }
  }
  
  // Retry loading themes
  Future<void> retry() async {
    await loadThemes();
  }
  
  // Clear error state
  void _clearError() {
    _errorMessage = null;
    notifyListeners();
  }
  
  // Set error state
  void _setError(String message) {
    _errorMessage = message;
    notifyListeners();
  }
  
  // Set loading state
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }
  
  // Get theme by index
  GameThemeModel? getTheme(int index) {
    if (index >= 0 && index < _themes.length) {
      return _themes[index];
    }
    return null;
  }
  
  // Get theme count
  int get themeCount => _themes.length;
}
