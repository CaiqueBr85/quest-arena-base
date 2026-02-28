/// Quest Arena — WebSocket Service
///
/// Manages the WebSocket connection to the Quest Arena server.
/// Sends client messages and exposes a stream of server messages.
library;

import 'dart:async';
import 'dart:convert';

import 'package:web_socket_channel/web_socket_channel.dart';

class WebSocketService {
  WebSocketChannel? _channel;
  final _messageController = StreamController<Map<String, dynamic>>.broadcast();
  bool _isConnected = false;

  Stream<Map<String, dynamic>> get messages => _messageController.stream;
  bool get isConnected => _isConnected;

  /// Connect to the Quest Arena server.
  void connect(String url) {
    try {
      final uri = Uri.parse(url);
      _channel = WebSocketChannel.connect(uri);
      _isConnected = true;

      _channel!.stream.listen(
        (data) {
          try {
            final decoded = jsonDecode(data as String) as Map<String, dynamic>;
            _messageController.add(decoded);
          } catch (e) {
            // ignore malformed messages
          }
        },
        onDone: () {
          _isConnected = false;
        },
        onError: (error) {
          _isConnected = false;
        },
      );
    } catch (e) {
      _isConnected = false;
    }
  }

  /// Send a JOIN message to register the team.
  void join(String teamName) {
    _send({'type': 'join', 'team_name': teamName});
  }

  /// Send a MOVE message.
  void move(String direction) {
    _send({'type': 'move', 'direction': direction});
  }

  /// Send a quest ACTION (e.g., riddle answer).
  void action(String questId, String answer) {
    _send({'type': 'action', 'quest_id': questId, 'answer': answer});
  }

  /// Send an INTERACT message to talk to an NPC.
  void interact(String npcId) {
    _send({'type': 'interact', 'npc_id': npcId});
  }

  /// Send a USE_ITEM message to use an item from inventory.
  void useItem(String itemId) {
    _send({'type': 'use_item', 'item_id': itemId});
  }

  void _send(Map<String, dynamic> message) {
    if (_channel != null && _isConnected) {
      _channel!.sink.add(jsonEncode(message));
    }
  }

  void disconnect() {
    _channel?.sink.close();
    _isConnected = false;
  }

  void dispose() {
    disconnect();
    _messageController.close();
  }
}
