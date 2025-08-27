import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../game_controller.dart';
import '../flip_card.dart';
import '../game_constants.dart';
import '../../models/theme_model.dart';

class GameGrid extends StatelessWidget {
  final bool isLandscape;
  final GameThemeModel theme;

  const GameGrid({
    super.key,
    required this.isLandscape,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<GameController>(
      builder: (context, controller, child) {
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

        return GridView.builder(
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
              themeName: theme.title,
              cardColor: Color.fromRGBO(
                (theme.red * 255).round(),
                (theme.green * 255).round(),
                (theme.blue * 255).round(),
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
              back: Center(
                child: Text(
                  theme.cardSymbol,
                  style: TextStyle(
                    fontSize: isLandscape 
                        ? GameConstants.landscapeCardTextFontSize 
                        : GameConstants.portraitCardTextFontSize
                  ),
                ),
              ),
              onTap: () => controller.onCardTap(i),
            );
          },
        );
      },
    );
  }
}
