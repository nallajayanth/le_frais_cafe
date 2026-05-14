import 'package:flutter/material.dart';
import 'package:le_frais_mobile_application/game/food_memory_challenge/services/game_service.dart';
import 'package:le_frais_mobile_application/game/food_memory_challenge/services/game_progress_service.dart';
import 'package:le_frais_mobile_application/game/food_memory_challenge/services/reward_service.dart';
import 'package:le_frais_mobile_application/game/food_memory_challenge/models/difficulty_level.dart';
import 'package:le_frais_mobile_application/game/food_memory_challenge/models/game_state.dart';
import 'package:le_frais_mobile_application/game/food_memory_challenge/models/player_stats.dart';
import 'package:le_frais_mobile_application/game/food_memory_challenge/audio/audio_manager.dart';

/// Controller for the Food Memory Challenge game
class GameController extends ChangeNotifier {
  final GameService _gameService = GameService();
  final GameProgressService _progressService = GameProgressService();
  final RewardService _rewardService = RewardService();
  final AudioManager _audioManager = AudioManager();

  GameState? _currentGameState;
  bool _isInitialized = false;

  // Getters
  GameState? get currentGameState => _currentGameState;
  bool get isInitialized => _isInitialized;
  int get remainingDailyChances => -1;

  /// Initialize the controller
  Future<void> initialize() async {
    if (_isInitialized) return;

    await _progressService.initialize();
    await _rewardService.initialize();
    await _audioManager.initialize();

    _isInitialized = true;

    // Setup callbacks
    _gameService.onGameStateChanged = (state) {
      _currentGameState = state;
      notifyListeners();
    };

    _gameService.onTimeUpdate = (timeRemaining) {
      notifyListeners();
    };

    _gameService.onComboTriggered = () {
      _audioManager.playCombo();
      // Haptic feedback
    };

    notifyListeners();
  }

  /// Start a new game
  Future<void> startGame(DifficultyLevel difficulty) async {
    _currentGameState = _gameService.initializeGame(difficulty);
    _audioManager.playBackgroundMusic();

    notifyListeners();
  }

  /// Tap a card
  Future<void> tapCard(String cardId) async {
    if (_currentGameState == null || !_currentGameState!.isGameActive) {
      return;
    }

    _audioManager.playCardFlip();
    await _gameService.tapCard(cardId);
  }

  /// End current game
  void endGame() {
    if (_currentGameState != null) {
      _gameService.quitGame();
      _audioManager.stopBackgroundMusic();
    }
  }

  /// Save game result
  Future<void> saveGameResult() async {
    if (_currentGameState == null) return;

    await _progressService.recordGameResult(
      isWin: _currentGameState!.isVictory,
      score: _currentGameState!.score,
      coins: _currentGameState!.coinsEarned,
      difficulty: _currentGameState!.difficulty,
      timeElapsed: _currentGameState!.getElapsedTime(),
    );

    await _rewardService.recordCoinsEarned(_currentGameState!.coinsEarned);
    await _rewardService.addCoins(_currentGameState!.coinsEarned);

    if (_currentGameState!.isVictory) {
      _audioManager.playVictory();
    } else {
      _audioManager.playGameOver();
    }
  }

  /// Get player coins
  Future<int> getPlayerCoins() async {
    return await _rewardService.getCoins();
  }

  /// Get player stats
  Future<PlayerStats> getPlayerStats() async {
    return await _progressService.getPlayerStats();
  }

  /// Redeem a reward
  Future<bool> redeemReward(dynamic reward) async {
    return await _rewardService.redeemReward(reward);
  }

  /// Toggle music
  void toggleMusic(bool enabled) {
    _audioManager.toggleMusic(enabled);
  }

  /// Toggle SFX
  void toggleSfx(bool enabled) {
    _audioManager.toggleSfx(enabled);
  }

  /// Cleanup
  @override
  void dispose() {
    _gameService.dispose();
    _audioManager.dispose();
    super.dispose();
  }
}
