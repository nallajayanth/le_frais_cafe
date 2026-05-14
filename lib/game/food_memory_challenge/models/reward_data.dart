/// Reward data structure
class RewardData {
  final int coins;
  final String title;
  final String description;
  final String? icon; // Emoji or icon path
  final bool isSpecial;
  final DateTime earnedAt;

  const RewardData({
    required this.coins,
    required this.title,
    required this.description,
    this.icon,
    this.isSpecial = false,
    required this.earnedAt,
  });

  /// Create a copy with modified fields
  RewardData copyWith({
    int? coins,
    String? title,
    String? description,
    String? icon,
    bool? isSpecial,
    DateTime? earnedAt,
  }) {
    return RewardData(
      coins: coins ?? this.coins,
      title: title ?? this.title,
      description: description ?? this.description,
      icon: icon ?? this.icon,
      isSpecial: isSpecial ?? this.isSpecial,
      earnedAt: earnedAt ?? this.earnedAt,
    );
  }
}

/// Available rewards and coupons
class AvailableReward {
  final String id;
  final String title;
  final String description;
  final int coinsCost;
  final String? couponCode;
  final String category; // 'discount', 'free_item', 'special_offer'

  const AvailableReward({
    required this.id,
    required this.title,
    required this.description,
    required this.coinsCost,
    this.couponCode,
    required this.category,
  });
}

/// Repository of available rewards
class RewardRepository {
  static const List<AvailableReward> availableRewards = [
    AvailableReward(
      id: 'free_fries',
      title: '🍟 Free Fries',
      description: 'Get a free order of fries',
      coinsCost: 50,
      couponCode: 'FREEFRIES',
      category: 'free_item',
    ),
    AvailableReward(
      id: 'free_drink',
      title: '🥤 Free Drink',
      description: 'Get a free drink of your choice',
      coinsCost: 40,
      couponCode: 'FREEDRINK',
      category: 'free_item',
    ),
    AvailableReward(
      id: 'discount_10',
      title: '💰 10% Discount',
      description: 'Get 10% off your next order',
      coinsCost: 60,
      couponCode: 'SAVE10',
      category: 'discount',
    ),
    AvailableReward(
      id: 'discount_20',
      title: '💰 20% Discount',
      description: 'Get 20% off your next order',
      coinsCost: 100,
      couponCode: 'SAVE20',
      category: 'discount',
    ),
    AvailableReward(
      id: 'pizza',
      title: '🍕 Free Pizza',
      description: 'Get a free pizza of your choice',
      coinsCost: 150,
      couponCode: 'FREEPIZZA',
      category: 'free_item',
    ),
    AvailableReward(
      id: 'combo_meal',
      title: '🍔 Combo Meal',
      description: 'Get a free combo meal (burger + fries + drink)',
      coinsCost: 200,
      couponCode: 'COMBOMEAL',
      category: 'special_offer',
    ),
  ];

  /// Get reward by ID
  static AvailableReward? getRewardById(String id) {
    try {
      return availableRewards.firstWhere((r) => r.id == id);
    } catch (e) {
      return null;
    }
  }

  /// Get rewards by category
  static List<AvailableReward> getRewardsByCategory(String category) {
    return availableRewards.where((r) => r.category == category).toList();
  }

  /// Get all affordable rewards (costs less than or equal to coins)
  static List<AvailableReward> getAffordableRewards(int coins) {
    return availableRewards.where((r) => r.coinsCost <= coins).toList();
  }
}
