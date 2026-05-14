import 'package:le_frais_mobile_application/game/food_memory_challenge/models/card_model.dart';
import 'package:le_frais_mobile_application/game/food_memory_challenge/models/difficulty_level.dart';

/// Represents the current state of a game
class GameState {
  final List<CardModel> cards;
  final DifficultyLevel difficulty;
  final int score;
  final int moves;
  final int timeRemaining;
  final int comboCount;
  final int matchedPairs;
  final bool isGameActive;
  final bool isGameOver;
  final bool isVictory;
  final int coinsEarned;
  final List<CardModel> flippedCards;
  final DateTime gameStartTime;

  const GameState({
    required this.cards,
    required this.difficulty,
    this.score = 0,
    this.moves = 0,
    this.timeRemaining = 0,
    this.comboCount = 0,
    this.matchedPairs = 0,
    this.isGameActive = false,
    this.isGameOver = false,
    this.isVictory = false,
    this.coinsEarned = 0,
    this.flippedCards = const [],
    required this.gameStartTime,
  });

  /// Create a copy with modified fields
  GameState copyWith({
    List<CardModel>? cards,
    DifficultyLevel? difficulty,
    int? score,
    int? moves,
    int? timeRemaining,
    int? comboCount,
    int? matchedPairs,
    bool? isGameActive,
    bool? isGameOver,
    bool? isVictory,
    int? coinsEarned,
    List<CardModel>? flippedCards,
    DateTime? gameStartTime,
  }) {
    return GameState(
      cards: cards ?? this.cards,
      difficulty: difficulty ?? this.difficulty,
      score: score ?? this.score,
      moves: moves ?? this.moves,
      timeRemaining: timeRemaining ?? this.timeRemaining,
      comboCount: comboCount ?? this.comboCount,
      matchedPairs: matchedPairs ?? this.matchedPairs,
      isGameActive: isGameActive ?? this.isGameActive,
      isGameOver: isGameOver ?? this.isGameOver,
      isVictory: isVictory ?? this.isVictory,
      coinsEarned: coinsEarned ?? this.coinsEarned,
      flippedCards: flippedCards ?? this.flippedCards,
      gameStartTime: gameStartTime ?? this.gameStartTime,
    );
  }

  /// Check if game is won
  bool checkVictory() => matchedPairs == difficulty.pairs;

  /// Get game progress percentage
  double getProgress() {
    return matchedPairs / difficulty.pairs;
  }

  /// Get elapsed time in seconds
  int getElapsedTime() {
    return difficulty.timeSeconds - timeRemaining;
  }
}
