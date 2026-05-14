import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'dart:math' as math;

/// Premium animated card widget with flip animation
class AnimatedCardWidget extends StatefulWidget {
  final String foodEmoji;
  final VoidCallback onTap;
  final bool isFlipped;
  final bool isMatched;
  final bool isGoldenCard;
  final bool isRainbowCard;

  const AnimatedCardWidget({
    required this.foodEmoji,
    required this.onTap,
    this.isFlipped = false,
    this.isMatched = false,
    this.isGoldenCard = false,
    this.isRainbowCard = false,
    super.key,
  });

  @override
  State<AnimatedCardWidget> createState() => _AnimatedCardWidgetState();
}

class _AnimatedCardWidgetState extends State<AnimatedCardWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _flipController;
  late Animation<double> _flipAnimation;

  @override
  void initState() {
    super.initState();
    _flipController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _flipAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _flipController, curve: Curves.easeInOut),
    );

    if (widget.isFlipped) {
      _flipController.forward();
    }
  }

  @override
  void didUpdateWidget(AnimatedCardWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isFlipped && !oldWidget.isFlipped) {
      _flipController.forward();
    } else if (!widget.isFlipped && oldWidget.isFlipped) {
      _flipController.reverse();
    }
  }

  @override
  void dispose() {
    _flipController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.isMatched ? null : widget.onTap,
      child: AnimatedBuilder(
        animation: _flipAnimation,
        builder: (context, child) {
          final isShowingBack = _flipAnimation.value < 0.5;

          return Transform(
            alignment: Alignment.center,
            transform: Matrix4.identity()
              ..setEntry(3, 2, 0.001)
              ..rotateY(_flipAnimation.value * math.pi),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: _getGlowColor().withValues(alpha: 0.45),
                    blurRadius: widget.isFlipped ? 18 : 10,
                    spreadRadius: widget.isFlipped ? 1 : 0,
                  ),
                ],
              ),
              child: isShowingBack
                  ? _buildCardBack()
                  : Transform(
                      alignment: Alignment.center,
                      transform: Matrix4.identity()..rotateY(math.pi),
                      child: _buildCardFront(),
                    ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildCardBack() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [const Color(0xFF2D2D2D), const Color(0xFF1A1A1A)],
        ),
        border: Border.all(color: const Color(0xFF444444), width: 2),
      ),
      child: Center(
        child: Icon(
          Icons.question_mark_rounded,
          size: 40,
          color: Colors.white.withValues(alpha: 0.55),
        ),
      ),
    );
  }

  Widget _buildCardFront() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: _getGradient(),
        border: Border.all(color: _getGlowColor(), width: 2),
      ),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(10),
          child:
              FittedBox(
                fit: BoxFit.contain,
                child: Text(
                  widget.foodEmoji,
                  style: const TextStyle(fontSize: 52),
                ),
              ).animate().scale(
                begin: const Offset(0.8, 0.8),
                end: const Offset(1.0, 1.0),
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeOut,
              ),
        ),
      ),
    );
  }

  Color _getGlowColor() {
    if (widget.isRainbowCard) return const Color(0xFF9933FF);
    if (widget.isGoldenCard) return const Color(0xFFFFD700);
    return const Color(0xFFFF6B35);
  }

  LinearGradient _getGradient() {
    if (widget.isRainbowCard) {
      return const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFF9933FF), Color(0xFFFF0000), Color(0xFFFFFF00)],
      );
    }
    if (widget.isGoldenCard) {
      return const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFFFFD700), Color(0xFFFFA500), Color(0xFFFF8C00)],
      );
    }
    return const LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [Color(0xFF3D3D3D), Color(0xFF2D2D2D)],
    );
  }
}
