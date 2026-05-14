import 'dart:async';
import 'dart:math';
import 'package:le_frais_mobile_application/game/food_memory_challenge/models/card_model.dart';
import 'package:le_frais_mobile_application/game/food_memory_challenge/models/game_state.dart';
import 'package:le_frais_mobile_application/game/food_memory_challenge/models/difficulty_level.dart';
import 'package:le_frais_mobile_application/game/food_memory_challenge/utils/game_constants.dart';
import 'package:le_frais_mobile_application/game/food_memory_challenge/utils/food_items.dart';

/// Main game service handling game logic
class GameService {
  late GameState _gameState;
  Timer? _gameTimer;
  final _random = Random();
  bool _isCheckingPair = false;

  // Callbacks
  Function(GameState)? onGameStateChanged;
  Function(int)? onTimeUpdate; // Called every second
  Function()? onComboTriggered;
  Function(CardModel)? onGoldenCardFlipped;
  Function(CardModel)? onRainbowCardFlipped;

  /// Initialize a new game
  GameState initializeGame(DifficultyLevel difficulty) {
    _gameTimer?.cancel();
    final foodItems = FoodItems.getRandomItems(difficulty.pairs);
    final cards = _generateCards(foodItems);

    _gameState = GameState(
      cards: cards,
      difficulty: difficulty,
      timeRemaining: difficulty.timeSeconds,
      isGameActive: true,
      gameStartTime: DateTime.now(),
    );

    _isCheckingPair = false;
    _startGameTimer();
    return _gameState;
  }

  /// Generate cards for the game (pairs)
  List<CardModel> _generateCards(List<FoodItem> foodItems) {
    final cards = <CardModel>[];
    int cardId = 0;

    for (var foodItem in foodItems) {
      for (int i = 0; i < 2; i++) {
        // Determine if this card should be special
        final isGolden =
            _random.nextDouble() < GameConstants.goldenCardProbability;
        final isRainbow =
            !isGolden &&
            _random.nextDouble() < GameConstants.rainbowCardProbability;

        cards.add(
          CardModel(
            id: 'card_$cardId',
            foodEmoji: foodItem.emoji,
            foodName: foodItem.name,
            isGoldenCard: isGolden,
            isRainbowCard: isRainbow,
          ),
        );
        cardId++;
      }
    }

    // Shuffle cards
    cards.shuffle(_random);
    return cards;
  }

  /// Tap a card
  Future<bool> tapCard(String cardId) async {
    if (!_gameState.isGameActive || _isCheckingPair) {
      return false;
    }

    final card = _gameState.cards.firstWhere((c) => c.id == cardId);

    if (card.isMatched || card.isFlipped) {
      return false;
    }

    // Flip the card
    late CardModel flippedCard;
    final updatedCards = _gameState.cards.map((c) {
      if (c.id == cardId) {
        flippedCard = c.copyWith(isFlipped: true);
        return flippedCard;
      }
      return c;
    }).toList();

    // Check if it's a special card
    if (card.isGoldenCard) {
      onGoldenCardFlipped?.call(card);
    } else if (card.isRainbowCard) {
      onRainbowCardFlipped?.call(card);
    }

    // Update state with flipped card
    _gameState = _gameState.copyWith(
      cards: updatedCards,
      flippedCards: [..._gameState.flippedCards, flippedCard],
    );
    onGameStateChanged?.call(_gameState);

    // If two cards are flipped, check for match
    if (_gameState.flippedCards.length == 2) {
      _isCheckingPair = true;
      await Future.delayed(
        const Duration(milliseconds: GameConstants.cardFlipDuration),
      );
      _checkMatch();
    }

    return true;
  }

  /// Check if flipped cards match
  void _checkMatch() {
    if (_gameState.flippedCards.length != 2) return;

    final card1 = _gameState.flippedCards[0];
    final card2 = _gameState.flippedCards[1];

    if (card1.matches(card2)) {
      _handleMatch(card1, card2);
    } else {
      _handleMismatch(card1, card2);
    }
  }

