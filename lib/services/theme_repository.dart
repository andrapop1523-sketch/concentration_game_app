import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/theme_model.dart';

class ThemeFetchException implements Exception {
  final String message;
  ThemeFetchException(this.message);
  
  @override
  String toString() => 'ThemeFetchException: $message';
}

class ThemeRepository {
  static const String _themesUrl = 'https://firebasestorage.googleapis.com/v0/b/concentrationgame-20753.appspot.com/o/themes.json?alt=media&token=6898245a-0586-4fed-b30e-5078faeba078';
  
  Future<List<GameThemeModel>> fetchThemes() async {
    try {
      final response = await http.get(Uri.parse(_themesUrl));
      
      if (response.statusCode == 200) {
        final List<dynamic> jsonList = json.decode(response.body);
        return jsonList
            .map((json) => GameThemeModel.fromJson(json))
            .toList();
      } else {
        throw ThemeFetchException('Failed to load themes: ${response.statusCode}');
      }
    } catch (e) {
      if (e is ThemeFetchException) {
        rethrow;
      }
      throw ThemeFetchException('Network error: $e');
    }
  }
}
