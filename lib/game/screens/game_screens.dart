// Game Screens - UI for the game
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../models/game_models.dart';
import '../config/game_config.dart';

// Entry Screen - Main menu before game starts
class GameEntryScreen extends StatefulWidget {
  final VoidCallback onStartGame;
  final int dailyChancesLeft;
  final int totalCoins;

  const GameEntryScreen({
    required this.onStartGame,
    this.dailyChancesLeft = 3,
    this.totalCoins = 0,
    Key? key,
  }) : super(key: key);

  @override
  State<GameEntryScreen> createState() => _GameEntryScreenState();
}

class _GameEntryScreenState extends State<GameEntryScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _animationController.dispose();
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
          // Animated background particles
          Positioned.fill(
            child: CustomPaint(
              painter: AnimatedParticlePainter(_animationController),
            ),
          ),
          // Content
          SafeArea(
            child: Column(
              children: [
                // Header with logo
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      const SizedBox(height: 20),
                      // Animated title
                      Text(
                            '🍔 CATCH 🍔',
                            style: const TextStyle(
                              fontSize: 48,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFFFF9800),
                              letterSpacing: 3,
                            ),
                          )
                          .animate(onPlay: (controller) => controller.repeat())
                          .scale(
                            begin: const Offset(1, 1),
                            end: const Offset(1.05, 1.05),
                            duration: const Duration(milliseconds: 600),
                          ),
                      const SizedBox(height: 8),
                      const Text(
                        'THE FOOD',
                        style: TextStyle(
                          fontSize: 24,
                          color: Color(0xFFFFEB3B),
                          letterSpacing: 2,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                // Mascot animation area
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Animated chef emoji
                      Text('👨‍🍳', style: const TextStyle(fontSize: 120))
                          .animate(onPlay: (controller) => controller.repeat())
                          .scale(
                            begin: const Offset(1, 1),
                            end: const Offset(1.1, 1.1),
                            duration: const Duration(milliseconds: 1000),
                          )
                          .then()
                          .scale(
                            begin: const Offset(1.1, 1.1),
                            end: const Offset(1, 1),
                            duration: const Duration(milliseconds: 1000),
                          ),
                      const SizedBox(height: 30),
                      // Floating food icons
                      SizedBox(
                        height: 60,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: ['🍔', '🍕', '🍟', '🍩']
                              .map(
                                (emoji) => Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                  ),
                                  child:
                                      Text(
                                            emoji,
                                            style: const TextStyle(
                                              fontSize: 40,
                                            ),
                                          )
                                          .animate(
                                            onPlay: (controller) =>
                                                controller.repeat(),
                                          )
                                          .moveY(
                                            begin: 0,
                                            end: -15,
                                            duration: const Duration(
                                              milliseconds: 800,
                                            ),
                                          )
                                          .then()
                                          .moveY(
                                            begin: -15,
                                            end: 0,
                                            duration: const Duration(
                                              milliseconds: 800,
                                            ),
                                          ),
                                ),
                              )
                              .toList(),
                        ),
                      ),
                    ],
                  ),
                ),
                // Bottom section with info and buttons
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      // Daily chances info
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFF2a2a2a),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: const Color(0xFFFF9800),
                            width: 2,
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '⏱️ Daily Chances Left: ${widget.dailyChancesLeft}/3',
                              style: const TextStyle(
                                fontSize: 16,
                                color: Color(0xFFFFFFFF),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Text(
                              '🪙 ${widget.totalCoins}',
                              style: const TextStyle(
                                fontSize: 16,
                                color: Color(0xFFFFEB3B),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                      // Start button
                      GestureDetector(
                            onTap: widget.onStartGame,
                            child: Container(
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    const Color(0xFFFF9800),
                                    const Color(0xFFFFEB3B),
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(
                                      0xFFFF9800,
                                    ).withOpacity(0.5),
                                    blurRadius: 12,
                                    offset: const Offset(0, 6),
                                  ),
                                ],
                              ),
                              child: const Center(
                                child: Text(
                                  '🚀 START GAME',
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
                          .fadeIn(duration: const Duration(milliseconds: 800))
                          .scaleXY(begin: 0.9),
                      const SizedBox(height: 12),
                      // Additional buttons row
                      Row(
                        children: [
                          Expanded(
                            child: _MenuButton(
                              label: '🏆 Leaderboard',
                              onTap: () {
                                // Navigate to leaderboard
                              },
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _MenuButton(
                              label: '🎁 Rewards',
                              onTap: () {
                                // Navigate to rewards
                              },
                            ),
                          ),
                        ],
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

// Menu button widget
class _MenuButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _MenuButton({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: const Color(0xFF2a2a2a),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFFF9800), width: 1.5),
        ),
        child: Center(
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Color(0xFFFFFFFF),
            ),
          ),
        ),
      ),
    );
  }
}

// Game HUD - Top overlay with score, timer, combo
class GameHUD extends StatefulWidget {
  final GameState gameState;
  final VoidCallback onPause;

  const GameHUD({required this.gameState, required this.onPause, Key? key})
    : super(key: key);

  @override
  State<GameHUD> createState() => _GameHUDState();
}

