import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/theme_model.dart';
import 'game_controller.dart';
import 'widgets/game_header.dart';
import 'widgets/game_grid.dart';
import 'widgets/game_overlay.dart';
import 'widgets/game_bottom_button.dart';

class GameScreen extends StatefulWidget {
  const GameScreen({super.key, required this.theme});

  final GameThemeModel theme;

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  late GameController _gameController;

  List<String> get _themeSymbols {
    return widget.theme.symbols.take(4).toList();
  }

  @override
  void initState() {
    super.initState();
    _gameController = GameController();
    _gameController.initializeGame(_themeSymbols);
  }

  @override
  void dispose() {
    _gameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _gameController,
      child: Consumer<GameController>(
        builder: (context, controller, child) {
          return LayoutBuilder(
            builder: (context, constraints) {
              final isLandscape = constraints.maxWidth > constraints.maxHeight;
              
              return Scaffold(
                appBar: AppBar(
                  title: Text(widget.theme.title),
                  actions: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Center(
                        child: Text(
                          controller.formatTime(controller.secondsLeft),
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    if (isLandscape) ...[
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Center(
                          child: ElevatedButton(
                            onPressed: () => controller.resetGame(_themeSymbols),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
                              foregroundColor: Theme.of(context).colorScheme.onSurface,
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                            ),
                            child: Text(controller.allCardsDisappeared ? 'Start' : (controller.timeUp ? 'Retry' : 'Reset')),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                body: Stack(
                  children: [
                    Column(
                      children: [
                        // Add space for the score header
                        SizedBox(height: isLandscape ? 30 : 50),
                        Expanded(
                          child: GameGrid(
                            isLandscape: isLandscape,
                            theme: widget.theme,
                          ),
                        ),
                      ],
                    ),
                    const GameOverlay(),
                    Positioned(
                      top: 0,
                      left: 0,
                      right: 0,
                      child: GameHeader(
                        isLandscape: isLandscape,
                        themeSymbols: _themeSymbols,
                      ),
                    ),
                    if (!isLandscape)
                      Positioned(
                        bottom: 0,
                        left: 0,
                        right: 0,
                        child: GameBottomButton(themeSymbols: _themeSymbols),
                      ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}

