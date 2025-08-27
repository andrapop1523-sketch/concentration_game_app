import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'controllers/theme_controller.dart';
import 'models/theme_model.dart';
import 'game/game_screen.dart';

class ThemeSelectionScreen extends StatefulWidget {
  const ThemeSelectionScreen({super.key});

  @override
  State<ThemeSelectionScreen> createState() => _ThemeSelectionScreenState();
}

class _ThemeSelectionScreenState extends State<ThemeSelectionScreen> {
  late ThemeController _themeController;

  @override
  void initState() {
    super.initState();
    _themeController = ThemeController();
    _themeController.loadThemes();
  }

  @override
  void dispose() {
    _themeController.dispose();
    super.dispose();
  }

  void _navigateToGame(BuildContext context, GameThemeModel theme) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => GameScreen(theme: theme),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _themeController,
      child: Consumer<ThemeController>(
        builder: (context, controller, child) {
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
                      if (controller.isLoading)
                        const CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.orange),
                        )
                      else if (controller.hasError)
                        _buildErrorState(controller, isLandscape)
                      else if (controller.hasThemes)
                        _buildThemeList(controller, isLandscape)
                      else
                        _buildEmptyState(),
                    ],
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildErrorState(ThemeController controller, bool isLandscape) {
    return Column(
      children: [
        Icon(
          Icons.error_outline,
          size: isLandscape ? 36 : 48,
          color: Colors.red[400],
        ),
        const SizedBox(height: 16),
        Text(
          controller.errorMessage ?? 'Unknown error occurred',
          style: TextStyle(
            fontSize: isLandscape ? 14 : 16,
            color: Colors.red[600],
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 16),
        ElevatedButton(
          onPressed: controller.retry,
          child: const Text('Retry'),
        ),
      ],
    );
  }

  Widget _buildThemeList(ThemeController controller, bool isLandscape) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: isLandscape ? 64 : 32,
      ),
      child: Column(
        children: controller.themes.map((theme) {
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
    );
  }

  Widget _buildEmptyState() {
    return Column(
      children: [
        Icon(
          Icons.inbox_outlined,
          size: 48,
          color: Colors.grey[400],
        ),
        const SizedBox(height: 16),
        Text(
          'No themes available',
          style: TextStyle(
            fontSize: 18,
            color: Colors.grey[600],
          ),
        ),
        const SizedBox(height: 16),
        ElevatedButton(
          onPressed: () => _themeController.loadThemes(),
          child: const Text('Refresh'),
        ),
      ],
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
}