class _GameHUDState extends State<GameHUD> {
  late Function() _updateCallback;

  @override
  void initState() {
    super.initState();
    // Trigger rebuild frequently to show timer and score updates
    _updateCallback = () => setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: Stream.periodic(const Duration(milliseconds: 50)),
      builder: (context, snapshot) {
        return SafeArea(
          bottom: false,
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              children: [
                // Top row - Timer and Pause
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Timer
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: widget.gameState.timeRemaining < 10
                            ? const Color(0xFFF44336).withOpacity(0.9)
                            : const Color(0xFF2a2a2a).withOpacity(0.9),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: const Color(0xFFFFEB3B),
                          width: 2,
                        ),
                      ),
                      child: Text(
                        '⏱️ ${widget.gameState.timeRemaining}s',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: widget.gameState.timeRemaining < 10
                              ? Colors.white
                              : const Color(0xFFFFEB3B),
                        ),
                      ),
                    ),
                    // Pause button
                    GestureDetector(
                      onTap: widget.onPause,
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: const Color(0xFF2a2a2a).withOpacity(0.9),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: const Color(0xFFFF9800),
                            width: 2,
                          ),
                        ),
                        child: const Text('⏸️', style: TextStyle(fontSize: 20)),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                // Score and coins row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Score
                    _HUDCard(
                      label: 'Score',
                      value: widget.gameState.score.toString(),
                      icon: '⭐',
                      color: const Color(0xFFFF9800),
                    ),
                    // Coins
                    _HUDCard(
                      label: 'Coins',
                      value: widget.gameState.coins.toString(),
                      icon: '🪙',
                      color: const Color(0xFFFFEB3B),
                    ),
                  ],
                ),
                // Combo display (only show if active)
                if (widget.gameState.comboCount >= GameConfig.comboThreshold)
                  Padding(
                    padding: const EdgeInsets.only(top: 12),
                    child:
                        Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    const Color(0xFFFF6B6B),
                                    const Color(0xFFFFD700),
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(
                                      0xFFFF6B6B,
                                    ).withOpacity(0.6),
                                    blurRadius: 12,
                                    spreadRadius: 2,
                                  ),
                                ],
                              ),
                              child: Text(
                                '🔥 COMBO x${widget.gameState.comboCount}',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                  letterSpacing: 1,
                                ),
                              ),
                            )
                            .animate(
                              onPlay: (controller) => controller.repeat(),
                            )
                            .scale(
                              begin: const Offset(1, 1),
                              end: const Offset(1.05, 1.05),
                              duration: const Duration(milliseconds: 400),
                            ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _HUDCard extends StatelessWidget {
  final String label;
  final String value;
  final String icon;
  final Color color;

  const _HUDCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF2a2a2a).withOpacity(0.9),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color, width: 2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(icon, style: const TextStyle(fontSize: 18)),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(fontSize: 12, color: Color(0xFFB0B0B0)),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

// Countdown Screen - 3...2...1...GO!
class CountdownScreen extends StatefulWidget {
  final VoidCallback onCountdownComplete;

  const CountdownScreen({required this.onCountdownComplete, Key? key})
    : super(key: key);

  @override
  State<CountdownScreen> createState() => _CountdownScreenState();
}

class _CountdownScreenState extends State<CountdownScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  int _countdownValue = 3;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    );

    _startCountdown();
  }

  void _startCountdown() {
    for (int i = 3; i > 0; i--) {
      Future.delayed(Duration(seconds: 3 - i), () {
        if (mounted) {
          setState(() {
            _countdownValue = i;
          });
        }
      });
    }

    Future.delayed(const Duration(seconds: 3), () {
      widget.onCountdownComplete();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFF1a1a1a).withOpacity(0.95),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
                  _countdownValue > 0 ? '$_countdownValue' : 'GO!',
                  style: TextStyle(
                    fontSize: _countdownValue > 0 ? 120 : 140,
                    fontWeight: FontWeight.bold,
                    color: _countdownValue > 0
                        ? const Color(0xFFFF9800)
                        : const Color(0xFFFFEB3B),
                  ),
                )
                .animate(onPlay: (controller) => controller.forward())
                .scale(
                  begin: const Offset(0.5, 0.5),
                  end: const Offset(1.2, 1.2),
                  duration: const Duration(milliseconds: 600),
                )
                .then()
                .scale(
                  begin: const Offset(1.2, 1.2),
                  end: const Offset(1, 1),
                  duration: const Duration(milliseconds: 400),
                ),
          ],
        ),
      ),
    );
  }
}

// Animated particle painter for background
class AnimatedParticlePainter extends CustomPainter {
  final AnimationController animation;

  AnimatedParticlePainter(this.animation) : super(repaint: animation);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFFF9800).withOpacity(0.1)
      ..strokeWidth = 1;

    for (int i = 0; i < 20; i++) {
      final x = (i * 50.0 + animation.value * 100) % size.width;
      final y = (i * 40.0 + animation.value * 150) % size.height;
      canvas.drawCircle(Offset(x, y), 2, paint);
    }
  }

  @override
  bool shouldRepaint(AnimatedParticlePainter oldDelegate) => true;
}
