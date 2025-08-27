import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../game_controller.dart';
import '../game_constants.dart';

class GameHeader extends StatelessWidget {
  final bool isLandscape;
  final List<String> themeSymbols;

  const GameHeader({
    super.key,
    required this.isLandscape,
    required this.themeSymbols,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<GameController>(
      builder: (context, controller, child) {
        return Container(
          padding: EdgeInsets.symmetric(
            horizontal: isLandscape ? 12 : 16, 
            vertical: isLandscape ? 4 : 8
          ),
          child: Text(
            'Score: ${controller.calculateScore()}',
            style: TextStyle(
              fontSize: isLandscape 
                  ? GameConstants.landscapeScoreFontSize 
                  : GameConstants.portraitScoreFontSize,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
        );
      },
    );
  }
}
