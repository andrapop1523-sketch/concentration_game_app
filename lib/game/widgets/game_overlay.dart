import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../game_controller.dart';

class GameOverlay extends StatelessWidget {
  const GameOverlay({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<GameController>(
      builder: (context, controller, child) {
        return Stack(
          children: [
            if (controller.allCardsDisappeared)
              _buildWinOverlay(controller),
            if (controller.timeUp && !controller.allCardsDisappeared)
              _buildTimeUpOverlay(controller),
          ],
        );
      },
    );
  }

  Widget _buildWinOverlay(GameController controller) {
    return Container(
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
    );
  }

  Widget _buildTimeUpOverlay(GameController controller) {
    return Container(
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
    );
  }
}
