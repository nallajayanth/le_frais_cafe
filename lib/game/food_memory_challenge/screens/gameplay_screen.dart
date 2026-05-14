import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import 'package:le_frais_mobile_application/game/food_memory_challenge/controllers/game_controller.dart';
import 'package:le_frais_mobile_application/game/food_memory_challenge/models/difficulty_level.dart';
import 'package:le_frais_mobile_application/game/food_memory_challenge/models/game_state.dart';
import 'package:le_frais_mobile_application/game/food_memory_challenge/utils/color_palette.dart';
import 'package:le_frais_mobile_application/game/food_memory_challenge/utils/helpers.dart';
import 'package:le_frais_mobile_application/game/food_memory_challenge/widgets/animated_card.dart';
import 'package:le_frais_mobile_application/game/food_memory_challenge/widgets/combo_display.dart';
import 'package:le_frais_mobile_application/game/food_memory_challenge/widgets/premium_button.dart';

/// Main gameplay screen
class GameplayScreen extends StatefulWidget {
  final int difficulty;

  const GameplayScreen({required this.difficulty, super.key});

  @override
  State<GameplayScreen> createState() => _GameplayScreenState();
}

class _GameplayScreenState extends State<GameplayScreen> {
  late DifficultyLevel _selectedDifficulty;
  bool _hasSavedGameResult = false;

