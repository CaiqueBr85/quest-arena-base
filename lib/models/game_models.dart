/// Quest Arena — Server message models
///
/// Mirrors the JSON protocol defined on the server side.
library;

class ServerMessage {
  final String type;
  final Map<String, dynamic> data;

  ServerMessage({required this.type, this.data = const {}});

  factory ServerMessage.fromJson(Map<String, dynamic> json) {
    return ServerMessage(
      type: json['type'] as String,
      data: json['data'] as Map<String, dynamic>? ?? {},
    );
  }
}

/// Represents an item in a player's inventory (structured, not just a string).
class InventoryItem {
  final String itemId;
  final String itemType;
  final String name;
  final String description;
  final bool usable;

  InventoryItem({
    required this.itemId,
    required this.itemType,
    required this.name,
    required this.description,
    required this.usable,
  });

  factory InventoryItem.fromJson(Map<String, dynamic> json) {
    return InventoryItem(
      itemId: json['item_id'] as String? ?? '',
      itemType: json['item_type'] as String? ?? '',
      name: json['name'] as String? ?? '',
      description: json['description'] as String? ?? '',
      usable: json['usable'] as bool? ?? false,
    );
  }
}

/// An item placed on the map, waiting to be picked up.
class MapItemData {
  final String itemId;
  final String itemType;
  final int x;
  final int y;

  MapItemData({
    required this.itemId,
    required this.itemType,
    required this.x,
    required this.y,
  });

  factory MapItemData.fromJson(String id, Map<String, dynamic> json) {
    return MapItemData(
      itemId: id,
      itemType: json['item_type'] as String? ?? '',
      x: json['x'] as int? ?? 0,
      y: json['y'] as int? ?? 0,
    );
  }
}

class PlayerData {
  final int x;
  final int y;
  final int score;
  final List<InventoryItem> inventory;
  final int speedBoost;
  final bool hasShield;
  final String?
  inRoom; // room_id if player is inside a treasure room, null otherwise

  PlayerData({
    required this.x,
    required this.y,
    required this.score,
    required this.inventory,
    this.speedBoost = 0,
    this.hasShield = false,
    this.inRoom,
  });

  factory PlayerData.fromJson(Map<String, dynamic> json) {
    final rawInventory = json['inventory'] as List? ?? [];
    final inventory = rawInventory.map((item) {
      if (item is Map<String, dynamic>) {
        return InventoryItem.fromJson(item);
      }
      // Fallback for legacy string inventory (shouldn't happen with updated server)
      return InventoryItem(
        itemId: '',
        itemType: item.toString(),
        name: item.toString(),
        description: '',
        usable: false,
      );
    }).toList();

    return PlayerData(
      x: json['x'] as int,
      y: json['y'] as int,
      score: json['score'] as int,
      inventory: inventory,
      speedBoost: json['speed_boost'] as int? ?? 0,
      hasShield: json['has_shield'] as bool? ?? false,
      inRoom: json['in_room'] as String?,
    );
  }

  /// Count items of a specific type.
  int countItemType(String type) =>
      inventory.where((i) => i.itemType == type).length;

  /// Get usable items only.
  List<InventoryItem> get usableItems =>
      inventory.where((i) => i.usable).toList();
}

class QuestData {
  final String questId;
  final String description;
  final String questType;
  final Map<String, dynamic> goal;
  final String status;
  final int reward;

  QuestData({
    required this.questId,
    required this.description,
    required this.questType,
    required this.goal,
    required this.status,
    required this.reward,
  });

  factory QuestData.fromJson(String id, Map<String, dynamic> json) {
    return QuestData(
      questId: id,
      description: json['description'] as String,
      questType: json['quest_type'] as String,
      goal: json['goal'] as Map<String, dynamic>? ?? {},
      status: json['status'] as String,
      reward: json['reward'] as int,
    );
  }
}

class NpcDialogue {
  final String npcId;
  final String npcType;
  final String dialogue;
  final bool thinking;

  NpcDialogue({
    required this.npcId,
    required this.npcType,
    required this.dialogue,
    this.thinking = false,
  });

  factory NpcDialogue.fromJson(Map<String, dynamic> json) {
    return NpcDialogue(
      npcId: json['npc_id'] as String? ?? '',
      npcType: json['npc_type'] as String? ?? 'patrol',
      dialogue: json['dialogue'] as String? ?? '',
      thinking: json['thinking'] as bool? ?? false,
    );
  }
}

