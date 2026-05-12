// Game Rewards and Persistence Service
import 'package:shared_preferences/shared_preferences.dart';
import '../models/game_models.dart';

class RewardsService {
  static final RewardsService _instance = RewardsService._internal();

  factory RewardsService() {
    return _instance;
  }

  RewardsService._internal();

  late SharedPreferences _prefs;
  static const String totalCoinsKey = 'total_coins';
  static const String dailyChancesKey = 'daily_chances_left';
  static const String lastPlayDateKey = 'last_play_date';
  static const String gameHistoryKey = 'game_history';
  static const String bestScoreKey = 'best_score';
  static const String totalPlayTimeKey = 'total_play_time';
  static const int dailyChancesLimit = 5;

  Future<void> initialize() async {
    _prefs = await SharedPreferences.getInstance();
    _resetDailyChancesIfNeeded();
  }

  // Get total coins
  int getTotalCoins() {
    return _prefs.getInt(totalCoinsKey) ?? 0;
  }

  // Add coins from game result
  Future<void> addCoins(int coins) async {
    final current = getTotalCoins();
    await _prefs.setInt(totalCoinsKey, current + coins);
  }

  // Get daily chances left
  int getDailyChancesLeft() {
    return _prefs.getInt(dailyChancesKey) ?? dailyChancesLimit;
  }

  // Use one daily chance
  Future<bool> useOneChance() async {
    final chancesLeft = getDailyChancesLeft();
    if (chancesLeft > 0) {
      await _prefs.setInt(dailyChancesKey, chancesLeft - 1);
      await _prefs.setString(lastPlayDateKey, DateTime.now().toString());
      return true;
    }
    return false;
  }

  // Reset daily chances if needed
  Future<void> _resetDailyChancesIfNeeded() async {
    final lastPlayDate = _prefs.getString(lastPlayDateKey);
    if (lastPlayDate == null) {
      await _prefs.setInt(dailyChancesKey, dailyChancesLimit);
      return;
    }

    final last = DateTime.parse(lastPlayDate);
    final now = DateTime.now();
    final difference = now.difference(last).inHours;

    if (difference >= 24) {
      await _prefs.setInt(dailyChancesKey, dailyChancesLimit);
    }
  }

  // Save game result
  Future<void> saveGameResult(GameResult result) async {
    // Update best score
    final bestScore = _prefs.getInt(bestScoreKey) ?? 0;
    if (result.finalScore > bestScore) {
      await _prefs.setInt(bestScoreKey, result.finalScore);
    }

    // Add coins
    await addCoins(result.totalCoins);

    // Store game history (keep last 10 games)
    final history = _prefs.getStringList(gameHistoryKey) ?? [];
    final gameData =
        '${result.finalScore},${result.totalCoins},${result.bestCombo},${result.playedAt.toIso8601String()}';
    history.insert(0, gameData);
    if (history.length > 10) {
      history.removeLast();
    }
    await _prefs.setStringList(gameHistoryKey, history);
  }

  // Get best score
  int getBestScore() {
    return _prefs.getInt(bestScoreKey) ?? 0;
  }

  // Get game history
  List<GameHistoryEntry> getGameHistory() {
    final history = _prefs.getStringList(gameHistoryKey) ?? [];
    return history
        .map((entry) {
          final parts = entry.split(',');
          if (parts.length >= 4) {
            return GameHistoryEntry(
              score: int.parse(parts[0]),
              coinsEarned: int.parse(parts[1]),
              bestCombo: int.parse(parts[2]),
              playedAt: DateTime.parse(parts[3]),
            );
          }
          return null;
        })
        .whereType<GameHistoryEntry>()
        .toList();
  }

  // Get total play time (cumulative)
  int getTotalPlayTime() {
    return _prefs.getInt(totalPlayTimeKey) ?? 0;
  }

  // Add play time
  Future<void> addPlayTime(int seconds) async {
    final current = getTotalPlayTime();
    await _prefs.setInt(totalPlayTimeKey, current + seconds);
  }

  // Check if player can redeem a reward
  bool canRedeemReward(RewardData reward) {
    // In a real app, this would check database/backend
    // For now, just validate the reward exists
    return RewardData.rewardTiers.contains(reward);
  }

  // Redeem a reward (deduct coins or mark as used)
  Future<bool> redeemReward(RewardData reward) async {
    // In production, this would call backend
    // For now, we'll store it locally
    try {
      final redeemedRewards = _prefs.getStringList('redeemed_rewards') ?? [];
      redeemedRewards.add(
        '${reward.description},${DateTime.now().toIso8601String()}',
      );
      await _prefs.setStringList('redeemed_rewards', redeemedRewards);
      return true;
    } catch (e) {
      print('Error redeeming reward: $e');
      return false;
    }
  }

  // Clear all data (for testing)
  Future<void> clearAllData() async {
    await _prefs.clear();
  }
}

class GameHistoryEntry {
  final int score;
  final int coinsEarned;
  final int bestCombo;
  final DateTime playedAt;

  GameHistoryEntry({
    required this.score,
    required this.coinsEarned,
    required this.bestCombo,
    required this.playedAt,
  });
}
