// Game Models - Core data structures for the Catch The Food game

enum FoodType {
  // Good items
  burger,
  pizza,
  fries,
  donut,
  iceCream,
  coldCoffee,
  // Bad items
  burntBurger,
  rottenTomato,
  bomb,
  chiliTrap,
  // Special items
  goldenBurger,
  rainbowPizza,
}

class FoodItemData {
  final FoodType type;
  final bool isGood;
  final int baseScore;
  final String emoji;
  final bool isSpecial;
  final double spawnProbability;

  const FoodItemData({
    required this.type,
    required this.isGood,
    required this.baseScore,
    required this.emoji,
    required this.isSpecial,
    required this.spawnProbability,
  });

  static const Map<FoodType, FoodItemData> foodDatabase = {
    // Good items
    FoodType.burger: FoodItemData(
      type: FoodType.burger,
      isGood: true,
      baseScore: 10,
      emoji: '🍔',
      isSpecial: false,
      spawnProbability: 0.15,
    ),
    FoodType.pizza: FoodItemData(
      type: FoodType.pizza,
      isGood: true,
      baseScore: 15,
      emoji: '🍕',
      isSpecial: false,
      spawnProbability: 0.12,
    ),
    FoodType.fries: FoodItemData(
      type: FoodType.fries,
      isGood: true,
      baseScore: 8,
      emoji: '🍟',
      isSpecial: false,
      spawnProbability: 0.14,
    ),
    FoodType.donut: FoodItemData(
      type: FoodType.donut,
      isGood: true,
      baseScore: 12,
      emoji: '🍩',
      isSpecial: false,
      spawnProbability: 0.13,
    ),
    FoodType.iceCream: FoodItemData(
      type: FoodType.iceCream,
      isGood: true,
      baseScore: 11,
      emoji: '🍦',
      isSpecial: false,
      spawnProbability: 0.12,
    ),
    FoodType.coldCoffee: FoodItemData(
      type: FoodType.coldCoffee,
      isGood: true,
      baseScore: 9,
      emoji: '☕',
      isSpecial: false,
      spawnProbability: 0.11,
    ),
    // Bad items
    FoodType.burntBurger: FoodItemData(
      type: FoodType.burntBurger,
      isGood: false,
      baseScore: -20,
      emoji: '🍔',
      isSpecial: false,
      spawnProbability: 0.08,
    ),
    FoodType.rottenTomato: FoodItemData(
      type: FoodType.rottenTomato,
      isGood: false,
      baseScore: -15,
      emoji: '🍅',
      isSpecial: false,
      spawnProbability: 0.07,
    ),
    FoodType.bomb: FoodItemData(
      type: FoodType.bomb,
      isGood: false,
      baseScore: -30,
      emoji: '💣',
      isSpecial: false,
      spawnProbability: 0.05,
    ),
    FoodType.chiliTrap: FoodItemData(
      type: FoodType.chiliTrap,
      isGood: false,
      baseScore: -25,
      emoji: '🌶️',
      isSpecial: false,
      spawnProbability: 0.06,
    ),
    // Special items (rare)
    FoodType.goldenBurger: FoodItemData(
      type: FoodType.goldenBurger,
      isGood: true,
      baseScore: 50,
      emoji: '✨🍔✨',
      isSpecial: true,
      spawnProbability: 0.02,
    ),
    FoodType.rainbowPizza: FoodItemData(
      type: FoodType.rainbowPizza,
      isGood: true,
      baseScore: 75,
      emoji: '🌈🍕🌈',
      isSpecial: true,
      spawnProbability: 0.015,
    ),
  };

  static FoodItemData getFood(FoodType type) {
    return foodDatabase[type]!;
  }
}

class GameState {
  int score;
  int coins;
  int comboCount;
  int maxCombo;
  int timeRemaining; // in seconds
  bool isGameActive;
  bool isPaused;
  List<int> recentCatches; // Track recent catches for combo
  double difficulty; // 1.0 = base, increases over time

  GameState({
    this.score = 0,
    this.coins = 0,
    this.comboCount = 0,
    this.maxCombo = 0,
    this.timeRemaining = 60,
    this.isGameActive = false,
    this.isPaused = false,
    List<int>? recentCatches,
    this.difficulty = 1.0,
  }) : recentCatches = recentCatches ?? [];

  // Calculate score with combo multiplier
  int calculateScore(int baseScore) {
    double multiplier = 1.0;
    if (comboCount > 2) {
      multiplier = 1.0 + (comboCount - 2) * 0.1; // +10% per combo after 2
    }
    return (baseScore * multiplier).toInt();
  }

  // Difficulty scales with score
  void updateDifficulty() {
    difficulty = 1.0 + (score / 500).clamp(0.0, 2.0); // Max 3x difficulty
  }
}

class RewardData {
  final int scoreThreshold;
  final String rewardType; // 'coins', 'discount', 'mystery'
  final String description;
  final int rewardValue;

  const RewardData({
    required this.scoreThreshold,
    required this.rewardType,
    required this.description,
    required this.rewardValue,
  });

  static const List<RewardData> rewardTiers = [
    RewardData(
      scoreThreshold: 50,
      rewardType: 'coins',
      description: '5 Coins',
      rewardValue: 5,
    ),
    RewardData(
      scoreThreshold: 100,
      rewardType: 'discount',
      description: 'Free Fries',
      rewardValue: 1,
    ),
    RewardData(
      scoreThreshold: 150,
      rewardType: 'discount',
      description: '10% OFF',
      rewardValue: 10,
    ),
    RewardData(
      scoreThreshold: 200,
      rewardType: 'mystery',
      description: 'Mystery Reward',
      rewardValue: 1,
    ),
    RewardData(
      scoreThreshold: 300,
      rewardType: 'jackpot',
      description: 'Jackpot Spin',
      rewardValue: 1,
    ),
  ];

  static RewardData? getReward(int score) {
    for (int i = rewardTiers.length - 1; i >= 0; i--) {
      if (score >= rewardTiers[i].scoreThreshold) {
        return rewardTiers[i];
      }
    }
    return null;
  }
}

class GameResult {
  final int finalScore;
  final int totalCoins;
  final int bestCombo;
  final RewardData? reward;
  final DateTime playedAt;

  const GameResult({
    required this.finalScore,
    required this.totalCoins,
    required this.bestCombo,
    required this.reward,
    required this.playedAt,
  });
}
