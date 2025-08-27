import 'package:flutter/material.dart';
import 'dart:async';
import 'flip_card.dart';
import '../models/theme_model.dart';

class GameScreen extends StatefulWidget {
  final GameThemeModel theme;
  
  const GameScreen({super.key, required this.theme});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  late List<dynamic> deck;
  final List<int> flippedCards = [];
  final List<int> matchedPairs = [];
  final List<int> disappearingPairs = [];
  Timer? flipBackTimer;
  Timer? disappearTimer;

  static const int _startSeconds = 60;
  int _secondsLeft = _startSeconds;
  Timer? _countdown;

  int _wrongAttempts = 0;

  List<String> get _themeSymbols {
    return widget.theme.symbols.take(4).toList();
  }

  @override
  void initState() {
    super.initState();
    deck = [..._themeSymbols, ..._themeSymbols]..shuffle();
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

  int _calculateScore() {
    if (disappearingPairs.isEmpty) return 0;

    final matchScore = (disappearingPairs.length ~/ 2) * 25;
    
    final timeBonus = (_secondsLeft * 2) ~/ 60;
    
    final penalty = _wrongAttempts * 5;
    
    final totalScore = matchScore + timeBonus - penalty;

    return totalScore < 0 ? 0 : totalScore;
  }

  int get currentScore => _calculateScore();

  void resetGame() {
    flipBackTimer?.cancel();
    disappearTimer?.cancel();
    _stopCountdown();

    setState(() {
      flippedCards.clear();
      matchedPairs.clear();
      disappearingPairs.clear();
      deck = [..._themeSymbols, ..._themeSymbols]..shuffle();
      _secondsLeft = _startSeconds;
      _wrongAttempts = 0;
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
        setState(() => _wrongAttempts++);
        
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
        title: Text(widget.theme.title),
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
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isLandscape = constraints.maxWidth > constraints.maxHeight;
          final crossAxisCount = isLandscape ? 4 : 3;
          final childAspectRatio = isLandscape ? 2.0 : 0.7;
          final gridPadding = isLandscape ? 6.0 : 16.0;
          final gridSpacing = isLandscape ? 4.0 : 16.0;
          
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
                      'Score: $currentScore',
                      style: TextStyle(
                        fontSize: isLandscape ? 16 : 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const Spacer(),
                    if (isLandscape) ...[
                      ElevatedButton(
                        onPressed: resetGame,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.grey[300],
                          foregroundColor: Colors.black87,
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                        ),
                        child: Text(allCardsDisappeared ? 'Start' : (_timeUp ? 'Retry' : 'Reset')),
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
                      itemCount: deck.length,
                      itemBuilder: (_, i) {
                        if (disappearingPairs.contains(i)) return const SizedBox.shrink();
                        return FlipCard(
                          key: ValueKey(i),
                          themeName: widget.theme.title,
                          cardColor: Color.fromRGBO(
                            (widget.theme.red * 255).round(),
                            (widget.theme.green * 255).round(),
                            (widget.theme.blue * 255).round(),
                            1.0,
                          ),
                          isFlipped: flippedCards.contains(i) || matchedPairs.contains(i),
                          front: Center(
                            child:
                                Text(
                                    deck[i] as String,
                                    style: TextStyle(fontSize: isLandscape ? 18 : 28),
                                  )
                          ),
                          back: Icon(
                            Icons.diamond, 
                            size: isLandscape ? 18 : 28, 
                            color: Colors.white
                          ),
                          onTap: () => onCardTap(i),
                        );
                      },
                    ),

                    if (allCardsDisappeared)
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
                                'Final Score: $currentScore',
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

                    if (_timeUp && !allCardsDisappeared)
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
                                'Final Score: $currentScore',
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
                    onPressed: resetGame,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey[300],
                      foregroundColor: Colors.black87,
                      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                      textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    child: Text(allCardsDisappeared ? 'Start' : (_timeUp ? 'Retry' : 'Reset')),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}

