import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../game_controller.dart';

class GameBottomButton extends StatelessWidget {
  final List<String> themeSymbols;

  const GameBottomButton({
    super.key,
    required this.themeSymbols,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<GameController>(
      builder: (context, controller, child) {
        return Container(
          padding: const EdgeInsets.only(bottom: 32, left: 16, right: 16),
          child: ElevatedButton(
            onPressed: () => controller.resetGame(themeSymbols),
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
              foregroundColor: Theme.of(context).colorScheme.onSurface,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            child: Text(controller.allCardsDisappeared ? 'Start' : (controller.timeUp ? 'Retry' : 'Reset')),
          ),
        );
      },
    );
  }
}
