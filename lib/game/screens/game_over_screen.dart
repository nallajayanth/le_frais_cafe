// Game Over Screen - Results and reward display
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:confetti/confetti.dart';
import '../models/game_models.dart';

class GameOverScreen extends StatefulWidget {
  final GameResult gameResult;
  final VoidCallback onPlayAgain;
  final VoidCallback onHome;
  final VoidCallback onClaimReward;

  const GameOverScreen({
    required this.gameResult,
    required this.onPlayAgain,
    required this.onHome,
    required this.onClaimReward,
    Key? key,
  }) : super(key: key);

  @override
  State<GameOverScreen> createState() => _GameOverScreenState();
}

class _GameOverScreenState extends State<GameOverScreen> {
  late ConfettiController _confettiController;

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(
      duration: const Duration(seconds: 3),
    );
    _confettiController.play();
  }

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [const Color(0xFF1a1a1a), const Color(0xFF2a2a2a)],
        ),
      ),
      child: Stack(
        children: [
          // Confetti
          Align(
            alignment: Alignment.topCenter,
            child: ConfettiWidget(
              confettiController: _confettiController,
              blastDirectionality: BlastDirectionality.explosive,
              particleDrag: 0.05,
              emissionFrequency: 0.05,
              numberOfParticles: 50,
              gravity: 0.1,
              shouldLoop: false,
              colors: const [
                Color(0xFFFF9800),
                Color(0xFFFFEB3B),
                Color(0xFFF44336),
                Color(0xFF4CAF50),
              ],
            ),
          ),
          // Content
          SafeArea(
            child: Column(
              children: [
                const SizedBox(height: 30),
                // Game Over title
                Text(
                      'GAME OVER',
                      style: const TextStyle(
                        fontSize: 48,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFFF44336),
                        letterSpacing: 2,
                      ),
                    )
                    .animate()
                    .fadeIn(duration: const Duration(milliseconds: 600))
                    .scale(begin: const Offset(0.5, 0.5)),
                const SizedBox(height: 30),
                // Score stats
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        _ScoreStat(
                              icon: '⭐',
                              label: 'Final Score',
                              value: widget.gameResult.finalScore.toString(),
                              color: const Color(0xFFFF9800),
                            )
                            .animate()
                            .fadeIn(duration: const Duration(milliseconds: 400))
                            .scale(
                              begin: const Offset(0.8, 0.8),
                              duration: const Duration(milliseconds: 400),
                            ),
                        const SizedBox(height: 16),
                        _ScoreStat(
                              icon: '🔥',
                              label: 'Best Combo',
                              value: 'x${widget.gameResult.bestCombo}',
                              color: const Color(0xFFF44336),
                            )
                            .animate()
                            .fadeIn(duration: const Duration(milliseconds: 600))
                            .scale(
                              begin: const Offset(0.8, 0.8),
                              duration: const Duration(milliseconds: 600),
                              delay: const Duration(milliseconds: 100),
                            ),
                        const SizedBox(height: 16),
                        _ScoreStat(
                              icon: '🪙',
                              label: 'Coins Earned',
                              value: widget.gameResult.totalCoins.toString(),
                              color: const Color(0xFFFFEB3B),
                            )
                            .animate()
                            .fadeIn(duration: const Duration(milliseconds: 400))
                            .scale(
                              begin: const Offset(0.8, 0.8),
                              duration: const Duration(milliseconds: 400),
                              delay: const Duration(milliseconds: 200),
                            ),
                        const SizedBox(height: 30),
                        // Reward display
                        if (widget.gameResult.reward != null)
                          _RewardCard(reward: widget.gameResult.reward!)
                              .animate()
                              .fadeIn(
                                duration: const Duration(milliseconds: 800),
                              )
                              .scale(begin: const Offset(0.8, 0.8)),
                      ],
                    ),
                  ),
                ),
                // Buttons
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      // Claim reward button
                      if (widget.gameResult.reward != null)
                        GestureDetector(
                              onTap: widget.onClaimReward,
                              child: Container(
                                width: double.infinity,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 16,
                                ),
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      const Color(0xFFFFD700),
                                      const Color(0xFFFFA500),
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(16),
                                  boxShadow: [
                                    BoxShadow(
                                      color: const Color(
                                        0xFFFFD700,
                                      ).withOpacity(0.5),
                                      blurRadius: 12,
                                      offset: const Offset(0, 6),
                                    ),
                                  ],
                                ),
                                child: const Center(
                                  child: Text(
                                    '🎁 CLAIM REWARD',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF1a1a1a),
                                      letterSpacing: 1.5,
                                    ),
                                  ),
                                ),
                              ),
                            )
                            .animate()
                            .fadeIn(
                              duration: const Duration(milliseconds: 600),
                              delay: const Duration(milliseconds: 500),
                            )
                            .scaleXY(begin: 0.9),
                      if (widget.gameResult.reward != null)
                        const SizedBox(height: 12),
                      // Play again button
                      GestureDetector(
                            onTap: widget.onPlayAgain,
                            child: Container(
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              decoration: BoxDecoration(
                                color: const Color(0xFF2a2a2a),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: const Color(0xFFFF9800),
                                  width: 2,
                                ),
                              ),
                              child: const Center(
                                child: Text(
                                  '🚀 PLAY AGAIN',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFFFF9800),
                                    letterSpacing: 1.5,
                                  ),
                                ),
                              ),
                            ),
                          )
                          .animate()
                          .fadeIn(
                            duration: const Duration(milliseconds: 600),
                            delay: const Duration(milliseconds: 600),
                          )
                          .scaleXY(begin: 0.9),
                      const SizedBox(height: 12),
                      // Home button
                      GestureDetector(
                        onTap: widget.onHome,
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          decoration: BoxDecoration(
                            color: Colors.transparent,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: const Color(0xFFB0B0B0),
                              width: 1.5,
                            ),
                          ),
                          child: const Center(
                            child: Text(
                              '🏠 HOME',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFFB0B0B0),
                                letterSpacing: 1,
                              ),
                            ),
                          ),
                        ),
                      ).animate().fadeIn(
                        duration: const Duration(milliseconds: 600),
                        delay: const Duration(milliseconds: 700),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Score stat card
class _ScoreStat extends StatelessWidget {
  final String icon;
  final String label;
  final String value;
  final Color color;

  const _ScoreStat({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      decoration: BoxDecoration(
        color: const Color(0xFF2a2a2a),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color, width: 2),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 14,
                  color: Color(0xFFB0B0B0),
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
          Text(icon, style: const TextStyle(fontSize: 40)),
        ],
      ),
    );
  }
}

