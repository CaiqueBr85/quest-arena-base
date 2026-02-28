import 'dart:math';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';

class TileMapComponent extends PositionComponent {
  static const double tileSize = 32.0;

  List<List<String>> _map = [];
  double _elapsedTime = 0.0;

  TileMapComponent() {
    size = Vector2(20 * tileSize, 20 * tileSize);
  }

  void updateMap(List<List<String>> newMap) {
    _map = newMap;
  }

  @override
  void update(double dt) {
    super.update(dt);
    _elapsedTime += dt;
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    if (_map.isEmpty) return;

    final Paint emptyPaint = Paint()..color = const Color(0xFF1A1A2E);
    final Paint wallPaint = Paint()..color = const Color(0xFF16213E);

    // Grid lines
    final Paint gridPaint = Paint()
      ..color = const Color(0xFF0F3460).withOpacity(0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.5;

    for (int row = 0; row < _map.length; row++) {
      for (int col = 0; col < _map[row].length; col++) {
        final String tileType = _map[row][col];
        final Rect rect = Rect.fromLTWH(
          col * tileSize,
          row * tileSize,
          tileSize,
          tileSize,
        );

        // Draw background
        if (tileType == 'wall') {
          canvas.drawRect(rect, wallPaint);
        } else {
          canvas.drawRect(rect, emptyPaint);
        }

        // Draw special tiles
        if (tileType == 'gem') {
          _drawGem(canvas, rect);
        } else if (tileType == 'locked_door') {
          _drawLockedDoor(canvas, rect);
        } else if (tileType == 'door') {
          _drawDoor(canvas, rect);
        }

        // Draw grid lines
        canvas.drawRect(rect, gridPaint);
      }
    }
  }

  void _drawGem(Canvas canvas, Rect rect) {
    final center = rect.center;
    final double radius = tileSize * 0.3;

    canvas.save();
    canvas.translate(center.dx, center.dy);
    // Rotate animation using elapsed time
    canvas.rotate(_elapsedTime * 2.0);

    final Path diamondPath = Path()
      ..moveTo(0, -radius)
      ..lineTo(radius, 0)
      ..lineTo(0, radius)
      ..lineTo(-radius, 0)
      ..close();

    final Paint gemPaint = Paint()
      ..color = const Color(0xFF00FFFF); // bright cyan
    canvas.drawPath(diamondPath, gemPaint);

    canvas.restore();
  }

  void _drawLockedDoor(Canvas canvas, Rect rect) {
    final Paint lockedDoorBgPaint = Paint()..color = const Color(0xFFFFE066);
    final Paint keyholePaint = Paint()..color = const Color(0xFF1A1A2E);

    // Draw rounded rect, slightly smaller than the tile
    final RRect rrect = RRect.fromRectAndRadius(
      rect.deflate(4.0),
      const Radius.circular(4.0),
    );
    canvas.drawRRect(rrect, lockedDoorBgPaint);

    // Draw keyhole shape
    final center = rect.center;
    canvas.drawCircle(Offset(center.dx, center.dy - 2), 3.0, keyholePaint);

    final Path trapPath = Path()
      ..moveTo(center.dx - 3, center.dy + 5)
      ..lineTo(center.dx + 3, center.dy + 5)
      ..lineTo(center.dx + 1.5, center.dy - 2)
      ..lineTo(center.dx - 1.5, center.dy - 2)
      ..close();
    canvas.drawPath(trapPath, keyholePaint);
  }

  void _drawDoor(Canvas canvas, Rect rect) {
    // Pulsing glow animation
    final double pulse = (sin(_elapsedTime * 3) + 1) / 2; // 0.0 to 1.0
    final double opacity = 0.4 + (0.6 * pulse); // 0.4 to 1.0

    final Paint doorPaint = Paint()
      ..color = const Color(0xFF00FF88).withOpacity(opacity);

    final RRect rrect = RRect.fromRectAndRadius(
      rect.deflate(4.0),
      const Radius.circular(4.0),
    );
    canvas.drawRRect(rrect, doorPaint);
  }
}
