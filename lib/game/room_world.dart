import 'package:flame/components.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/game_models.dart';
import '../providers/game_providers.dart';
import 'components/room_tile_map_component.dart';
import 'components/room_player_component.dart';
import 'quest_arena_game.dart';

class RoomWorld extends World with HasGameRef<QuestArenaGame> {
  final WidgetRef ref;
  TreasureRoomData? _currentRoom;

  RoomTileMapComponent? _tileMap;
  RoomPlayerComponent? _player;

  RoomWorld(this.ref);

  void loadRoom(TreasureRoomData room) {
    if (_currentRoom?.roomId == room.roomId) return;
    unloadRoom();

    _currentRoom = room;
    _tileMap = RoomTileMapComponent(room.map);
    add(_tileMap!);

    _player = RoomPlayerComponent();
    add(_player!);

    // Center camera on the 10x10 room
    final center = (10 * QuestArenaGame.tileSize) / 2;
    gameRef.camera.viewfinder.position = Vector2(center, center);
    gameRef.camera.viewfinder.zoom = 1.0;
  }

  void unloadRoom() {
    _tileMap?.removeFromParent();
    _player?.removeFromParent();
    _tileMap = null;
    _player = null;
    _currentRoom = null;
  }

  @override
  void update(double dt) {
    super.update(dt);
    final roomData = ref.read(currentRoomProvider);
    final snapshot = ref.read(gameSnapshotProvider);
    final teamName = ref.read(teamNameProvider);

    if (roomData == null || snapshot == null || teamName.isEmpty) return;

    // In rooms, we don't sync all players, just the local one's position
    // logic based on which tile they are in the 10x10 room grid
    final myPlayerData = snapshot.players[teamName];
    if (myPlayerData != null && _player != null) {
      _player!.updatePosition(myPlayerData.x, myPlayerData.y);
    }
  }
}
