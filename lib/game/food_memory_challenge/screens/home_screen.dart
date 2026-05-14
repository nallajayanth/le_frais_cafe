import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import 'package:le_frais_mobile_application/game/food_memory_challenge/controllers/game_controller.dart';
import 'package:le_frais_mobile_application/game/food_memory_challenge/utils/color_palette.dart';
import 'package:le_frais_mobile_application/game/food_memory_challenge/widgets/premium_button.dart';
import 'package:le_frais_mobile_application/game/food_memory_challenge/screens/gameplay_screen.dart';
import 'dart:math' as math;

/// Home/Entry screen for Food Memory Challenge
class FoodMemoryChallengeHomeScreen extends StatefulWidget {
  const FoodMemoryChallengeHomeScreen({super.key});

  @override
  State<FoodMemoryChallengeHomeScreen> createState() =>
      _FoodMemoryChallengeHomeScreenState();
}

class _FoodMemoryChallengeHomeScreenState
    extends State<FoodMemoryChallengeHomeScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _floatingController;
  int _playerCoins = 0;

  @override
  void initState() {
    super.initState();
    _floatingController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat(reverse: true);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadPlayerData();
    });
  }

  void _loadPlayerData() async {
    final controller = context.read<GameController>();
    final coins = await controller.getPlayerCoins();

    setState(() {
      _playerCoins = coins;
    });
  }

  @override
  void dispose() {
    _floatingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: ColorPalette.gameBackgroundGradient,
        ),
        child: Stack(
          children: [
            // Animated background
            _buildAnimatedBackground(),

            // Main content
            SafeArea(
              child: Column(
                children: [
                  // Top bar
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '🍽️ Le Frais',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              'Food Memory Challenge',
                              style: const TextStyle(
                                color: Color(0xFFFF6B35),
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                const Color(0xFFFFD700).withValues(alpha: 0.9),
                                const Color(0xFFFFA500).withValues(alpha: 0.9),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            children: [
                              const Text('🪙', style: TextStyle(fontSize: 18)),
                              const SizedBox(width: 6),
                              Text(
                                _playerCoins.toString(),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Spacer
                  const Spacer(flex: 1),

                  // Center content - Animated cards
                  Expanded(
                    flex: 3,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _buildFloatingCards(),
                        const SizedBox(height: 40),
                        Text(
                          'Match the Food Cards!',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                          ),
                        ).animate().fadeIn(
                          duration: const Duration(milliseconds: 800),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Complete matches as quickly as possible',
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 14,
                          ),
                        ).animate().fadeIn(
                          duration: const Duration(milliseconds: 1000),
                        ),
                      ],
                    ),
                  ),

                  // Play availability
                  Container(
                    margin: const EdgeInsets.only(bottom: 20),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.1),
                      border: Border.all(
                        color: const Color(0xFFFF6B35).withValues(alpha: 0.5),
                        width: 1,
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text(
                          'Unlimited Plays',
                          style: TextStyle(color: Colors.white70, fontSize: 14),
                        ),
                      ],
                    ),
                  ),

                  // Action buttons
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      children: [
                        PremiumButton(
                          label: '▶ Play',
                          onPressed: _navigateToDifficultySelection,
                          width: double.infinity,
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: Container(
                                height: 48,
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                    color: const Color(
                                      0xFFFF6B35,
                                    ).withValues(alpha: 0.5),
                                    width: 1,
                                  ),
                                ),
                                child: Material(
                                  color: Colors.transparent,
                                  child: InkWell(
                                    onTap: () {},
                                    borderRadius: BorderRadius.circular(16),
                                    child: const Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          '🏆 Leaderboard',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Container(
                                height: 48,
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                    color: const Color(
                                      0xFFFF6B35,
                                    ).withValues(alpha: 0.5),
                                    width: 1,
                                  ),
                                ),
                                child: Material(
                                  color: Colors.transparent,
                                  child: InkWell(
                                    onTap: () {},
                                    borderRadius: BorderRadius.circular(16),
                                    child: const Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          '🎁 Rewards',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAnimatedBackground() {
    return Positioned.fill(
      child: CustomPaint(
        painter: FloatingParticlesPainter(
          animationValue: _floatingController.value,
        ),
      ),
    );
  }

  Widget _buildFloatingCards() {
    final foodEmojis = ['🍕', '🍔', '🍟', '☕'];

    return Stack(
      alignment: Alignment.center,
      children: [
        ...List.generate(foodEmojis.length, (index) {
          final angle = (index / foodEmojis.length) * 2 * 3.14159;
          final x = 100 * math.cos(angle) / 2;
          final y = 100 * math.sin(angle) / 2;

          return Transform.translate(
            offset: Offset(x, y),
            child: ScaleTransition(
              scale: Tween<double>(begin: 0.5, end: 1.0).animate(
                CurvedAnimation(
                  parent: _floatingController,
                  curve: Curves.easeInOut,
                ),
              ),
              child: Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  gradient: LinearGradient(
                    colors: [const Color(0xFF3D3D3D), const Color(0xFF2D2D2D)],
                  ),
                  border: Border.all(
                    color: const Color(0xFFFF6B35).withValues(alpha: 0.5),
                    width: 2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFFF6B35).withValues(alpha: 0.3),
                      blurRadius: 10,
                    ),
                  ],
                ),
                child: Center(
                  child: Text(
                    foodEmojis[index],
                    style: const TextStyle(fontSize: 32),
                  ),
                ),
              ),
            ),
          );
        }),
      ],
    );
  }

  void _navigateToDifficultySelection() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const DifficultySelectionScreen(),
      ),
    );
  }
}

