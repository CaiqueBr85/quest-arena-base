/// Quest Arena — Riverpod Providers
///
/// State management for the Flutter client using Riverpod.
library;

import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quest_arena_client/models/game_models.dart';
import 'package:quest_arena_client/services/websocket_service.dart';

/// The WebSocket service singleton.
final wsServiceProvider = Provider<WebSocketService>((ref) {
  final service = WebSocketService();
  ref.onDispose(() => service.dispose());
  return service;
});

/// Connection state.
final isConnectedProvider = NotifierProvider<IsConnectedNotifier, bool>(
  IsConnectedNotifier.new,
);

class IsConnectedNotifier extends Notifier<bool> {
  @override
  bool build() => false;

  void set(bool value) => state = value;
}

/// The team name for this client.
final teamNameProvider = NotifierProvider<TeamNameNotifier, String>(
  TeamNameNotifier.new,
);

class TeamNameNotifier extends Notifier<String> {
  @override
  String build() => '';

  void set(String value) => state = value;
}

/// The latest game snapshot from the server.
final gameSnapshotProvider =
    NotifierProvider<GameSnapshotNotifier, GameSnapshot?>(
      GameSnapshotNotifier.new,
    );

class GameSnapshotNotifier extends Notifier<GameSnapshot?> {
  @override
  GameSnapshot? build() => null;

  void set(GameSnapshot? value) => state = value;
}

/// Chat/notification messages.
final chatMessagesProvider = NotifierProvider<ChatNotifier, List<String>>(
  ChatNotifier.new,
);

class ChatNotifier extends Notifier<List<String>> {
  @override
  List<String> build() => [];

  void add(String message) {
    state = [...state, message];
    if (state.length > 50) {
      state = state.sublist(state.length - 50);
    }
  }
}

/// NPC dialogue state — holds the latest dialogue to display.
final npcDialogueProvider = NotifierProvider<NpcDialogueNotifier, NpcDialogue?>(
  NpcDialogueNotifier.new,
);

class NpcDialogueNotifier extends Notifier<NpcDialogue?> {
  @override
  NpcDialogue? build() => null;

  void set(NpcDialogue? value) => state = value;

  void clear() => state = null;
}

/// Latest item effect notification — shown briefly when items are picked up or used.
final itemEffectProvider = NotifierProvider<ItemEffectNotifier, ItemEffect?>(
  ItemEffectNotifier.new,
);

class ItemEffectNotifier extends Notifier<ItemEffect?> {
  @override
  ItemEffect? build() => null;

  void set(ItemEffect? value) => state = value;

  void clear() => state = null;
}

/// Current room data — non-null when the local player is inside a treasure room.
final currentRoomProvider =
    NotifierProvider<CurrentRoomNotifier, TreasureRoomData?>(
      CurrentRoomNotifier.new,
    );

class CurrentRoomNotifier extends Notifier<TreasureRoomData?> {
  @override
  TreasureRoomData? build() => null;

  void set(TreasureRoomData? value) => state = value;

  void clear() => state = null;
}

/// Processes incoming WebSocket messages at the provider level so no messages
/// are lost between screen transitions.
final messageHandlerProvider = NotifierProvider<MessageHandlerNotifier, bool>(
  MessageHandlerNotifier.new,
);

class MessageHandlerNotifier extends Notifier<bool> {
  StreamSubscription<Map<String, dynamic>>? _subscription;

  @override
  bool build() => false;

  /// Start listening to WebSocket messages. Call once after [ws.connect].
  void start() {
    _subscription?.cancel();
    final ws = ref.read(wsServiceProvider);
    _subscription = ws.messages.listen(_handleMessage);
    state = true;
  }

  void _handleMessage(Map<String, dynamic> raw) {
    final type = raw['type'] as String?;
    final data = raw['data'] as Map<String, dynamic>? ?? raw;

    switch (type) {
      case 'welcome':
        ref
            .read(chatMessagesProvider.notifier)
            .add('Connected! You are at position ${data['position']}');

      case 'state_update':
        ref
            .read(gameSnapshotProvider.notifier)
            .set(GameSnapshot.fromJson(data));

      case 'quest_assigned':
        ref
            .read(chatMessagesProvider.notifier)
            .add('New quest: ${data['description'] ?? 'unknown'}');

      case 'quest_result':
        final success = data['success'] as bool? ?? false;
        if (success) {
          ref
              .read(chatMessagesProvider.notifier)
              .add('Quest completed! +${data['reward']} points');
        } else {
          ref
              .read(chatMessagesProvider.notifier)
              .add('Quest failed: ${data['hint'] ?? 'Try again'}');
        }

      case 'leaderboard':
        break;

      case 'chat':
        ref
            .read(chatMessagesProvider.notifier)
            .add(data['message'] as String? ?? '');

      case 'npc_dialogue':
        ref.read(npcDialogueProvider.notifier).set(NpcDialogue.fromJson(data));

      case 'item_effect':
        final effect = ItemEffect.fromJson(data);
        ref.read(itemEffectProvider.notifier).set(effect);
        ref.read(chatMessagesProvider.notifier).add(effect.message);

      case 'room_enter':
        final roomData = data['room_data'] as Map<String, dynamic>?;
        if (roomData != null) {
          ref
              .read(currentRoomProvider.notifier)
              .set(TreasureRoomData.fromJson(roomData));
        }
        final roomId = data['room_id'] as String? ?? '?';
        ref
            .read(chatMessagesProvider.notifier)
            .add('Entered treasure room: $roomId');

      case 'room_exit':
        ref.read(currentRoomProvider.notifier).clear();
        final roomId = data['room_id'] as String? ?? '?';
        ref
            .read(chatMessagesProvider.notifier)
            .add('Exited treasure room: $roomId');

      case 'round_start':
        ref
            .read(chatMessagesProvider.notifier)
            .add(
              'Round ${data['round']} started! Duration: ${data['duration']}s',
            );

      case 'round_end':
        ref
            .read(chatMessagesProvider.notifier)
            .add('Round ${data['round']} ended!');

      case 'error':
        ref
            .read(chatMessagesProvider.notifier)
            .add('Error: ${data['message'] ?? 'unknown error'}');
    }
  }

  void stop() {
    _subscription?.cancel();
    _subscription = null;
    state = false;
  }
}
