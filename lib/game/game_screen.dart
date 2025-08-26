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

  // Countdown
  static const int _startSeconds = 60;
  int _secondsLeft = _startSeconds;
  Timer? _countdown;

  @override
  void initState() {
    super.initState();
    deck = [...colors, ...colors]..shuffle();
    _startCountdown();
  }

  void _startCountdown() {
    _countdown?.cancel();
    _secondsLeft = _startSeconds;
    _countdown = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) return;
      if (_secondsLeft <= 1) {
        setState(() => _secondsLeft = 0);
        t.cancel();
      } else {
        setState(() => _secondsLeft--);
      }
    });
  }

  void _stopCountdown() {
    _countdown?.cancel();
  }

  bool get _timeUp => _secondsLeft == 0;

  String _fmt(int s) {
    final m = s ~/ 60;
    final sec = s % 60;
    return '$m:${sec.toString().padLeft(2, '0')}';
    }

  void resetGame() {
    flipBackTimer?.cancel();
    disappearTimer?.cancel();
    _stopCountdown();

    setState(() {
      flippedCards.clear();
      matchedPairs.clear();
      disappearingPairs.clear();
      deck = [...colors, ...colors]..shuffle();
      _secondsLeft = _startSeconds;
    });

    _startCountdown();
  }

  void onCardTap(int index) {
    if (_timeUp ||
        matchedPairs.contains(index) ||
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

          if (disappearingPairs.length == deck.length) {
            _stopCountdown();
          }
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
    _stopCountdown();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final allCardsDisappeared = disappearingPairs.length == deck.length;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Balloons'),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Center(
              child: Text(
                _fmt(_secondsLeft),
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
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

                // Win overlay
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
                            Shadow(offset: Offset(2, 2), blurRadius: 4, color: Colors.black54),
                          ],
                        ),
                      ),
                    ),
                  ),

                // Time's up overlay
                if (_timeUp && !allCardsDisappeared)
                  Container(
                    color: Colors.black54,
                    child: const Center(
                      child: Text(
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
                    ),
                  ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(16),
            child: ElevatedButton(
              onPressed: resetGame,
              style: ElevatedButton.styleFrom(
                backgroundColor: allCardsDisappeared
                    ? Colors.green
                    : (_timeUp ? Colors.red : Colors.orange),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              child: Text(allCardsDisappeared ? 'Start' : (_timeUp ? 'Retry' : 'Reset')),
            ),
          ),
        ],
      ),
    );
  }
}