  /// Handle successful match
  void _handleMatch(CardModel card1, CardModel card2) {
    // Mark cards as matched
    final updatedCards = _gameState.cards.map((c) {
      if (c.id == card1.id || c.id == card2.id) {
        return c.copyWith(isMatched: true);
      }
      return c;
    }).toList();

    final newMatchedPairs = _gameState.matchedPairs + 1;
    var newScore = _gameState.score + GameConstants.baseMatchScore;
    var newCombo = _gameState.comboCount + 1;

    // Calculate combo multiplier
    int comboMultiplier = 1;
    if (newCombo >= GameConstants.comboTriggerCount) {
      comboMultiplier = newCombo >= 5
          ? GameConstants.comboMultiplierX3
          : GameConstants.comboMultiplierX2;
      onComboTriggered?.call();
    }

    newScore += GameConstants.baseMatchScore * (comboMultiplier - 1);

    // Add bonus for special cards
    if (card1.isGoldenCard || card2.isGoldenCard) {
      newScore += 50;
    } else if (card1.isRainbowCard || card2.isRainbowCard) {
      newScore += 100;
    }

    _gameState = _gameState.copyWith(
      cards: updatedCards,
      matchedPairs: newMatchedPairs,
      score: newScore,
      comboCount: newCombo,
      moves: _gameState.moves + 1,
      flippedCards: [],
    );
    _isCheckingPair = false;

    // Check if game won
    if (_gameState.checkVictory()) {
      _endGame(victory: true);
    }

    onGameStateChanged?.call(_gameState);
  }

  /// Handle mismatch
  void _handleMismatch(CardModel card1, CardModel card2) {
    // Flip cards back
    final updatedCards = _gameState.cards.map((c) {
      if (c.id == card1.id || c.id == card2.id) {
        return c.copyWith(isFlipped: false);
      }
      return c;
    }).toList();

    _gameState = _gameState.copyWith(
      cards: updatedCards,
      comboCount: 0, // Reset combo on mismatch
      moves: _gameState.moves + 1,
      flippedCards: [],
    );
    _isCheckingPair = false;

    onGameStateChanged?.call(_gameState);
  }

  /// Start game timer
  void _startGameTimer() {
    _gameTimer?.cancel();
    _gameTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_gameState.timeRemaining <= 0) {
        _endGame(victory: false);
        timer.cancel();
        return;
      }

      _gameState = _gameState.copyWith(
        timeRemaining: _gameState.timeRemaining - 1,
      );

      onGameStateChanged?.call(_gameState);
      onTimeUpdate?.call(_gameState.timeRemaining);

      // Critical warning at 10 seconds
      if (_gameState.timeRemaining == 10) {
        // Trigger ticking sound
      }
    });
  }

  /// End the game
  void _endGame({required bool victory}) {
    _gameTimer?.cancel();

    // Calculate coins earned
    int coinsEarned = 0;

    if (victory) {
      coinsEarned = _gameState.difficulty.getCompletionCoins();

      // Time bonus
      if (_gameState.timeRemaining > 0) {
        coinsEarned +=
            (GameConstants.timeBonusCoins * (_gameState.timeRemaining / 10))
                .toInt();
      }
    }

    _gameState = _gameState.copyWith(
      isGameActive: false,
      isGameOver: true,
      isVictory: victory,
      coinsEarned: coinsEarned,
    );

    onGameStateChanged?.call(_gameState);
  }

  /// Get current game state
  GameState getGameState() => _gameState;

  /// Pause game
  void pauseGame() {
    _gameTimer?.cancel();
    _gameState = _gameState.copyWith(isGameActive: false);
  }

  /// Resume game
  void resumeGame() {
    _gameState = _gameState.copyWith(isGameActive: true);
    _startGameTimer();
  }

  /// Quit game
  void quitGame() {
    _gameTimer?.cancel();
    _isCheckingPair = false;
    _gameState = _gameState.copyWith(
      isGameActive: false,
      isGameOver: true,
      isVictory: false,
    );
  }

  /// Cleanup
  void dispose() {
    _gameTimer?.cancel();
  }
}
