import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/game_providers.dart';
import 'quest_world.dart';
import 'room_world.dart';
import '../models/game_models.dart';

class QuestArenaGame extends FlameGame with KeyboardEvents {
  final WidgetRef ref;

  static const double tileSize = 32.0;

  late final QuestWorld questWorld;
  late final RoomWorld roomWorld;

  QuestArenaGame(this.ref) : super() {
    questWorld = QuestWorld(ref);
    world = questWorld;
    roomWorld = RoomWorld(ref);
  }

  @override
  Color backgroundColor() => const Color(0xFF0A0A1A);

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    // Setup camera viewfinder
    camera.viewfinder.anchor = Anchor.center;
  }

  void enterRoom(TreasureRoomData room) {
    if (world == roomWorld) return;
    world = roomWorld;
    roomWorld.loadRoom(room);
  }

  void exitRoom() {
    if (world == questWorld) return;
    world = questWorld;
    roomWorld.unloadRoom();
  }

  @override
  KeyEventResult onKeyEvent(
    KeyEvent event,
    Set<LogicalKeyboardKey> keysPressed,
  ) {
    if (event is KeyDownEvent) {
      final ws = ref.read(wsServiceProvider);

      // Movement
      if (keysPressed.contains(LogicalKeyboardKey.arrowUp) ||
          keysPressed.contains(LogicalKeyboardKey.keyW)) {
        ws.move('north');
        return KeyEventResult.handled;
      }
      if (keysPressed.contains(LogicalKeyboardKey.arrowDown) ||
          keysPressed.contains(LogicalKeyboardKey.keyS)) {
        ws.move('south');
        return KeyEventResult.handled;
      }
      if (keysPressed.contains(LogicalKeyboardKey.arrowLeft) ||
          keysPressed.contains(LogicalKeyboardKey.keyA)) {
        ws.move('west');
        return KeyEventResult.handled;
      }
      if (keysPressed.contains(LogicalKeyboardKey.arrowRight) ||
          keysPressed.contains(LogicalKeyboardKey.keyD)) {
        ws.move('east');
        return KeyEventResult.handled;
      }

      // Interaction
      if (keysPressed.contains(LogicalKeyboardKey.keyE)) {
        questWorld.handleInteract();
        return KeyEventResult.handled;
      }

      // Items
      if (keysPressed.contains(LogicalKeyboardKey.keyI)) {
        questWorld.handleUseItem();
        return KeyEventResult.handled;
      }
    }

    return super.onKeyEvent(event, keysPressed);
  }
}