/// Difficulty Selection Screen
class DifficultySelectionScreen extends StatelessWidget {
  const DifficultySelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: ColorPalette.gameBackgroundGradient,
        ),
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: const Color(
                              0xFFFF6B35,
                            ).withValues(alpha: 0.5),
                          ),
                        ),
                        child: const Icon(
                          Icons.arrow_back,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    const Text(
                      'Select Difficulty',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 40),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  children: [
                    _buildDifficultyCard(
                      context,
                      icon: '⭐',
                      title: 'Easy',
                      description: '4 pairs • 60 seconds',
                      difficulty: 1,
                      isLocked: false,
                    ),
                    const SizedBox(height: 20),
                    _buildDifficultyCard(
                      context,
                      icon: '⭐⭐',
                      title: 'Medium',
                      description: '8 pairs • 45 seconds',
                      difficulty: 2,
                      isLocked: false,
                    ),
                    const SizedBox(height: 20),
                    _buildDifficultyCard(
                      context,
                      icon: '⭐⭐⭐',
                      title: 'Hard',
                      description: '12 pairs • 30 seconds',
                      difficulty: 3,
                      isLocked: false,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDifficultyCard(
    BuildContext context, {
    required String icon,
    required String title,
    required String description,
    required int difficulty,
    required bool isLocked,
  }) {
    return GestureDetector(
      onTap: isLocked ? null : () => _startGame(context, difficulty),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: isLocked
                ? [
                    Colors.grey.withValues(alpha: 0.3),
                    Colors.grey.withValues(alpha: 0.2),
                  ]
                : [const Color(0xFF3D3D3D), const Color(0xFF2D2D2D)],
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isLocked
                ? Colors.grey.withValues(alpha: 0.3)
                : const Color(0xFFFF6B35).withValues(alpha: 0.7),
            width: 2,
          ),
          boxShadow: isLocked
              ? []
              : [
                  BoxShadow(
                    color: const Color(0xFFFF6B35).withValues(alpha: 0.3),
                    blurRadius: 15,
                  ),
                ],
        ),
        child: Row(
          children: [
            Text(icon, style: const TextStyle(fontSize: 32)),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: const TextStyle(color: Colors.white70, fontSize: 14),
                  ),
                ],
              ),
            ),
            if (isLocked)
              const Icon(Icons.lock, color: Colors.white54, size: 24)
            else
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [const Color(0xFFFF8C42), const Color(0xFFFF6B35)],
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.arrow_forward, color: Colors.white),
              ),
          ],
        ),
      ),
    );
  }

  void _startGame(BuildContext context, int difficulty) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => GameplayScreen(difficulty: difficulty),
      ),
    );
  }
}

/// Painter for animated floating particles background
class FloatingParticlesPainter extends CustomPainter {
  final double animationValue;

  FloatingParticlesPainter({required this.animationValue});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFFF6B35).withValues(alpha: 0.05)
      ..isAntiAlias = true;

    for (int i = 0; i < 5; i++) {
      final x = size.width * 0.2 * (i + 1);
      final y = size.height * (0.3 + animationValue * 0.4);

      canvas.drawCircle(Offset(x, y), 20, paint);
    }
  }

  @override
  bool shouldRepaint(FloatingParticlesPainter oldDelegate) => true;
}
