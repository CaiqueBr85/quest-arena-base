import 'package:flutter_test/flutter_test.dart';
import 'package:quest_arena_client/services/websocket_service.dart';

void main() {
  test('WebSocketService initializes disconnected', () {
    final ws = WebSocketService();
    expect(ws.isConnected, false);
    ws.dispose();
  });
}