  @override
  void initState() {
    super.initState();
    _selectedDifficulty = _getDifficultyLevel(widget.difficulty);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _startGame();
    });
  }

  DifficultyLevel _getDifficultyLevel(int difficulty) {
    switch (difficulty) {
      case 1:
        return DifficultyLevel.easy;
      case 2:
        return DifficultyLevel.medium;
      case 3:
        return DifficultyLevel.hard;
      default:
        return DifficultyLevel.easy;
    }
  }

  Future<void> _startGame() async {
    final controller = context.read<GameController>();
    try {
      _hasSavedGameResult = false;
      await controller.startGame(_selectedDifficulty);
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: ColorPalette.gameBackgroundGradient,
        ),
        child: SafeArea(
          child: Consumer<GameController>(
            builder: (context, controller, _) {
              final gameState = controller.currentGameState;

              if (gameState == null) {
                return const Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(
                      Color(0xFFFF6B35),
                    ),
                  ),
                );
              }

              if (gameState.isGameOver) {
                _saveGameResultOnce(controller);
                return GameOverScreen(
                  gameState: gameState,
                  onPlayAgain: _startGame,
                  onHome: () => Navigator.pop(context),
                );
              }

              return Column(
                children: [
                  _buildHUD(gameState),
                  if (gameState.comboCount >= 3)
                    ComboDisplay(
                      comboCount: gameState.comboCount,
                      isActive: true,
                    ),
                  Expanded(child: _buildCardGrid(gameState, controller)),
                  _buildExitButton(),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildHUD(GameState gameState) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 10),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildHUDItem(
                  icon: '🎯',
                  label: 'Score',
                  value: gameState.score.toString(),
                ),
                _buildHUDItem(
                  icon: '🔄',
                  label: 'Moves',
                  value: gameState.moves.toString(),
                ),
                _buildHUDItem(
                  icon: '⏱️',
                  label: 'Time',
                  value: GameHelpers.formatTime(gameState.timeRemaining),
                  isWarning: gameState.timeRemaining <= 10,
                ),
              ],
            ),
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: LinearProgressIndicator(
                value: gameState.getProgress(),
                minHeight: 8,
                backgroundColor: Colors.white.withValues(alpha: 0.1),
                valueColor: const AlwaysStoppedAnimation<Color>(
                  Color(0xFFFF6B35),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '${(gameState.getProgress() * 100).toStringAsFixed(0)}% Complete',
              style: const TextStyle(color: Colors.white70, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHUDItem({
    required String icon,
    required String label,
    required String value,
    bool isWarning = false,
  }) {
    return Column(
      children: [
        Text(icon, style: const TextStyle(fontSize: 20)),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 11,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            color: isWarning ? const Color(0xFFE63946) : Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildCardGrid(GameState gameState, GameController controller) {
    final crossAxisCount = gameState.difficulty.pairs <= 4 ? 2 : 4;
    final itemCount = gameState.cards.length;
    final rowCount = (itemCount / crossAxisCount).ceil();

    return LayoutBuilder(
      builder: (context, constraints) {
        const spacing = 12.0;
        const horizontalPadding = 16.0;
        const verticalPadding = 10.0;

        final gridWidth = constraints.maxWidth - (horizontalPadding * 2);
        final gridHeight = constraints.maxHeight - (verticalPadding * 2);
        final cardWidth =
            (gridWidth - (spacing * (crossAxisCount - 1))) / crossAxisCount;
        final cardHeight =
            (gridHeight - (spacing * math.max(0, rowCount - 1))) / rowCount;
        final childAspectRatio = cardWidth / math.max(1, cardHeight);

        return GridView.builder(
          padding: const EdgeInsets.symmetric(
            horizontal: horizontalPadding,
            vertical: verticalPadding,
          ),
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            crossAxisSpacing: spacing,
            mainAxisSpacing: spacing,
            childAspectRatio: childAspectRatio,
          ),
          itemCount: itemCount,
          itemBuilder: (context, index) {
            final card = gameState.cards[index];
            return AnimatedCardWidget(
              key: ValueKey(card.id),
              foodEmoji: card.foodEmoji,
              isFlipped: card.isFlipped || card.isMatched,
              isMatched: card.isMatched,
              isGoldenCard: card.isGoldenCard,
              isRainbowCard: card.isRainbowCard,
              onTap: () => controller.tapCard(card.id),
            );
          },
        );
      },
    );
  }

  Widget _buildExitButton() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      child: GestureDetector(
        onTap: () => Navigator.pop(context),
        child: Container(
          height: 48,
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
          ),
          child: const Center(
            child: Text(
              'Exit',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _saveGameResultOnce(GameController controller) {
    if (_hasSavedGameResult) return;

    _hasSavedGameResult = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        controller.saveGameResult();
      }
    });
  }
}

/// Game Over Screen
class GameOverScreen extends StatelessWidget {
  final GameState gameState;
  final VoidCallback onPlayAgain;
  final VoidCallback onHome;

  const GameOverScreen({
    required this.gameState,
    required this.onPlayAgain,
    required this.onHome,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final stars = GameHelpers.calculateStarRating(
      totalTime: gameState.difficulty.timeSeconds,
      timeTaken: gameState.getElapsedTime(),
      moves: gameState.moves,
      totalPairs: gameState.difficulty.pairs,
      difficulty: gameState.difficulty.level,
    );

    return Stack(
      children: [
        Center(
          child: Container(
            width: 300,
            height: 300,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  const Color(0xFFFF6B35).withValues(alpha: 0.2),
                  Colors.transparent,
                ],
              ),
            ),
          ),
        ),
        Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(vertical: 20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  gameState.isVictory ? '🎉' : '😢',
                  style: const TextStyle(fontSize: 80),
                ).animate().scale(
                  begin: const Offset(0, 0),
                  end: const Offset(1, 1),
                  duration: const Duration(milliseconds: 600),
                  curve: Curves.elasticOut,
                ),
                const SizedBox(height: 20),
                Text(
                  gameState.isVictory ? 'Victory!' : 'Game Over',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                  ),
                ).animate().fadeIn(duration: const Duration(milliseconds: 800)),
                const SizedBox(height: 30),
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 20),
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: const Color(0xFFFF6B35).withValues(alpha: 0.3),
                    ),
                  ),
                  child: Column(
                    children: [
                      _buildStatRow('Score', gameState.score.toString()),
                      const SizedBox(height: 12),
                      _buildStatRow('Moves', gameState.moves.toString()),
                      const SizedBox(height: 12),
                      _buildStatRow(
                        'Time',
                        GameHelpers.formatTime(gameState.getElapsedTime()),
                      ),
                      const SizedBox(height: 12),
                      _buildStatRow(
                        'Coins Earned',
                        gameState.coinsEarned.toString(),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 30),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(3, (index) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child:
                          Text(
                            index < stars ? '⭐' : '☆',
                            style: const TextStyle(fontSize: 32),
                          ).animate().scale(
                            delay: Duration(milliseconds: index * 100),
                            begin: const Offset(0, 0),
                            end: const Offset(1, 1),
                            duration: const Duration(milliseconds: 400),
                            curve: Curves.elasticOut,
                          ),
                    );
                  }),
                ),
                const SizedBox(height: 40),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    children: [
                      PremiumButton(
                        label: '▶ Play Again',
                        onPressed: onPlayAgain,
                      ),
                      const SizedBox(height: 12),
                      Container(
                        height: 48,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: const Color(
                              0xFFFF6B35,
                            ).withValues(alpha: 0.5),
                          ),
                        ),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: onHome,
                            borderRadius: BorderRadius.circular(16),
                            child: const Center(
                              child: Text(
                                '🏠 Home',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStatRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(color: Colors.white70, fontSize: 14),
        ),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
