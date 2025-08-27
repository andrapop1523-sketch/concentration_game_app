import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'models/theme_model.dart';
import 'game/game_screen.dart';

class ThemeSelectionScreen extends StatefulWidget {
  const ThemeSelectionScreen({super.key});

  @override
  State<ThemeSelectionScreen> createState() => _ThemeSelectionScreenState();
}

class _ThemeSelectionScreenState extends State<ThemeSelectionScreen> {
  List<GameThemeModel> themes = [];
  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    _downloadThemes();
  }

  Future<void> _downloadThemes() async {
    try {
      final response = await http.get(
        Uri.parse('https://firebasestorage.googleapis.com/v0/b/concentrationgame-20753.appspot.com/o/themes.json?alt=media&token=6898245a-0586-4fed-b30e-5078faeba078'),
      );

      if (response.statusCode == 200) {
        final List<dynamic> jsonThemes = json.decode(response.body);
        final List<GameThemeModel> downloadedThemes = jsonThemes
            .map((json) => GameThemeModel.fromJson(json))
            .toList();

        setState(() {
          themes = downloadedThemes;
          isLoading = false;
        });
      } else {
        setState(() {
          errorMessage = 'Failed to load themes: ${response.statusCode}';
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = 'Error loading themes: $e';
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isLandscape = constraints.maxWidth > constraints.maxHeight;
          
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Matching Pairs',
                  style: TextStyle(
                    fontSize: isLandscape ? 36 : 48,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 48),
                if (isLoading)
                  const CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.orange),
                  )
                else if (errorMessage != null)
                  Column(
                    children: [
                      Icon(
                        Icons.error_outline,
                        size: isLandscape ? 36 : 48,
                        color: Colors.red[400],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        errorMessage!,
                        style: TextStyle(
                          fontSize: isLandscape ? 14 : 16,
                          color: Colors.red[600],
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _downloadThemes,
                        child: const Text('Retry'),
                      ),
                    ],
                  )
                else
                  Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: isLandscape ? 64 : 32,
                    ),
                    child: Column(
                      children: themes.map((theme) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 24),
                          child: _buildThemeOption(
                            context,
                            theme: theme,
                            onTap: () => _navigateToGame(context, theme),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildThemeOption(
    BuildContext context, {
    required GameThemeModel theme,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.blue[400],
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
          border: Border.all(color: Colors.blue[600]!, width: 2),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    theme.title,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              color: Colors.white,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }

  void _navigateToGame(BuildContext context, GameThemeModel theme) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => GameScreen(theme: theme),
      ),
    );
  }
}


