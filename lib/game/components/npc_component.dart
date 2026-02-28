import 'dart:math' as math;
import 'dart:ui' as ui;
import 'package:flame/components.dart';
import 'package:flutter/material.dart';

class NpcComponent extends PositionComponent {
  final String npcId;
  Map<String, dynamic> data;

  static const double tileSize = 32.0;

  double _elapsedTime = 0.0;
  Vector2 _targetPosition = Vector2.zero();

  // Visuals
  final Paint _npcPaint = Paint()..color = const Color(0xFFFF6600);
  final Paint _outlinePaint = Paint()
    ..color = const Color(0xFFFFFFFF)
    ..style = PaintingStyle.stroke
    ..strokeWidth = 2.0;

  NpcComponent({required this.npcId, required this.data}) {
    priority = 8; // Render below players (10)
    anchor = Anchor.center;

    // Set initial position instantly
    final int cx = data['x'] as int;
    final int cy = data['y'] as int;
    position = _getTilePosition(cx, cy);
    _targetPosition = position.clone();
  }

  void updateFromData(Map<String, dynamic> newData) {
    data = newData;

    // Update target for lerp
    final int cx = data['x'] as int;
    final int cy = data['y'] as int;
    _targetPosition = _getTilePosition(cx, cy);
  }

  Vector2 _getTilePosition(int tileX, int tileY) {
    return Vector2(tileX * tileSize + 16, tileY * tileSize + 16);
  }

  @override
  void update(double dt) {
    super.update(dt);
    _elapsedTime += dt;

    // Smooth position interpolation
    position.x += (_targetPosition.x - position.x) * (dt * 12).clamp(0, 1);
    position.y += (_targetPosition.y - position.y) * (dt * 12).clamp(0, 1);
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    final double radius = 10.0;

    // Idle bob animation: math.sin(elapsed * 1.2 * 2 * pi) * 1.5 pixels vertical offset
    final double bobOffset = math.sin(_elapsedTime * 1.2 * 2 * math.pi) * 1.5;
    final Offset center = Offset(0, bobOffset);

    // Draw orange circle with white outline
    canvas.drawCircle(center, radius, _npcPaint);
    canvas.drawCircle(center, radius, _outlinePaint);

    // Optional: Draw NPC name/type label
    _renderLabel(canvas, center);
  }

  void _renderLabel(Canvas canvas, Offset anchorOffset) {
    final String typeName =
        (data['npc_type'] as String?)?.toUpperCase() ?? 'NPC';

    final builder =
        ui.ParagraphBuilder(
            ui.ParagraphStyle(
              textAlign: TextAlign.center,
              fontSize: 10,
              height: 1,
            ),
          )
          ..pushStyle(ui.TextStyle(color: const Color(0xFFFFFFFF)))
          ..addText(typeName);

    final paragraph = builder.build()
      ..layout(ui.ParagraphConstraints(width: 80));

    canvas.drawParagraph(paragraph, Offset(-40, anchorOffset.dy - 28));
  }
}
