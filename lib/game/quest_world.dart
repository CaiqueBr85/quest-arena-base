import 'package:flame/components.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/game_providers.dart';
import 'components/player_component.dart';
import 'components/tile_map_component.dart';

class QuestWorld extends World {
  final WidgetRef ref;

  late TileMapComponent tileMap;
  final Map<String, PlayerComponent> _players = {};

  QuestWorld(this.ref);

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    tileMap = TileMapComponent();
    add(tileMap);
  }

  @override
  void update(double dt) {
    super.update(dt);

    final snapshot = ref.read(gameSnapshotProvider);
    final teamName = ref.read(teamNameProvider);

    if (snapshot == null) return;

    // 1. Sync Map
    tileMap.updateMap(snapshot.map);

    // 2. Sync Players
    final serverPlayers = snapshot.players.keys.toSet();
    final localPlayers = _players.keys.toSet();

    // Remove disconnected players
    final toRemove = localPlayers.difference(serverPlayers);
    for (final id in toRemove) {
      final comp = _players.remove(id);
      if (comp != null) {
        comp.removeFromParent();
      }
    }

    // Add or update players
    for (final id in serverPlayers) {
      final playerData = snapshot.players[id]!;
      final isLocal = (id == teamName);

      if (!_players.containsKey(id)) {
        // Add new player
        final newPlayer = PlayerComponent(
          teamName: id,
          data: playerData,
          isLocalPlayer: isLocal,
        );
        _players[id] = newPlayer;
        add(newPlayer);
      } else {
        // Update existing player
        _players[id]!.updateFromData(playerData, isLocal);
      }
    }

    // 3. Camera Follow Logic
    final myPlayerComp = _players[teamName];
    if (myPlayerComp != null) {
      final cam = findGame()!.camera;

      final targetX = myPlayerComp.position.x;
      final targetY = myPlayerComp.position.y;

      cam.viewfinder.position = Vector2(
        cam.viewfinder.position.x +
            (targetX - cam.viewfinder.position.x) * 0.15,
        cam.viewfinder.position.y +
            ((targetY - 160) - cam.viewfinder.position.y) * 0.15,
      );
    }
  }

  void handleInteract() {
    final snapshot = ref.read(gameSnapshotProvider);
    final teamName = ref.read(teamNameProvider);
    final ws = ref.read(wsServiceProvider);

    if (snapshot == null || teamName.isEmpty) return;

    final myPlayer = snapshot.players[teamName];
    if (myPlayer == null) return;

    // Find nearest NPC within Manhattan distance <= 2
    String? nearestNpcId;
    for (final entry in snapshot.npcs.entries) {
      final npc = entry.value as Map<String, dynamic>;
      final dist =
          (myPlayer.x - npc['x']).abs() + (myPlayer.y - npc['y']).abs();

      if (dist <= 2) {
        nearestNpcId = entry.key;
        break; // Found one, stop checking
      }
    }

    if (nearestNpcId != null) {
      ws.interact(nearestNpcId);
    }
  }

  void handleUseItem() {
    final snapshot = ref.read(gameSnapshotProvider);
    final teamName = ref.read(teamNameProvider);
    final ws = ref.read(wsServiceProvider);

    if (snapshot == null || teamName.isEmpty) return;

    final myPlayer = snapshot.players[teamName];
    if (myPlayer == null) return;

    // Use the first usable item in the inventory an example
    if (myPlayer.usableItems.isNotEmpty) {
      ws.useItem(myPlayer.usableItems.first.itemId);
    }
  }
}
