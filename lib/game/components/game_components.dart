// Game Components - Food items and Player character using Flame
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'dart:math' as math;
import '../models/game_models.dart';
import '../config/game_config.dart';

// Base Food Item Component
class FoodItem extends PositionComponent {
  final FoodType foodType;
  final FoodItemData foodData;
  late double fallSpeed;
  late double rotationSpeed;
  bool caught = false;
  double glowIntensity = 0;
  final VoidCallback onCaught;
  late Rect trayBounds;

  FoodItem({
    required this.foodType,
    required Vector2 position,
    required this.trayBounds,
    required this.onCaught,
  }) : foodData = FoodItemData.getFood(foodType),
       super(
         position: position,
         size: Vector2(GameConfig.foodSize, GameConfig.foodSize),
         anchor: Anchor.center,
       );

  @override
  Future<void> onLoad() async {
    super.onLoad();
    // Randomize fall speed based on difficulty
    final game = parent as CatchTheFoodGame?;
    final baseSpeed =
        GameConfig.foodSpeedBase * (game?.gameState.difficulty ?? 1.0);
    fallSpeed = baseSpeed + math.Random().nextDouble() * 100;

    // Add slight rotation
    rotationSpeed = (math.Random().nextDouble() - 0.5) * 2; // -1 to 1 rad/s

    // Special items glow
    if (foodData.isSpecial) {
      glowIntensity = 1.0;
    }
  }

  @override
  void update(double dt) {
    super.update(dt);

    if (caught) return;

    // Move downward
    position.y += fallSpeed * dt;

    // Rotate
    angle += rotationSpeed * dt;

    // Check if off-screen
    if (position.y > GameConfig.gameHeight + 100) {
      removeFromParent();
      // Penalty for missing good items
      if (foodData.isGood) {
        (parent as CatchTheFoodGame?)?.onItemMissed(this);
      }
    }

    // Pulse glow for special items
    if (foodData.isSpecial && glowIntensity > 0) {
      glowIntensity =
          0.7 +
          0.3 *
              math.sin(
                (DateTime.now().millisecondsSinceEpoch / 500).toDouble() %
                    (2 * math.pi),
              );
    }

    // Check collision with tray
    checkCollision();
  }

  void checkCollision() {
    if (caught) return;

    // Simple AABB collision
    final foodRect = Rect.fromLTWH(
      position.x - size.x / 2,
      position.y - size.y / 2,
      size.x,
      size.y,
    );

    if (foodRect.overlaps(trayBounds)) {
      caught = true;
      onCaught();
      _playCatchEffect();
      removeFromParent();
    }
  }

  void _playCatchEffect() {
    // This will be enhanced with particles and animations
    if (foodData.isSpecial) {
      _playSpecialEffect();
    }
  }

  void _playSpecialEffect() {
    // Visual and audio effects for special items
    // Golden Burger: slow motion, sparkles
    // Rainbow Pizza: confetti, rainbow flash
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    // Draw emoji food
    final textPainter = TextPainter(
      text: TextSpan(
        text: foodData.emoji,
        style: const TextStyle(fontSize: 40),
      ),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    textPainter.paint(
      canvas,
      Offset(-textPainter.width / 2, -textPainter.height / 2),
    );

    // Draw glow effect for special items
    if (foodData.isSpecial && glowIntensity > 0) {
      final paint = Paint()
        ..color = const Color(
          0xFFFFD700,
        ).withAlpha((glowIntensity * 100).toInt())
        ..maskFilter = const MaskFilter.blur(BlurStyle.outer, 10);

      canvas.drawCircle(Offset.zero, size.x / 2 + 5, paint);
    }
  }
}

// Player tray component
class PlayerTray extends PositionComponent {
  late Vector2 velocity;
  static const String emoji = '🍽️';
  bool isMovingLeft = false;
  bool isMovingRight = false;

  PlayerTray({required Vector2 position})
    : super(
        position: position,
        size: Vector2(GameConfig.playerWidth, GameConfig.playerHeight),
        anchor: Anchor.center,
      );

  @override
  Future<void> onLoad() async {
    super.onLoad();
    velocity = Vector2.zero();
  }

