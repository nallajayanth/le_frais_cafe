// Game Integration Widget - For embedding in Order Tracking screen
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'catch_the_food_game.dart';
import 'services/rewards_service.dart';

class GamePlayButton extends StatefulWidget {
  final VoidCallback? onGameClosed;
  final Function(int)? onCoinsEarned;

  const GamePlayButton({this.onGameClosed, this.onCoinsEarned, Key? key})
    : super(key: key);

  @override
  State<GamePlayButton> createState() => _GamePlayButtonState();
}

class _GamePlayButtonState extends State<GamePlayButton> {
  late RewardsService rewardsService;
  int dailyChancesLeft = 5;
  int totalCoins = 0;

  @override
  void initState() {
    super.initState();
    rewardsService = RewardsService();
    _initializeService();
  }

  Future<void> _initializeService() async {
    await rewardsService.initialize();
    setState(() {
      dailyChancesLeft = rewardsService.getDailyChancesLeft();
      totalCoins = rewardsService.getTotalCoins();
    });
  }

  void _playGame() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.95,
        decoration: const BoxDecoration(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: CatchTheFoodGameView(
          onGameClosed: () {
            Navigator.pop(context);
            _refreshChances();
          },
          onRewardEarned: (result) {
            widget.onCoinsEarned?.call(result.totalCoins);
          },
        ),
      ),
    );
  }

  void _refreshChances() {
    setState(() {
      dailyChancesLeft = rewardsService.getDailyChancesLeft();
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
          onTap: dailyChancesLeft > 0 ? _playGame : null,
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: dailyChancesLeft > 0
                  ? LinearGradient(
                      colors: [
                        const Color(0xFFFF9800),
                        const Color(0xFFFFEB3B),
                      ],
                    )
                  : LinearGradient(
                      colors: [
                        const Color(0xFF888888),
                        const Color(0xFF666666),
                      ],
                    ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: dailyChancesLeft > 0
                  ? [
                      BoxShadow(
                        color: const Color(0xFFFF9800).withOpacity(0.5),
                        blurRadius: 12,
                        offset: const Offset(0, 6),
                      ),
                    ]
                  : [],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            '🎮 Play & Win',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              letterSpacing: 0.5,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            dailyChancesLeft > 0
                                ? 'Earn coins while you wait!'
                                : 'Come back tomorrow',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.white.withOpacity(0.9),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        const Text('🪙', style: TextStyle(fontSize: 24)),
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.3),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            dailyChancesLeft > 0
                                ? '$dailyChancesLeft/3'
                                : '0/3',
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        )
        .animate()
        .fadeIn(duration: const Duration(milliseconds: 600))
        .scale(
          begin: Offset(0.8, 0.8),
          duration: const Duration(milliseconds: 600),
        );
  }
}

// Game card for order tracking page
class GameCard extends StatelessWidget {
  const GameCard({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      child: const GamePlayButton(),
    );
  }
}

// Full-screen game launcher for after-payment screen
class GameRewardCard extends StatefulWidget {
  final String orderNumber;
  final VoidCallback? onClose;

  const GameRewardCard({required this.orderNumber, this.onClose, Key? key})
    : super(key: key);

  @override
  State<GameRewardCard> createState() => _GameRewardCardState();
}

class _GameRewardCardState extends State<GameRewardCard> {
  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: EdgeInsets.zero,
      child: Stack(
        children: [
          Positioned.fill(
            child: CatchTheFoodGameView(
              onGameClosed: () {
                Navigator.pop(context);
                widget.onClose?.call();
              },
            ),
          ),
        ],
      ),
    );
  }
}

// Mini preview card for main menu
class GamePreviewCard extends StatelessWidget {
  final VoidCallback onTap;

  const GamePreviewCard({required this.onTap, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              const Color(0xFFFF9800).withOpacity(0.8),
              const Color(0xFFFFEB3B).withOpacity(0.8),
            ],
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFFF9800).withOpacity(0.4),
              blurRadius: 16,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Stack(
            children: [
              // Background pattern
              Positioned.fill(
                child: CustomPaint(painter: GamePreviewPainter()),
              ),
              // Content
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Catch The Food',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1a1a1a),
                            letterSpacing: 1,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          '🍔 🍕 🍟 🍩',
                          style: TextStyle(fontSize: 20),
                        ),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Earn rewards\nwhile you wait',
                          style: TextStyle(
                            fontSize: 12,
                            color: Color(0xFF1a1a1a),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Text(
                            'Play Now →',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFFFF9800),
                            ),
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
      ),
    );
  }
}

class GamePreviewPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.1)
      ..style = PaintingStyle.fill;

    // Draw decorative circles
    canvas.drawCircle(Offset(size.width * 0.8, size.height * 0.2), 40, paint);
    canvas.drawCircle(Offset(size.width * 0.1, size.height * 0.8), 30, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
