// Game Configuration and Constants

class GameConfig {
  // Game timing
  static const int gameDuration = 60; // seconds
  static const double gameTimeStep = 0.016; // ~60 FPS

  // Screen dimensions
  static const double gameWidth = 360;
  static const double gameHeight = 800;

  // Player (tray/character)
  static const double playerWidth = 80;
  static const double playerHeight = 60;
  static const double playerSpeed = 400; // pixels per second

  // Food items
  static const double foodSize = 50;
  static const double foodSpeedBase = 300; // pixels per second
  static const double maxFoodSpeed = 800;

  // Spawn settings
  static const double spawnRate = 2; // items per second (base)
  static const double maxSpawnRate = 8;

  // Physics
  static const double gravity = 0;

  // Combo settings
  static const int comboTimeout =
      2000; // milliseconds - time between catches to maintain combo
  static const int comboThreshold = 3; // minimum catches for combo activation

  // Particle settings
  static const int maxParticles = 100;
  static const int maxComboParticles = 50;

  // Score multipliers
  static const double comboPunishment = 2.0;

  // Difficulty scaling
  static const double difficultyIncreaseRate = 0.01; // per second
}

class ColorPalette {
  // Restaurant brand colors
  static const int primaryOrange = 0xFFFF9800;
  static const int accentYellow = 0xFFFFEB3B;
  static const int darkBackground = 0xFF1a1a1a;
  static const int cardBackground = 0xFF2a2a2a;
  static const int textPrimary = 0xFFFFFFFF;
  static const int textSecondary = 0xFFB0B0B0;
  static const int goodItemGreen = 0xFF4CAF50;
  static const int badItemRed = 0xFFF44336;
  static const int specialGold = 0xFFFFD700;
  static const int specialRainbow1 = 0xFFFF6B6B;
  static const int specialRainbow2 = 0xFF4ECDC4;

  // Gradients for special effects
  static const List<int> rainbowGradient = [
    0xFFFF0000,
    0xFFFFFF00,
    0xFF00FF00,
    0xFF00FFFF,
    0xFF0000FF,
    0xFFFF00FF,
  ];
}

class AssetPaths {
  // Audio paths
  static const String audioDirectory = 'assets/game/audio/';
  static const String catchGoodSound = '${audioDirectory}catch_good.wav';
  static const String catchBadSound = '${audioDirectory}catch_bad.wav';
  static const String comboSound = '${audioDirectory}combo.wav';
  static const String specialItemSound = '${audioDirectory}special.wav';
  static const String gameOverSound = '${audioDirectory}game_over.wav';
  static const String uiSelectSound = '${audioDirectory}ui_select.wav';

  // Lottie animations
  static const String lottieDirectory = 'assets/game/animations/';
  static const String confettiAnimation = '${lottieDirectory}confetti.json';
  static const String sparkleAnimation = '${lottieDirectory}sparkle.json';
  static const String comboAnimatio = '${lottieDirectory}combo.json';
}

class GameTimings {
  // Screen transitions
  static const Duration countdownDuration = Duration(milliseconds: 3500);
  static const Duration gameOverDelay = Duration(milliseconds: 1000);
  static const Duration rewardPopupDuration = Duration(milliseconds: 2000);

  // Animation timings
  static const Duration catchAnimationDuration = Duration(milliseconds: 400);
  static const Duration comboAnimationDuration = Duration(milliseconds: 600);
  static const Duration specialItemGlowDuration = Duration(milliseconds: 500);
}

// Difficulty levels (for future features)
enum DifficultyLevel { easy, normal, hard, extreme }

extension DifficultyLevelExtension on DifficultyLevel {
  double getSpawnRateMultiplier() {
    switch (this) {
      case DifficultyLevel.easy:
        return 0.8;
      case DifficultyLevel.normal:
        return 1.0;
      case DifficultyLevel.hard:
        return 1.5;
      case DifficultyLevel.extreme:
        return 2.0;
    }
  }

  double getSpeedMultiplier() {
    switch (this) {
      case DifficultyLevel.easy:
        return 0.7;
      case DifficultyLevel.normal:
        return 1.0;
      case DifficultyLevel.hard:
        return 1.4;
      case DifficultyLevel.extreme:
        return 1.8;
    }
  }
}
