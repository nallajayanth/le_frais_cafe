import 'package:flutter/material.dart';

/// Combo display widget
class ComboDisplay extends StatefulWidget {
  final int comboCount;
  final bool isActive;

  const ComboDisplay({
    required this.comboCount,
    required this.isActive,
    Key? key,
  }) : super(key: key);

  @override
  State<ComboDisplay> createState() => _ComboDisplayState();
}

class _ComboDisplayState extends State<ComboDisplay>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    if (widget.isActive) {
      _controller.forward(from: 0);
    }
  }

  @override
  void didUpdateWidget(ComboDisplay oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isActive && widget.comboCount > oldWidget.comboCount) {
      _controller.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.comboCount < 3 || !widget.isActive) {
      return const SizedBox.shrink();
    }

    final color = _getComboColor();
    final multiplier = widget.comboCount >= 5 ? '3X' : '2X';

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.scale(
          scale: 0.8 + (_controller.value * 0.4),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '🔥 COMBO x${widget.comboCount}',
                style: TextStyle(
                  color: color,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  shadows: [
                    Shadow(color: color.withOpacity(0.5), blurRadius: 10),
                  ],
                ),
              ),
              const SizedBox(height: 4),
              Text(
                multiplier,
                style: TextStyle(
                  color: color,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  shadows: [
                    Shadow(color: color.withOpacity(0.5), blurRadius: 10),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Color _getComboColor() {
    if (widget.comboCount >= 10) return const Color(0xFF9933FF);
    if (widget.comboCount >= 5) return const Color(0xFFFFD700);
    return const Color(0xFFFF6B35);
  }
}

/// Special card indicator
class SpecialCardIndicator extends StatefulWidget {
  final bool isGoldenCard;
  final bool isRainbowCard;

  const SpecialCardIndicator({
    required this.isGoldenCard,
    required this.isRainbowCard,
    Key? key,
  }) : super(key: key);

  @override
  State<SpecialCardIndicator> createState() => _SpecialCardIndicatorState();
}

class _SpecialCardIndicatorState extends State<SpecialCardIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.isGoldenCard && !widget.isRainbowCard) {
      return const SizedBox.shrink();
    }

    final text = widget.isRainbowCard ? '🌈 MEGA BONUS!' : '✨ GOLDEN CARD!';
    final color = widget.isRainbowCard
        ? const Color(0xFF9933FF)
        : const Color(0xFFFFD700);

    return ScaleTransition(
      scale: Tween<double>(
        begin: 0.9,
        end: 1.1,
      ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut)),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: [color, color.withOpacity(0.6)]),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [BoxShadow(color: color.withOpacity(0.5), blurRadius: 15)],
        ),
        child: Text(
          text,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}

/// Reward popup for displaying earned rewards
class RewardPopup extends StatefulWidget {
  final String title;
  final int coins;
  final String emoji;
  final Duration duration;

  const RewardPopup({
    required this.title,
    required this.coins,
    required this.emoji,
    this.duration = const Duration(seconds: 2),
    Key? key,
  }) : super(key: key);

  @override
  State<RewardPopup> createState() => _RewardPopupState();
}

class _RewardPopupState extends State<RewardPopup>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(duration: widget.duration, vsync: this);
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: Tween<double>(
        begin: 0,
        end: 1,
      ).animate(CurvedAnimation(parent: _controller, curve: Curves.elasticOut)),
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, -1),
          end: Offset.zero,
        ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut)),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                const Color(0xFFFF6B35).withOpacity(0.9),
                const Color(0xFFFFD700).withOpacity(0.9),
              ],
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFFF6B35).withOpacity(0.5),
                blurRadius: 20,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(widget.emoji, style: const TextStyle(fontSize: 40)),
              const SizedBox(height: 8),
              Text(
                widget.title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '+${widget.coins} 🪙',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
