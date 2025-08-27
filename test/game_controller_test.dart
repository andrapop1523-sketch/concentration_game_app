import 'package:flutter_test/flutter_test.dart';
import 'package:concentration_game_app/game/game_controller.dart';
import 'package:concentration_game_app/game/game_constants.dart';

void main() {
  group('GameController', () {
    late GameController controller;
    late List<String> testSymbols;

    setUp(() {
      controller = GameController();
      testSymbols = ['🎈', '🎃', '⭐', '🎨'];
    });

    tearDown(() {
      controller.dispose();
    });

    group('Game Initialization', () {
      test('should initialize game with shuffled deck', () {
        controller.initializeGame(testSymbols);
        
        expect(controller.deck.length, equals(8)); // 4 pairs
        expect(controller.flippedCards, isEmpty);
        expect(controller.matchedPairs, isEmpty);
        expect(controller.disappearingPairs, isEmpty);
        expect(controller.secondsLeft, equals(GameConstants.gameDurationSeconds));
        expect(controller.wrongAttempts, equals(0));
        expect(controller.startTime, equals(0));
        expect(controller.timeUp, isFalse);
        expect(controller.allCardsDisappeared, isFalse);
      });

      test('should start countdown when game initializes', () async {
        controller.initializeGame(testSymbols);
        
        expect(controller.secondsLeft, equals(GameConstants.gameDurationSeconds));
        
        await Future.delayed(Duration(seconds: 2));
        
        expect(controller.secondsLeft, lessThan(GameConstants.gameDurationSeconds));
      });
    });

    group('Card Flipping', () {
      test('should flip first card when tapped', () {
        controller.initializeGame(testSymbols);
        
        controller.onCardTap(0);
        
        expect(controller.flippedCards, contains(0));
        expect(controller.flippedCards.length, equals(1));
      });

      test('should not allow tapping already flipped card', () {
        controller.initializeGame(testSymbols);
        
        controller.onCardTap(0);
        controller.onCardTap(0); // Tap same card again
        
        expect(controller.flippedCards.length, equals(1));
        expect(controller.flippedCards, contains(0));
      });
    });

    group('Card Matching', () {

      test('should not match different symbols', () async {
        controller.initializeGame(testSymbols);
        
        controller.onCardTap(0);
        controller.onCardTap(1); // Different symbol
        
        expect(controller.matchedPairs, isEmpty);
        expect(controller.flippedCards, containsAll([0, 1]));
        
        // Wait for timer to complete
        await Future.delayed(Duration(seconds: GameConstants.cardFlipDelaySeconds + 1));
        
        expect(controller.flippedCards, isEmpty);
      });

      test('should increment wrong attempts for non-matches', () async {
        controller.initializeGame(testSymbols);
        
        controller.onCardTap(0);
        controller.onCardTap(1); // Different symbol
        
        expect(controller.wrongAttempts, equals(1));
        
        // Wait for timer to complete
        await Future.delayed(Duration(seconds: GameConstants.cardFlipDelaySeconds + 1));
      });
    });

    group('Timer Behavior', () {
      test('should flip back non-matching cards after delay', () async {
        controller.initializeGame(testSymbols);
        
        controller.onCardTap(0);
        controller.onCardTap(1); // Different symbol
        
        expect(controller.flippedCards, containsAll([0, 1]));
        
        // Wait for timer to complete
        await Future.delayed(Duration(seconds: GameConstants.cardFlipDelaySeconds + 1));
        
        expect(controller.flippedCards, isEmpty);
      });
    });

    group('Scoring System', () {
      test('should start with score 0', () {
        controller.initializeGame(testSymbols);
        
        expect(controller.calculateScore(), equals(0));
      });

      test('should never return negative score', () async {
        controller.initializeGame(testSymbols);
        
        // Make many wrong attempts
        for (int i = 0; i < 10; i++) {
          controller.onCardTap(0);
          controller.onCardTap(1);
          await Future.delayed(Duration(seconds: GameConstants.cardFlipDelaySeconds + 1));
        }
        
        // Make one correct match
        controller.onCardTap(0);
        controller.onCardTap(4);
        await Future.delayed(Duration(seconds: GameConstants.cardFlipDelaySeconds + 1));
        
        final score = controller.calculateScore();
        expect(score, greaterThanOrEqualTo(0));
      });
    });

    group('Game Reset', () {
      test('should reset all game state', () async {
        controller.initializeGame(testSymbols);
        
        controller.onCardTap(0);
        controller.onCardTap(1);
        await Future.delayed(Duration(seconds: GameConstants.cardFlipDelaySeconds + 1));
        
        // Reset the game
        controller.resetGame(testSymbols);
        
        expect(controller.flippedCards, isEmpty);
        expect(controller.matchedPairs, isEmpty);
        expect(controller.disappearingPairs, isEmpty);
        expect(controller.secondsLeft, equals(GameConstants.gameDurationSeconds));
        expect(controller.wrongAttempts, equals(0));
        expect(controller.startTime, equals(0));
        expect(controller.timeUp, isFalse);
        expect(controller.allCardsDisappeared, isFalse);
      });

      test('should shuffle deck on reset', () {
        controller.initializeGame(testSymbols);
        final firstDeck = List.from(controller.deck);
        
        controller.resetGame(testSymbols);
        final secondDeck = List.from(controller.deck);
        
        // Could fail, if shuffle results in same order by chance
        expect(secondDeck, isNot(equals(firstDeck)));
      });

      test('should restart countdown on reset', () {
        controller.initializeGame(testSymbols);
        
        Future.delayed(Duration(seconds: 5));
        
        controller.resetGame(testSymbols);
        
        expect(controller.secondsLeft, equals(GameConstants.gameDurationSeconds));
      });
    });

    group('Game State Getters', () {
      test('should return unmodifiable lists', () {
        controller.initializeGame(testSymbols);
        
        expect(() => controller.flippedCards.add(0), throwsUnsupportedError);
        expect(() => controller.matchedPairs.add(0), throwsUnsupportedError);
        expect(() => controller.disappearingPairs.add(0), throwsUnsupportedError);
      });

      test('should calculate timeUp correctly', () {
        controller.initializeGame(testSymbols);
        
        expect(controller.timeUp, isFalse);
        
        expect(controller.secondsLeft == 0, equals(controller.timeUp));
      });

      test('should calculate allCardsDisappeared correctly', () {
        controller.initializeGame(testSymbols);
        
        expect(controller.allCardsDisappeared, isFalse);
        
        expect(controller.disappearingPairs.length == controller.deck.length, 
               equals(controller.allCardsDisappeared));
      });
    });
  });
}
