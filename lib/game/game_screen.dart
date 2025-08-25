import 'package:flutter/material.dart';
import 'flip_card.dart';

class GameScreen extends StatelessWidget {
  const GameScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = [
      Colors.red,
      Colors.blue,
      Colors.green,
      Colors.purple,
    ];
    final deck = [...colors, ...colors]..shuffle();

    return Scaffold(
      appBar: AppBar(title: const Text('Balloons')),
      body: LayoutBuilder(
        builder: (context, constraints) {
          return GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 0.7,
            ),
            itemCount: deck.length,
            itemBuilder: (_, i) => FlipCard(
              front: Center(
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: deck[i],
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                ),
              ),
              back: const Icon(Icons.help_outline, size: 28),
            ),
          );
        },
      ),
    );
  }
}