  @override
  void update(double dt) {
    super.update(dt);

    // Update velocity based on input
    velocity.x = 0;
    if (isMovingLeft && position.x > GameConfig.playerWidth / 2) {
      velocity.x = -GameConfig.playerSpeed;
    } else if (isMovingRight &&
        position.x < GameConfig.gameWidth - GameConfig.playerWidth / 2) {
      velocity.x = GameConfig.playerSpeed;
    }

    // Update position
    position.x += velocity.x * dt;

    // Clamp to screen bounds
    position.x = position.x.clamp(
      GameConfig.playerWidth / 2,
      GameConfig.gameWidth - GameConfig.playerWidth / 2,
    );
  }

  void moveLeft(bool active) {
    isMovingLeft = active;
  }

  void moveRight(bool active) {
    isMovingRight = active;
  }

  Rect getBounds() {
    return Rect.fromLTWH(
      position.x - size.x / 2,
      position.y - size.y / 2,
      size.x,
      size.y,
    );
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    // Draw tray
    final paint = Paint()
      ..color =
          const Color.fromARGB(255, 255, 152, 0) // Orange
      ..style = PaintingStyle.fill;

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(-size.x / 2, -size.y / 2, size.x, size.y),
        const Radius.circular(8),
      ),
      paint,
    );

    // Draw border
    final borderPaint = Paint()
      ..color =
          const Color.fromARGB(255, 255, 235, 59) // Yellow
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(-size.x / 2, -size.y / 2, size.x, size.y),
        const Radius.circular(8),
      ),
      borderPaint,
    );

    // Draw emoji
    final textPainter = TextPainter(
      text: const TextSpan(text: emoji, style: TextStyle(fontSize: 32)),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    textPainter.paint(
      canvas,
      Offset(-textPainter.width / 2, -textPainter.height / 2 + 2),
    );
  }
}

// Particle effect component
class FoodParticle extends PositionComponent {
  final Color color;
  late Vector2 velocity;
  final double lifetime;
  double elapsedTime = 0;

  FoodParticle({
    required Vector2 position,
    required this.color,
    required Vector2 velocity,
    required this.lifetime,
  }) : super(position: position, size: Vector2.all(8), anchor: Anchor.center);

  @override
  void update(double dt) {
    super.update(dt);
    elapsedTime += dt;

    position += velocity * dt;
    velocity.y += 200 * dt; // Gravity

    if (elapsedTime > lifetime) {
      removeFromParent();
    }
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    final alpha = ((1 - elapsedTime / lifetime) * 255).toInt();
    final paint = Paint()
      ..color = color.withAlpha(alpha)
      ..maskFilter = const MaskFilter.blur(BlurStyle.outer, 2);

    canvas.drawCircle(Offset.zero, size.x / 2, paint);
  }
}

// Main game class
class CatchTheFoodGame extends FlameGame with HasCollisionDetection {
  late PlayerTray playerTray;
  final List<FoodItem> foodItems = [];
  late GameState gameState;
  double spawnTimer = 0;
  bool gameOver = false;
  double timeAccumulator = 0;
  final VoidCallback? onGameOver;
  final Function(GameResult)? onGameComplete;

  CatchTheFoodGame({this.onGameOver, this.onGameComplete}) {
    // Initialize gameState in constructor to avoid LateInitializationError
    gameState = GameState(timeRemaining: GameConfig.gameDuration);
  }

  @override
  Future<void> onLoad() async {
    super.onLoad();

    // Add player tray
    playerTray = PlayerTray(
      position: Vector2(GameConfig.gameWidth / 2, GameConfig.gameHeight - 80),
    );
    add(playerTray);

    gameState.isGameActive = true;
  }

  @override
  void update(double dt) {
    super.update(dt);

    if (!gameState.isGameActive || gameOver) return;

    // Update timer
    timeAccumulator += dt;
    gameState.timeRemaining = (GameConfig.gameDuration - timeAccumulator)
        .toInt();

    if (gameState.timeRemaining <= 0) {
      endGame();
      return;
    }

    // Update difficulty
    gameState.updateDifficulty();

    // Spawn food items
    spawnTimer += dt;
    final spawnRate = GameConfig.spawnRate * gameState.difficulty;
    final spawnInterval = 1.0 / spawnRate;

    if (spawnTimer >= spawnInterval) {
      spawnFoodItem();
      spawnTimer = 0;
    }
  }

