import 'package:flutter/material.dart';
import 'dart:async';
import 'flip_card.dart';

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  final colors = [Colors.red, Colors.blue, Colors.green, Colors.purple];
  late List<Color> deck;
  final List<int> flippedCards = [];
  final List<int> matchedPairs = [];
  final List<int> disappearingPairs = [];
  Timer? flipBackTimer;
  Timer? disappearTimer;

  @override
  void initState() {
    super.initState();
    deck = [...colors, ...colors]..shuffle();
  }

  void resetGame() {
    flipBackTimer?.cancel();
    disappearTimer?.cancel();
    
    setState(() {
      flippedCards.clear();
      matchedPairs.clear();
      disappearingPairs.clear();
      deck = [...colors, ...colors]..shuffle();
    });
  }

  void onCardTap(int index) {
    if (matchedPairs.contains(index) ||
        flippedCards.contains(index) ||
        disappearingPairs.contains(index)) {
      return;
    }

    setState(() => flippedCards.add(index));

    if (flippedCards.length == 2) {
      final firstIndex = flippedCards[0];
      final secondIndex = flippedCards[1];

      if (deck[firstIndex] == deck[secondIndex]) {
        setState(() {
          matchedPairs.addAll([firstIndex, secondIndex]);
          flippedCards.clear();
        });

        disappearTimer = Timer(const Duration(seconds: 1), () {
          if (!mounted) return;
          setState(() => disappearingPairs.addAll([firstIndex, secondIndex]));
        });
      } else {
        flipBackTimer = Timer(const Duration(seconds: 1), () {
          if (!mounted) return;
          setState(flippedCards.clear);
        });
      }
    }
  }

  @override
  void dispose() {
    flipBackTimer?.cancel();
    disappearTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final allCardsDisappeared = disappearingPairs.length == deck.length;
    
    return Scaffold(
      appBar: AppBar(title: const Text('Balloons')),
      body: Column(
        children: [
          Expanded(
            child: Stack(
              children: [
                GridView.builder(
                  padding: const EdgeInsets.all(16),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: 0.7,
                  ),
                  itemCount: deck.length,
                  itemBuilder: (_, i) {
                    if (disappearingPairs.contains(i)) return const SizedBox.shrink();
                    return FlipCard(
                      key: ValueKey(i),
                      isFlipped: flippedCards.contains(i) || matchedPairs.contains(i),
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
                      onTap: () => onCardTap(i),
                    );
                  },
                ),
                if (allCardsDisappeared)
                  Container(
                    color: Colors.black54,
                    child: const Center(
                      child: Text(
                        'You Won!',
                        style: TextStyle(
                          fontSize: 48,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          shadows: [
                            Shadow(
                              offset: Offset(2, 2),
                              blurRadius: 4,
                              color: Colors.black54,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(16),
            child: allCardsDisappeared
                ? ElevatedButton(
                    onPressed: resetGame,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                      textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    child: const Text('Start'),
                  )
                : ElevatedButton(
                    onPressed: resetGame,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                      textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    child: const Text('Reset'),
                  ),
          ),
        ],
      ),
    );
  }
}
