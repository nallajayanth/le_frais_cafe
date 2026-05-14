import 'package:flutter/material.dart';
import 'dart:math' as math;

/// Glow effect painter for glowing cards and UI elements
class GlowEffectPainter extends CustomPainter {
  final Color glowColor;
  final double glowRadius;
  final double intensity;
  final Animation<double>? animation;

  GlowEffectPainter({
    required this.glowColor,
    required this.glowRadius,
    required this.intensity,
    this.animation,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final animationValue = animation?.value ?? 0.5;
    final pulseIntensity = 0.5 + (math.sin(animationValue * 2 * math.pi) * 0.5);

    final rect = Rect.fromLTWH(0, 0, size.width, size.height);

    // Draw pulsing glow
    canvas.drawRect(
      rect,
      Paint()
        ..color = glowColor.withOpacity(intensity * pulseIntensity * 0.3)
        ..maskFilter = MaskFilter.blur(
          BlurStyle.outer,
          glowRadius * pulseIntensity,
        ),
    );
  }

  @override
  bool shouldRepaint(GlowEffectPainter oldDelegate) => true;
}

/// Animated glow widget
class GlowEffect extends StatefulWidget {
  final Widget child;
  final Color glowColor;
  final double glowRadius;
  final Duration duration;
  final double intensity;

  const GlowEffect({
    required this.child,
    required this.glowColor,
    this.glowRadius = 20.0,
    this.duration = const Duration(milliseconds: 1500),
    this.intensity = 1.0,
    Key? key,
  }) : super(key: key);

  @override
  State<GlowEffect> createState() => _GlowEffectState();
}

class _GlowEffectState extends State<GlowEffect>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(duration: widget.duration, vsync: this)
      ..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        CustomPaint(
          painter: GlowEffectPainter(
            glowColor: widget.glowColor,
            glowRadius: widget.glowRadius,
            intensity: widget.intensity,
            animation: _controller,
          ),
          child: widget.child,
        ),
        widget.child,
      ],
    );
  }
}

/// Screen flash effect for big wins
class ScreenFlashEffect extends StatefulWidget {
  final Color color;
  final Duration duration;

  const ScreenFlashEffect({
    required this.color,
    this.duration = const Duration(milliseconds: 500),
    Key? key,
  }) : super(key: key);

  @override
  State<ScreenFlashEffect> createState() => _ScreenFlashEffectState();
}

class _ScreenFlashEffectState extends State<ScreenFlashEffect>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _opacity;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(duration: widget.duration, vsync: this);

    _opacity = Tween<double>(
      begin: 1.0,
      end: 0.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _opacity,
      child: Container(color: widget.color.withOpacity(0.7)),
    );
  }
}