  void spawnFoodItem() {
    final randomType = _selectRandomFood();
    final randomX = math.Random().nextDouble() * GameConfig.gameWidth;

    final foodItem = FoodItem(
      foodType: randomType,
      position: Vector2(randomX, -50),
      trayBounds: playerTray.getBounds(),
      onCaught: () => onFoodCaught(randomType),
    );

    add(foodItem);
    foodItems.add(foodItem);
  }

  FoodType _selectRandomFood() {
    final random = math.Random().nextDouble();
    double cumulativeProbability = 0;

    for (final entry in FoodItemData.foodDatabase.entries) {
      cumulativeProbability += entry.value.spawnProbability;
      if (random <= cumulativeProbability) {
        return entry.key;
      }
    }

    return FoodType.burger;
  }

  void onFoodCaught(FoodType foodType) {
    final foodData = FoodItemData.getFood(foodType);
    final score = gameState.calculateScore(foodData.baseScore);

    if (foodData.isGood) {
      // Good item caught
      gameState.score += score;
      if (foodData.isSpecial && foodType == FoodType.goldenBurger) {
        gameState.coins += 10;
      } else if (foodData.isSpecial && foodType == FoodType.rainbowPizza) {
        gameState.coins += 15;
      } else {
        gameState.coins += 1;
      }

      // Increment combo
      gameState.comboCount++;
      if (gameState.comboCount > gameState.maxCombo) {
        gameState.maxCombo = gameState.comboCount;
      }

      // Trigger combo at threshold
      if (gameState.comboCount == GameConfig.comboThreshold) {
        _triggerCombo();
      }
    } else {
      // Bad item caught - reset combo
      gameState.comboCount = 0;
    }

    gameState.recentCatches.add(DateTime.now().millisecondsSinceEpoch);

    // Clean up old catch timestamps
    final now = DateTime.now().millisecondsSinceEpoch;
    gameState.recentCatches.removeWhere(
      (timestamp) => now - timestamp > GameConfig.comboTimeout,
    );
  }

  void onItemMissed(FoodItem item) {
    // Reset combo on miss
    gameState.comboCount = 0;
  }

  void _triggerCombo() {
    // Combo triggered - this will show effects in UI layer
  }

  void endGame() {
    gameOver = true;
    gameState.isGameActive = false;

    final reward = RewardData.getReward(gameState.score);
    final result = GameResult(
      finalScore: gameState.score,
      totalCoins: gameState.coins,
      bestCombo: gameState.maxCombo,
      reward: reward,
      playedAt: DateTime.now(),
    );

    onGameComplete?.call(result);
  }

  void pauseGame() {
    gameState.isPaused = true;
    gameState.isGameActive = false;
  }

  void resumeGame() {
    gameState.isPaused = false;
    gameState.isGameActive = true;
  }

  void movePlayerLeft() {
    playerTray.moveLeft(true);
  }

  void stopPlayerLeft() {
    playerTray.moveLeft(false);
  }

  void movePlayerRight() {
    playerTray.moveRight(true);
  }

  void stopPlayerRight() {
    playerTray.moveRight(false);
  }

  // Move tray based on drag delta (for smooth gesture tracking)
  // This is the primary drag control method
  void movePlayerByDelta(double deltaX) {
    if (!gameState.isGameActive || gameOver) return;

    // Calculate new position
    final currentX = playerTray.position.x;
    final newX =
        currentX + (deltaX * 1.5); // 1.5x sensitivity for better responsiveness

    // Clamp to valid bounds with proper buffer for tray width
    final minX = GameConfig.playerWidth / 2;
    final maxX = GameConfig.gameWidth - (GameConfig.playerWidth / 2);
    playerTray.position.x = newX.clamp(minX, maxX);
  }

  // Move tray to absolute X position (for touch tracking)
  void movePlayerToX(double x) {
    if (!gameState.isGameActive || gameOver) return;

    // Clamp to valid bounds
    final minX = GameConfig.playerWidth / 2;
    final maxX = GameConfig.gameWidth - (GameConfig.playerWidth / 2);
    playerTray.position.x = x.clamp(minX, maxX);
  }
}
