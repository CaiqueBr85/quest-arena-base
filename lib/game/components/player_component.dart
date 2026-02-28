import 'dart:ui';
import 'package:flame/components.dart';
import '../../models/game_models.dart';

class PlayerComponent extends PositionComponent {
  final String teamName;
  bool isLocalPlayer;
  PlayerData data;

  static const double tileSize = 32.0;

  // Visuals
  final Paint _localPaint = Paint()..color = const Color(0xFF00FF88);
  final Paint _otherPaint = Paint()..color = const Color(0xFF53CFFF);

  final Paint _shieldPaint = Paint()
    ..color = const Color(0xFFFFD700)
    ..style = PaintingStyle.stroke
    ..strokeWidth = 2.0;

  final Paint _boostPaint = Paint()
    ..color = const Color(0xFF00BFFF)
    ..style = PaintingStyle.stroke
    ..strokeWidth = 2.0;

  Vector2 _targetPosition = Vector2.zero();

  PlayerComponent({
    required this.teamName,
    required this.data,
    required this.isLocalPlayer,
  }) {
    priority = 10;
    anchor = Anchor.center;
    // Set initial position instantly
    position = _getTilePosition(data.x, data.y);
    _targetPosition = position.clone();
  }

  void updateFromData(PlayerData newData, bool isMe) {
    data = newData;
    isLocalPlayer = isMe;

    // Update target for lerp
    _targetPosition = _getTilePosition(data.x, data.y);
  }

  Vector2 _getTilePosition(int tileX, int tileY) {
    return Vector2(tileX * tileSize + 16, tileY * tileSize + 16);
  }

  @override
  void update(double dt) {
    super.update(dt);

    // Smooth position interpolation
    position.x += (_targetPosition.x - position.x) * (dt * 12).clamp(0, 1);
    position.y += (_targetPosition.y - position.y) * (dt * 12).clamp(0, 1);
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    final double radius = 10.0;

    // Base coordinate since anchor is center
    final Offset center = Offset.zero;

    // Optional Rings (shield / speed)
    if (data.hasShield) {
      canvas.drawCircle(center, radius + 4, _shieldPaint);
    }
    if (data.speedBoost > 0) {
      canvas.drawCircle(center, radius + 7, _boostPaint);
    }

    // Core player circle
    canvas.drawCircle(
      center,
      radius,
      isLocalPlayer ? _localPaint : _otherPaint,
    );

    // Name Label above
    _renderLabel(canvas);
  }

  void _renderLabel(Canvas canvas) {
    final builder =
        ParagraphBuilder(
            ParagraphStyle(
              textAlign: TextAlign.center,
              fontSize: 10,
              height: 1, // tight line height
            ),
          )
          ..pushStyle(TextStyle(color: const Color(0xFFFFFFFF)))
          ..addText(teamName);

    final paragraph = builder.build()
      ..layout(const ParagraphConstraints(width: 80));

    // Offset above the circle and offset horizontally by half the width
    canvas.drawParagraph(paragraph, const Offset(-40, -32));
  }
}
