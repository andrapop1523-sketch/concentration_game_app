import 'dart:async';
import 'package:flutter/material.dart';
import 'game_constants.dart';

class GameController extends ChangeNotifier {
  List<dynamic> _deck = [];
  final List<int> _flippedCards = [];
  final List<int> _matchedPairs = [];
  final List<int> _disappearingPairs = [];
  Timer? _cardFlipTimer;
  Timer? _countdownTimer;
  
  int _secondsLeft = GameConstants.gameDurationSeconds;
  int _wrongAttempts = 0;
  int _startTime = 0;
  
  List<dynamic> get deck => _deck;
  List<int> get flippedCards => List.unmodifiable(_flippedCards);
  List<int> get matchedPairs => List.unmodifiable(_matchedPairs);
  List<int> get disappearingPairs => List.unmodifiable(_disappearingPairs);
  int get secondsLeft => _secondsLeft;
  int get wrongAttempts => _wrongAttempts;
  int get startTime => _startTime;
  bool get timeUp => _secondsLeft == 0;
  bool get allCardsDisappeared => _disappearingPairs.length == _deck.length;
  
  void initializeGame(List<String> symbols) {
    _deck = [...symbols, ...symbols]..shuffle();
    _startCountdown();
    notifyListeners();
  }
  
  void _startCountdown() {
    _countdownTimer?.cancel();
    _secondsLeft = GameConstants.gameDurationSeconds;
    _countdownTimer = Timer.periodic(
      Duration(seconds: GameConstants.countdownIntervalSeconds), 
      (t) {
        if (_secondsLeft <= 1) {
          _secondsLeft = 0;
          notifyListeners();
          t.cancel();
        } else {
          _secondsLeft--;
          notifyListeners();
        }
      }
    );
  }
  
  void _stopCountdown() {
    _countdownTimer?.cancel();
  }
  
  String formatTime(int seconds) {
    final m = seconds ~/ 60;
    final sec = seconds % 60;
    return '$m:${sec.toString().padLeft(2, '0')}';
  }
  
  int calculateScore() {
    if (_disappearingPairs.isEmpty) return 0;
    
    final matchScore = (_disappearingPairs.length ~/ 2) * GameConstants.scorePerMatch;
    final timeBonus = (_secondsLeft * GameConstants.timeBonusMultiplier) ~/ GameConstants.timeBonusDivisor;
    final penalty = _wrongAttempts * GameConstants.penaltyPerMistake;
    final totalScore = matchScore + timeBonus - penalty;
    
    return totalScore < 0 ? 0 : totalScore;
  }
  
  void resetGame(List<String> symbols) {
    _cardFlipTimer?.cancel();
    _stopCountdown();
    
    _flippedCards.clear();
    _matchedPairs.clear();
    _disappearingPairs.clear();
    _deck = [...symbols, ...symbols]..shuffle();
    _secondsLeft = GameConstants.gameDurationSeconds;
    _wrongAttempts = 0;
    _startTime = 0;
    
    _startCountdown();
    notifyListeners();
  }
  
  void onCardTap(int index) {
    if (timeUp ||
        _matchedPairs.contains(index) ||
        _flippedCards.contains(index) ||
        _disappearingPairs.contains(index) ||
        _cardFlipTimer != null) {
      return;
    }
    
    _flippedCards.add(index);
    
    if (_startTime == 0) {
      _startTime = GameConstants.gameDurationSeconds;
    }
    
    if (_flippedCards.length == 2) {
      final firstIndex = _flippedCards[0];
      final secondIndex = _flippedCards[1];
      
      if (_deck[firstIndex] == _deck[secondIndex]) {
        _matchedPairs.addAll([firstIndex, secondIndex]);
        _flippedCards.clear();
        
        _cardFlipTimer = Timer(
          Duration(seconds: GameConstants.cardFlipDelaySeconds), 
          () {
            _disappearingPairs.addAll([firstIndex, secondIndex]);
            
            if (_disappearingPairs.length == _deck.length) {
              _stopCountdown();
            }
            _cardFlipTimer = null;
            notifyListeners();
          }
        );
      } else {
        _wrongAttempts++;
        
        _cardFlipTimer = Timer(
          Duration(seconds: GameConstants.cardFlipDelaySeconds), 
          () {
            _flippedCards.clear();
            _cardFlipTimer = null;
            notifyListeners();
          }
        );
      }
      
      notifyListeners();
    } else {
      notifyListeners();
    }
  }
  
  @override
  void dispose() {
    _cardFlipTimer?.cancel();
    _countdownTimer?.cancel();
    super.dispose();
  }
}
