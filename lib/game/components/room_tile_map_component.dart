import 'dart:ui';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import '../quest_arena_game.dart';

class RoomTileMapComponent extends PositionComponent {
  final List<List<String>> map;

  RoomTileMapComponent(this.map);

  @override
  void render(Canvas canvas) {
    for (int y = 0; y < map.length; y++) {
      for (int x = 0; x < map[y].length; x++) {
        final type = map[y][x];
        _drawTile(canvas, x, y, type);
      }
    }
  }

  void _drawTile(Canvas canvas, int x, int y, String type) {
    final rect = Rect.fromLTWH(
      x * QuestArenaGame.tileSize,
      y * QuestArenaGame.tileSize,
      QuestArenaGame.tileSize,
      QuestArenaGame.tileSize,
    );

    Color color;
    bool hasX = false;
    bool hasPulse = false;
    String label = '';

    switch (type) {
      case 'wall':
        color = const Color(0xFF1B1B2F);
        break;
      case 'floor':
        color = const Color(0xFF16213E);
        break;
      case 'hazard':
        color = const Color(0xFFE94560).withOpacity(0.3);
        hasX = true;
        break;
      case 'pedestal':
        color = const Color(0xFF8B4513);
        label = 'ITEM';
        break;
      case 'exit_portal':
        color = const Color(0xFF53CFFF).withOpacity(0.5);
        hasPulse = true;
        label = 'EXIT';
        break;
      default:
        color = const Color(0xFF0F0F1B);
    }

    // Base background
    canvas.drawRect(rect, Paint()..color = color);

    // Subtle border
    canvas.drawRect(
      rect,
      Paint()
        ..color = Colors.white.withOpacity(0.05)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.5,
    );

    if (hasX) {
      final p = Paint()
        ..color = const Color(0xFFE94560)
        ..strokeWidth = 2;
      canvas.drawLine(rect.topLeft, rect.bottomRight, p);
      canvas.drawLine(rect.topRight, rect.bottomLeft, p);
    }

    if (label.isNotEmpty) {
      final textStyle = TextStyle(
        color: Colors.white.withOpacity(0.8),
        fontSize: 8,
        fontWeight: FontWeight.bold,
      );
      final textSpan = TextSpan(text: label, style: textStyle);
      final textPainter = TextPainter(
        text: textSpan,
        textDirection: TextDirection.ltr,
      );
      textPainter.layout();
      textPainter.paint(
        canvas,
        Offset(
          rect.center.dx - textPainter.width / 2,
          rect.center.dy - textPainter.height / 2,
        ),
      );
    }
  }
}