// Reward card
class _RewardCard extends StatelessWidget {
  final RewardData reward;

  const _RewardCard({required this.reward});

  @override
  Widget build(BuildContext context) {
    return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                const Color(0xFFFFD700).withOpacity(0.2),
                const Color(0xFFFFA500).withOpacity(0.2),
              ],
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFFFD700), width: 3),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFFFD700).withOpacity(0.5),
                blurRadius: 20,
                spreadRadius: 2,
              ),
            ],
          ),
          child: Column(
            children: [
              const Text(
                '🎉 REWARD UNLOCKED 🎉',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFFFD700),
                  letterSpacing: 1,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                reward.description,
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFFFFFFF),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                _getRewardEmoji(reward.rewardType),
                style: const TextStyle(fontSize: 48),
              ),
            ],
          ),
        )
        .animate(onPlay: (controller) => controller.repeat())
        .scale(
          begin: const Offset(1, 1),
          end: const Offset(1.02, 1.02),
          duration: const Duration(milliseconds: 800),
        );
  }

  String _getRewardEmoji(String rewardType) {
    switch (rewardType) {
      case 'coins':
        return '🪙';
      case 'discount':
        return '🍔';
      case 'mystery':
        return '🎁';
      case 'jackpot':
        return '🎰';
      default:
        return '🎉';
    }
  }
}

// Pause overlay
class PauseOverlay extends StatelessWidget {
  final VoidCallback onResume;
  final VoidCallback onHome;

  const PauseOverlay({required this.onResume, required this.onHome, Key? key})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black.withOpacity(0.7),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'PAUSED',
              style: TextStyle(
                fontSize: 48,
                fontWeight: FontWeight.bold,
                color: Color(0xFFFF9800),
                letterSpacing: 2,
              ),
            ),
            const SizedBox(height: 60),
            GestureDetector(
              onTap: onResume,
              child: Container(
                width: 200,
                padding: const EdgeInsets.symmetric(vertical: 16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [const Color(0xFFFF9800), const Color(0xFFFFEB3B)],
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Center(
                  child: Text(
                    '▶️ RESUME',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1a1a1a),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            GestureDetector(
              onTap: onHome,
              child: Container(
                width: 200,
                padding: const EdgeInsets.symmetric(vertical: 16),
                decoration: BoxDecoration(
                  color: const Color(0xFF2a2a2a),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFFF9800), width: 2),
                ),
                child: const Center(
                  child: Text(
                    '🏠 HOME',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFFF9800),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
