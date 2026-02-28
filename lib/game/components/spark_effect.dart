import 'dart:math';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';

class SparkParticle {
  Vector2 position;
  Vector2 velocity;
  final double radius;
  final Color baseColor;

  SparkParticle({
    required this.position,
    required this.velocity,
    required this.radius,
    required this.baseColor,
  });
}

class SparkEffect extends PositionComponent {
  final int particleCount = 12;
  final double duration = 0.5; // Fades out over half a second
  final Color color;

  double _elapsed = 0;
  final List<SparkParticle> _particles = [];

  SparkEffect({
    required Vector2 position,
    this.color = const Color(0xFFFFFFFF),
  }) {
    this.position = position;
    priority = 20; // Above everything else
    anchor = Anchor.center;

    final rand = Random();

    // Generate particles bursting outwards
    for (int i = 0; i < particleCount; i++) {
      // Random angle (0 to 2*pi)
      final double angle = rand.nextDouble() * 2 * pi;

      // Random velocity speed
      final double speed = rand.nextDouble() * 50 + 50;

      _particles.add(
        SparkParticle(
          position: Vector2.zero(), // Start at center
          velocity: Vector2(cos(angle) * speed, sin(angle) * speed),
          radius: rand.nextDouble() * 1.5 + 1.5,
          baseColor: color,
        ),
      );
    }
  }

  @override
  void update(double dt) {
    super.update(dt);
    _elapsed += dt;

    if (_elapsed >= duration) {
      removeFromParent(); // Despawn when finished Let GC collect
      return;
    }

    for (final p in _particles) {
      p.position += p.velocity * dt;
      // Slight drag to ease out the explosion curve
      p.velocity *= 0.85;
    }
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    // Calculate alpha interpolation based on remaining life
    final double lifecycleProgress = (_elapsed / duration).clamp(0.0, 1.0);
    final double alpha = 1.0 - lifecycleProgress;

    for (final p in _particles) {
      final Paint paint = Paint()..color = p.baseColor.withOpacity(alpha);
      canvas.drawCircle(Offset(p.position.x, p.position.y), p.radius, paint);
    }
  }
}
