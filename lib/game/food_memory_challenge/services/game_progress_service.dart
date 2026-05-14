import 'package:shared_preferences/shared_preferences.dart';
import 'package:le_frais_mobile_application/game/food_memory_challenge/models/player_stats.dart';
import 'package:le_frais_mobile_application/game/food_memory_challenge/models/difficulty_level.dart';
import 'dart:convert';

/// Service to manage game progress and player statistics
class GameProgressService {
  static final GameProgressService _instance = GameProgressService._internal();
  late SharedPreferences _prefs;

  factory GameProgressService() {
    return _instance;
  }

  GameProgressService._internal();

  /// Initialize service
  Future<void> initialize() async {
    _prefs = await SharedPreferences.getInstance();
  }

  /// Get player stats
  Future<PlayerStats> getPlayerStats() async {
    final statsJson = _prefs.getString('player_stats');
    if (statsJson == null) {
      return const PlayerStats();
    }

    try {
      final decoded = jsonDecode(statsJson) as Map<String, dynamic>;
      return _playerStatsFromJson(decoded);
    } catch (e) {
      print('Error loading player stats: $e');
      return const PlayerStats();
    }
  }

  /// Save player stats
  Future<void> savePlayerStats(PlayerStats stats) async {
    try {
      final json = _playerStatsToJson(stats);
      await _prefs.setString('player_stats', jsonEncode(json));
    } catch (e) {
      print('Error saving player stats: $e');
    }
  }

  /// Record a game result
  Future<void> recordGameResult({
    required bool isWin,
    required int score,
    required int coins,
    required DifficultyLevel difficulty,
    required int timeElapsed,
  }) async {
    final stats = await getPlayerStats();

    var newStats = stats.copyWith(
      totalGamesPlayed: stats.totalGamesPlayed + 1,
      totalGamesWon: isWin ? stats.totalGamesWon + 1 : stats.totalGamesWon,
      totalCoinsEarned: stats.totalCoinsEarned + coins,
      currentStreak: isWin ? stats.currentStreak + 1 : 0,
    );

    // Update high scores
    final difficultyKey = difficulty.level;
    final currentHighScore = stats.getHighScoreForDifficulty(difficultyKey);
    if (score > currentHighScore) {
      final updatedScores = Map<int, int>.from(stats.difficultyHighScores);
      updatedScores[difficultyKey] = score;
      newStats = newStats.copyWith(difficultyHighScores: updatedScores);
    }

    // Update best time
    if (isWin &&
        (stats.bestTimeInSeconds == 0 ||
            timeElapsed < stats.bestTimeInSeconds)) {
      newStats = newStats.copyWith(bestTimeInSeconds: timeElapsed);
    }

    // Update highest score
    if (score > newStats.highestScore) {
      newStats = newStats.copyWith(highestScore: score);
    }

    // Unlock next difficulty if completed
    if (isWin && difficulty != DifficultyLevel.hard) {
      final nextDifficulty = difficulty.level + 1;
      final updatedUnlocked = Map<int, bool>.from(stats.unlockedDifficulties);
      updatedUnlocked[nextDifficulty] = true;
      newStats = newStats.copyWith(unlockedDifficulties: updatedUnlocked);
    }

    await savePlayerStats(newStats);
  }

  /// Update player coins
  Future<void> updatePlayerCoins(int coinsDelta) async {
    final stats = await getPlayerStats();
    final newCoins = (stats.totalCoinsEarned + coinsDelta).clamp(0, 999999);
    await savePlayerStats(stats.copyWith(totalCoinsEarned: newCoins));
  }

  /// Get current player coins
  Future<int> getPlayerCoins() async {
    final stats = await getPlayerStats();
    return stats.totalCoinsEarned;
  }

  /// Clear all progress (for testing)
  Future<void> clearAllProgress() async {
    await _prefs.remove('player_stats');
  }

  /// Convert PlayerStats to JSON
  Map<String, dynamic> _playerStatsToJson(PlayerStats stats) {
    return {
      'totalGamesPlayed': stats.totalGamesPlayed,
      'totalGamesWon': stats.totalGamesWon,
      'totalCoinsEarned': stats.totalCoinsEarned,
      'highestScore': stats.highestScore,
      'bestTimeInSeconds': stats.bestTimeInSeconds,
      'currentStreak': stats.currentStreak,
      'difficultyHighScores': stats.difficultyHighScores,
      'unlockedDifficulties': stats.unlockedDifficulties,
      'totalMatches': stats.totalMatches,
      'totalCombos': stats.totalCombos,
      'goldenCardsFound': stats.goldenCardsFound,
      'rainbowCardsFound': stats.rainbowCardsFound,
    };
  }

  /// Convert JSON to PlayerStats
  PlayerStats _playerStatsFromJson(Map<String, dynamic> json) {
    return PlayerStats(
      totalGamesPlayed: json['totalGamesPlayed'] ?? 0,
      totalGamesWon: json['totalGamesWon'] ?? 0,
      totalCoinsEarned: json['totalCoinsEarned'] ?? 0,
      highestScore: json['highestScore'] ?? 0,
      bestTimeInSeconds: json['bestTimeInSeconds'] ?? 0,
      currentStreak: json['currentStreak'] ?? 0,
      difficultyHighScores: Map<int, int>.from(
        json['difficultyHighScores'] ?? {},
      ),
      unlockedDifficulties: Map<int, bool>.from(
        json['unlockedDifficulties'] ?? {1: true},
      ),
      totalMatches: json['totalMatches'] ?? 0,
      totalCombos: json['totalCombos'] ?? 0,
      goldenCardsFound: json['goldenCardsFound'] ?? 0,
      rainbowCardsFound: json['rainbowCardsFound'] ?? 0,
    );
  }
}
