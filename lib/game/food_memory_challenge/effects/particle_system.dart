import 'package:flutter/material.dart';
import 'dart:math' as math;

/// Particle effect painter for various visual effects
class ParticleEffectPainter extends CustomPainter {
  final List<Particle> particles;
  final double progress;

  ParticleEffectPainter({required this.particles, required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    for (var particle in particles) {
      particle.update(progress);
      particle.draw(canvas, size);
    }
  }

  @override
  bool shouldRepaint(ParticleEffectPainter oldDelegate) => true;
}

/// Individual particle in a particle effect
class Particle {
  late double x;
  late double y;
  late double vx; // velocity x
  late double vy; // velocity y
  late Color color;
  late double size;
  late double life;
  late double maxLife;
  final math.Random random = math.Random();

  Particle({
    required double startX,
    required double startY,
    required this.color,
    required this.size,
    this.maxLife = 1.0,
  }) {
    x = startX;
    y = startY;
    life = 0;

    // Random velocity
    final angle = random.nextDouble() * 2 * math.pi;
    final speed = 100 + random.nextDouble() * 150;
    vx = math.cos(angle) * speed;
    vy = math.sin(angle) * speed;
  }

  void update(double deltaTime) {
    life = (life + deltaTime).clamp(0, maxLife).toDouble();
    x += vx * deltaTime;
    y += vy * deltaTime;
    vy += 980 * deltaTime; // Gravity
  }

  void draw(Canvas canvas, Size canvasSize) {
    final opacity = 1.0 - (life / maxLife);
    canvas.drawCircle(
      Offset(x, y),
      size * opacity,
      Paint()..color = color.withValues(alpha: opacity * 0.8),
    );
  }

  bool get isDead => life >= maxLife;
}

/// Confetti particle for celebrations
class ConfettiParticle extends Particle {
  late double rotation;
  late double rotationSpeed;

  ConfettiParticle({
    required super.startX,
    required super.startY,
    required super.color,
  }) : super(size: 4, maxLife: 1.5) {
    rotation = random.nextDouble() * 360;
    rotationSpeed = -200 + random.nextDouble() * 400;
  }

  @override
  void update(double deltaTime) {
    super.update(deltaTime);
    rotation += rotationSpeed * deltaTime;
  }

  @override
  void draw(Canvas canvas, Size canvasSize) {
    final opacity = 1.0 - (life / maxLife);

    canvas.save();
    canvas.translate(x, y);
    canvas.rotate(rotation * math.pi / 180);

    canvas.drawRect(
      Rect.fromCenter(center: const Offset(0, 0), width: 4, height: 8),
      Paint()..color = color.withValues(alpha: opacity * 0.8),
    );

    canvas.restore();
  }
}

/// Spark particle for glowing effects
class SparkParticle extends Particle {
  late double brightness;

  SparkParticle({
    required super.startX,
    required super.startY,
    required super.color,
  }) : super(size: 2, maxLife: 0.8) {
    brightness = 1.0;
  }

  @override
  void update(double deltaTime) {
    super.update(deltaTime);
    brightness = 1.0 - (life / maxLife);
  }

  @override
  void draw(Canvas canvas, Size canvasSize) {
    final opacity = brightness * 0.8;

    // Draw glow
    canvas.drawCircle(
      Offset(x, y),
      4 * brightness,
      Paint()
        ..color = color.withValues(alpha: opacity * 0.3)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2),
    );

    // Draw core
    canvas.drawCircle(
      Offset(x, y),
      size * brightness,
      Paint()..color = color.withValues(alpha: opacity),
    );
  }
}

/// System for managing particle effects
class ParticleSystem {
  final List<Particle> particles = [];
  final int maxParticles;

  ParticleSystem({this.maxParticles = 200});

  /// Emit particles from a position
  void emit({
    required double x,
    required double y,
    required int count,
    required Color color,
    String type = 'spark',
  }) {
    for (int i = 0; i < count; i++) {
      if (particles.length >= maxParticles) {
        particles.removeAt(0);
      }

      Particle particle;
      if (type == 'confetti') {
        particle = ConfettiParticle(startX: x, startY: y, color: color);
      } else {
        particle = SparkParticle(startX: x, startY: y, color: color);
      }

      particles.add(particle);
    }
  }

  /// Emit explosion
  void emitExplosion({
    required double x,
    required double y,
    required Color color,
  }) {
    emit(x: x, y: y, count: 30, color: color, type: 'spark');
  }

  /// Emit confetti burst
  void emitConfetti({
    required double x,
    required double y,
    List<Color>? colors,
  }) {
    colors ??= [
      const Color(0xFFFF6B35),
      const Color(0xFFFFD700),
      const Color(0xFF4CAF50),
      const Color(0xFF2196F3),
    ];

    for (int i = 0; i < 50; i++) {
      emit(
        x: x,
        y: y,
        count: 1,
        color: colors[i % colors.length],
        type: 'confetti',
      );
    }
  }

  /// Update all particles
  void update(double deltaTime) {
    for (var particle in particles) {
      particle.update(deltaTime);
    }
    particles.removeWhere((p) => p.isDead);
  }

  /// Clear all particles
  void clear() {
    particles.clear();
  }

  /// Get number of active particles
  int get activeCount => particles.length;
}
