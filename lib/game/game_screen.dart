import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/theme_model.dart';
import 'flip_card.dart';
import 'game_controller.dart';
import 'game_constants.dart';

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
              ],
            ),
            body: LayoutBuilder(
              builder: (context, constraints) {
                final isLandscape = constraints.maxWidth > constraints.maxHeight;
                final crossAxisCount = isLandscape 
                    ? GameConstants.landscapeCrossAxisCount 
                    : GameConstants.portraitCrossAxisCount;
                final childAspectRatio = isLandscape 
                    ? GameConstants.landscapeChildAspectRatio 
                    : GameConstants.portraitChildAspectRatio;
                final gridPadding = isLandscape 
                    ? GameConstants.landscapeGridPadding 
                    : GameConstants.portraitGridPadding;
                final gridSpacing = isLandscape 
                    ? GameConstants.landscapeGridSpacing 
                    : GameConstants.portraitGridSpacing;
                
                return Column(
                  children: [
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: isLandscape ? 12 : 16, 
                        vertical: isLandscape ? 4 : 8
                      ),
                      child: Row(
                        children: [
                          Text(
                            'Score: ${controller.calculateScore()}',
                            style: TextStyle(
                              fontSize: isLandscape 
                                  ? GameConstants.landscapeScoreFontSize 
                                  : GameConstants.portraitScoreFontSize,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                          const Spacer(),
                          if (isLandscape) ...[
                            ElevatedButton(
                              onPressed: () => controller.resetGame(_themeSymbols),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.grey[300],
                                foregroundColor: Colors.black87,
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                              ),
                              child: Text(controller.allCardsDisappeared ? 'Start' : (controller.timeUp ? 'Retry' : 'Reset')),
                            ),
                          ],
                        ],
                      ),
                    ),
                    Expanded(
                      child: Stack(
                        children: [
                          GridView.builder(
                            padding: EdgeInsets.all(gridPadding),
                            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: crossAxisCount,
                              crossAxisSpacing: gridSpacing,
                              mainAxisSpacing: gridSpacing,
                              childAspectRatio: childAspectRatio,
                            ),
                            itemCount: controller.deck.length,
                            itemBuilder: (_, i) {
                              if (controller.disappearingPairs.contains(i)) return const SizedBox.shrink();
                              return FlipCard(
                                key: ValueKey(i),
                                themeName: widget.theme.title,
                                cardColor: Color.fromRGBO(
                                  (widget.theme.red * 255).round(),
                                  (widget.theme.green * 255).round(),
                                  (widget.theme.blue * 255).round(),
                                  1.0,
                                ),
                                isFlipped: controller.flippedCards.contains(i) || controller.matchedPairs.contains(i),
                                front: Center(
                                  child: Text(
                                    controller.deck[i] as String,
                                    style: TextStyle(
                                      fontSize: isLandscape 
                                          ? GameConstants.landscapeCardTextFontSize 
                                          : GameConstants.portraitCardTextFontSize
                                    ),
                                  ),
                                ),
                                back: Icon(
                                  Icons.diamond, 
                                  size: isLandscape 
                                      ? GameConstants.landscapeCardIconSize 
                                      : GameConstants.portraitCardIconSize, 
                                  color: Colors.white
                                ),
                                onTap: () => controller.onCardTap(i),
                              );
                            },
                          ),

                          if (controller.allCardsDisappeared)
                            Container(
                              color: Colors.black54,
                              child: Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Text(
                                      'You Won!',
                                      style: TextStyle(
                                        fontSize: 48,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                        shadows: [
                                          Shadow(offset: Offset(2, 2), blurRadius: 4, color: Colors.black54),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(height: 16),
                                    Text(
                                      'Final Score: ${controller.calculateScore()}',
                                      style: const TextStyle(
                                        fontSize: 24,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.white,
                                        shadows: [
                                          Shadow(offset: Offset(1, 1), blurRadius: 2, color: Colors.black54),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),

                          if (controller.timeUp && !controller.allCardsDisappeared)
                            Container(
                              color: Colors.black54,
                              child: Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Text(
                                      "Time's Up!",
                                      style: TextStyle(
                                        fontSize: 42,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                        shadows: [
                                          Shadow(offset: Offset(2, 2), blurRadius: 4, color: Colors.black54),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(height: 16),
                                    Text(
                                      'Final Score: ${controller.calculateScore()}',
                                      style: const TextStyle(
                                        fontSize: 24,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.white,
                                        shadows: [
                                          Shadow(offset: Offset(1, 1), blurRadius: 2, color: Colors.black54),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                    if (!isLandscape)
                      Container(
                        padding: const EdgeInsets.all(16),
                        child: ElevatedButton(
                          onPressed: () => controller.resetGame(_themeSymbols),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.grey[300],
                            foregroundColor: Colors.black87,
                            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                            textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          child: Text(controller.allCardsDisappeared ? 'Start' : (controller.timeUp ? 'Retry' : 'Reset')),
                        ),
                      ),
                  ],
                );
              },
            ),
          );
        },
      ),
    );
  }
}