/// Data for an item_effect server message.
class ItemEffect {
  final String action; // "pickup", "use", "trap_triggered"
  final bool success;
  final String itemType;
  final String message;
  final List<Map<String, dynamic>>? gems; // only for scroll_reveal

  ItemEffect({
    required this.action,
    this.success = true,
    this.itemType = '',
    required this.message,
    this.gems,
  });

  factory ItemEffect.fromJson(Map<String, dynamic> json) {
    final gemsRaw = json['gems'] as List?;
    return ItemEffect(
      action: json['action'] as String? ?? '',
      success: json['success'] as bool? ?? true,
      itemType: json['item_type'] as String? ?? '',
      message: json['message'] as String? ?? '',
      gems: gemsRaw?.map((g) => Map<String, dynamic>.from(g as Map)).toList(),
    );
  }
}

/// Data for a treasure room sub-map (AI-generated 10x10 grid).
class TreasureRoomData {
  final String roomId;
  final String theme;
  final String description;
  final List<List<String>> map; // 10x10 grid of tile type strings
  final List<int> exitPortal; // [x, y] of exit portal
  final List<int> doorPosition; // [x, y] on the main map

  TreasureRoomData({
    required this.roomId,
    required this.theme,
    required this.description,
    required this.map,
    required this.exitPortal,
    required this.doorPosition,
  });

  factory TreasureRoomData.fromJson(Map<String, dynamic> json) {
    final mapJson = json['map'] as List? ?? [];
    final exitJson = json['exit_portal'] as List? ?? [0, 0];
    final doorJson = json['door_position'] as List? ?? [0, 0];
    return TreasureRoomData(
      roomId: json['room_id'] as String? ?? '',
      theme: json['theme'] as String? ?? 'default',
      description: json['description'] as String? ?? '',
      map: mapJson.map((row) => List<String>.from(row as List)).toList(),
      exitPortal: exitJson.map((v) => v as int).toList(),
      doorPosition: doorJson.map((v) => v as int).toList(),
    );
  }
}

class GameSnapshot {
  final List<List<String>> map;
  final Map<String, PlayerData> players;
  final Map<String, dynamic> npcs;
  final Map<String, QuestData> quests;
  final Map<String, MapItemData> items;
  final Map<String, TreasureRoomData> rooms;
  final int round;
  final int timeRemaining;
  final bool gameActive;
  final Map<String, int> leaderboard;

  GameSnapshot({
    required this.map,
    required this.players,
    required this.npcs,
    required this.quests,
    required this.items,
    required this.rooms,
    required this.round,
    required this.timeRemaining,
    required this.gameActive,
    required this.leaderboard,
  });

  factory GameSnapshot.fromJson(Map<String, dynamic> json) {
    final playersJson = json['players'] as Map<String, dynamic>? ?? {};
    final questsJson = json['quests'] as Map<String, dynamic>? ?? {};
    final itemsJson = json['items'] as Map<String, dynamic>? ?? {};
    final roomsJson = json['rooms'] as Map<String, dynamic>? ?? {};
    final mapJson = json['map'] as List? ?? [];
    final lbJson = json['leaderboard'] as Map<String, dynamic>? ?? {};

    return GameSnapshot(
      map: mapJson.map((row) => List<String>.from(row as List)).toList(),
      players: playersJson.map(
        (k, v) => MapEntry(k, PlayerData.fromJson(v as Map<String, dynamic>)),
      ),
      npcs: json['npcs'] as Map<String, dynamic>? ?? {},
      quests: questsJson.map(
        (k, v) => MapEntry(k, QuestData.fromJson(k, v as Map<String, dynamic>)),
      ),
      items: itemsJson.map(
        (k, v) =>
            MapEntry(k, MapItemData.fromJson(k, v as Map<String, dynamic>)),
      ),
      rooms: roomsJson.map(
        (k, v) =>
            MapEntry(k, TreasureRoomData.fromJson(v as Map<String, dynamic>)),
      ),
      round: json['round'] as int? ?? 0,
      timeRemaining: json['time_remaining'] as int? ?? 0,
      gameActive: json['game_active'] as bool? ?? false,
      leaderboard: lbJson.map((k, v) => MapEntry(k, v as int)),
    );
  }
}
