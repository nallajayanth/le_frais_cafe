/// Game constants for Food Memory Challenge
class GameConstants {
  // Game modes
  static const int easyPairs = 4;
  static const int mediumPairs = 8;
  static const int hardPairs = 12;

  // Timers (in seconds)
  static const int easyTimer = 60;
  static const int mediumTimer = 45;
  static const int hardTimer = 30;

  // Scoring
  static const int baseMatchScore = 10;
  static const int comboMultiplier = 1;
  static const int timeBonusThreshold = 30; // seconds

  // Coins
  static const int easyCompletionCoins = 10;
  static const int mediumCompletionCoins = 25;
  static const int hardCompletionCoins = 50;

  static const int timeBonusCoins = 20;
  static const int goldenCardBonus = 50;
  static const int rainbowCardBonus = 100;

  // Combo system
  static const int comboMultiplierX2 = 2;
  static const int comboMultiplierX3 = 3;
  static const int comboTriggerCount = 3;
  static const int comboTimeWindow = 3000; // milliseconds

  // Daily limits
  static const int maxGamesPerDay = 3;
  static const int gameResetHour = 0; // Midnight UTC

  // Special cards probability
  static const double goldenCardProbability = 0.10; // 10%
  static const double rainbowCardProbability = 0.02; // 2%

  // Animations
  static const int cardFlipDuration = 300; // milliseconds
  static const int matchAnimationDuration = 400;
  static const int wrongMatchDuration = 500;
  static const int comboAnimationDuration = 600;

  // UI
  static const double cardBorderRadius = 16.0;
  static const double buttonBorderRadius = 20.0;
  static const double shadowBlur = 20.0;
  static const double glowIntensity = 1.5;

  // Particle effects
  static const int particleCount = 50;
  static const int confettiParticles = 30;
}
