import 'package:flame/components.dart';
import 'package:flutter/material.dart';

class MapItemComponent extends PositionComponent {
  final String itemId;
  final String itemType;
  final int tileX;
  final int tileY;

  static const double tileSize = 32.0;

  // Colors mapping per item type
  final Map<String, Color> _typeColors = {
    'potion_speed': const Color(0xFF00BFFF),
    'potion_shield': const Color(0xFFFFD700),
    'scroll_reveal': const Color(0xFFDA70D6),
    'key_golden': const Color(0xFFFFE066),
    'compass': const Color(0xFF7FFF7F),
    'trap': const Color(0xFFFF4444),
  };

  late Paint _itemPaint;
  final Paint _outlinePaint = Paint()
    ..color = const Color(0xFFFFFFFF)
    ..style = PaintingStyle.stroke
    ..strokeWidth = 1.5;

  MapItemComponent({
    required this.itemId,
    required this.itemType,
    required this.tileX,
    required this.tileY,
  }) {
    priority = 5; // render below NPCs (8) and players (10)
    anchor = Anchor.center;

    // Position fixed exactly on the tile center
    position = Vector2(tileX * tileSize + 16, tileY * tileSize + 16);

    _itemPaint = Paint()
      ..color = _typeColors[itemType] ?? const Color(0xFFE0E0E0);
  }

  Color getColor() {
    return _typeColors[itemType] ?? const Color(0xFFE0E0E0);
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    // size = tileSize * 0.35 => radius = 11.2 => 22.4 rect
    final double rectSize = tileSize * 0.35 * 2;

    final RRect rrect = RRect.fromRectAndRadius(
      Rect.fromCenter(center: Offset.zero, width: rectSize, height: rectSize),
      const Radius.circular(4.0),
    );

    canvas.drawRRect(rrect, _itemPaint);
    canvas.drawRRect(rrect, _outlinePaint);
  }
}
