import 'package:shared_preferences/shared_preferences.dart';
import 'package:le_frais_mobile_application/game/food_memory_challenge/models/reward_data.dart';
import 'dart:convert';

/// Service to manage rewards and coins
class RewardService {
  static final RewardService _instance = RewardService._internal();
  late SharedPreferences _prefs;

  factory RewardService() {
    return _instance;
  }

  RewardService._internal();

  /// Initialize service
  Future<void> initialize() async {
    _prefs = await SharedPreferences.getInstance();
  }

  /// Get player's current coins
  Future<int> getCoins() async {
    return _prefs.getInt('player_coins') ?? 0;
  }

  /// Add coins
  Future<void> addCoins(int amount) async {
    final current = await getCoins();
    await _prefs.setInt('player_coins', current + amount);
  }

  /// Spend coins
  Future<bool> spendCoins(int amount) async {
    final current = await getCoins();
    if (current >= amount) {
      await _prefs.setInt('player_coins', current - amount);
      return true;
    }
    return false;
  }

  /// Get earned rewards history
  Future<List<RewardData>> getRewardsHistory() async {
    final historyJson = _prefs.getStringList('rewards_history') ?? [];
    return historyJson.map((json) {
      final decoded = jsonDecode(json) as Map<String, dynamic>;
      return RewardData(
        coins: decoded['coins'] as int,
        title: decoded['title'] as String,
        description: decoded['description'] as String,
        icon: decoded['icon'] as String?,
        isSpecial: decoded['isSpecial'] as bool? ?? false,
        earnedAt: DateTime.parse(decoded['earnedAt'] as String),
      );
    }).toList();
  }

  /// Record a reward earned
  Future<void> recordReward(RewardData reward) async {
    final history = await getRewardsHistory();
    history.add(reward);

    // Keep only last 100 rewards
    if (history.length > 100) {
      history.removeRange(0, history.length - 100);
    }

    final encoded = history.map((r) {
      return jsonEncode({
        'coins': r.coins,
        'title': r.title,
        'description': r.description,
        'icon': r.icon,
        'isSpecial': r.isSpecial,
        'earnedAt': r.earnedAt.toIso8601String(),
      });
    }).toList();

    await _prefs.setStringList('rewards_history', encoded);
  }

  /// Redeem a reward
  Future<bool> redeemReward(AvailableReward reward) async {
    if (await spendCoins(reward.coinsCost)) {
      await recordReward(
        RewardData(
          coins: reward.coinsCost,
          title: reward.title,
          description: reward.description,
          icon: reward.title.split(' ')[0], // Get emoji
          isSpecial: reward.category == 'special_offer',
          earnedAt: DateTime.now(),
        ),
      );
      return true;
    }
    return false;
  }

  /// Get redeemed coupons
  Future<List<String>> getRedeemedCoupons() async {
    return _prefs.getStringList('redeemed_coupons') ?? [];
  }

  /// Add redeemed coupon
  Future<void> addRedeemedCoupon(String couponCode) async {
    final coupons = await getRedeemedCoupons();
    if (!coupons.contains(couponCode)) {
      coupons.add(couponCode);
      await _prefs.setStringList('redeemed_coupons', coupons);
    }
  }

  /// Get total coins earned ever
  Future<int> getTotalCoinsEarned() async {
    return _prefs.getInt('total_coins_earned') ?? 0;
  }

  /// Record coins earned
  Future<void> recordCoinsEarned(int amount) async {
    final total = await getTotalCoinsEarned();
    await _prefs.setInt('total_coins_earned', total + amount);
  }

  /// Clear reward history (for testing)
  Future<void> clearHistory() async {
    await _prefs.remove('rewards_history');
  }
}
