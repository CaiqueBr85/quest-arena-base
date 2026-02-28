import 'dart:ui';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import '../quest_arena_game.dart';

class RoomPlayerComponent extends PositionComponent {
  RoomPlayerComponent() : super(size: Vector2.all(QuestArenaGame.tileSize));

  @override
  void render(Canvas canvas) {
    final center = size / 2;
    final radius = size.x * 0.35;

    // Green circle for room player
    canvas.drawCircle(
      center.toOffset(),
      radius,
      Paint()..color = const Color(0xFF00FF88),
    );

    // White outline
    canvas.drawCircle(
      center.toOffset(),
      radius,
      Paint()
        ..color = Colors.white
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );

    // Inner glow
    canvas.drawCircle(
      center.toOffset(),
      radius * 0.6,
      Paint()..color = Colors.white.withOpacity(0.3),
    );
  }

  void updatePosition(int tileX, int tileY) {
    position = Vector2(
      tileX * QuestArenaGame.tileSize,
      tileY * QuestArenaGame.tileSize,
    );
  }
}
