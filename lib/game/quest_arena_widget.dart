/// Quest Arena — Game Widget (STARTER STUB)
///
/// This is a placeholder that shows connection status and chat messages.
/// YOUR GOAL: Replace this with a full Flame GameWidget that renders
/// the 20x20 tile map, players, NPCs, items, and Flutter UI overlays.
///
/// See README.md for step-by-step tasks.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quest_arena_client/providers/game_providers.dart';

class QuestArenaWidget extends ConsumerWidget {
  const QuestArenaWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final snapshot = ref.watch(gameSnapshotProvider);
    final chatMessages = ref.watch(chatMessagesProvider);
    final teamName = ref.watch(teamNameProvider);

    if (snapshot == null) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircularProgressIndicator(color: Color(0xFF53CFFF)),
              const SizedBox(height: 16),
              const Text(
                'Waiting for game state...',
                style: TextStyle(color: Colors.white54),
              ),
              if (chatMessages.isNotEmpty) ...[
                const SizedBox(height: 16),
                Text(
                  chatMessages.last,
                  style: const TextStyle(
                    color: Color(0xFF00FF88),
                    fontSize: 12,
                  ),
                ),
              ],
            ],
          ),
        ),
      );
    }

    // ---------------------------------------------------------------
    // PLACEHOLDER: Replace this entire Scaffold with your Flame game!
    // ---------------------------------------------------------------
    final myPlayer = snapshot.players[teamName];

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Status header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF16213E),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Team: $teamName',
                    style: const TextStyle(
                      color: Color(0xFF00FF88),
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Map: ${snapshot.map.length}x${snapshot.map[0].length}  |  '
                    'Players: ${snapshot.players.length}  |  '
                    'Score: ${myPlayer?.score ?? 0}  |  '
                    'Round: ${snapshot.round}  |  '
                    '${snapshot.gameActive ? "${snapshot.timeRemaining}s left" : "Lobby"}',
                    style: const TextStyle(color: Colors.white70, fontSize: 14),
                  ),
                  if (myPlayer != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      'Position: (${myPlayer.x}, ${myPlayer.y})  |  '
                      'Inventory: ${myPlayer.inventory.length} items  |  '
                      'NPCs: ${snapshot.npcs.length}',
                      style: const TextStyle(
                        color: Colors.white54,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ],
              ),
            ),

            const SizedBox(height: 16),
            const Text(
              'Server messages are flowing! Now build the game.',
              style: TextStyle(
                color: Color(0xFFE94560),
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'See README.md for tasks. Start with Task 1: Tile Map Component.',
              style: TextStyle(color: Colors.white38, fontSize: 12),
            ),

            const SizedBox(height: 16),

            // Chat log
            const Text(
              'LOG',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFF16213E),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: ListView.builder(
                  reverse: true,
                  itemCount: chatMessages.length,
                  itemBuilder: (_, i) {
                    final msg = chatMessages[chatMessages.length - 1 - i];
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 2),
                      child: Text(
                        msg,
                        style: const TextStyle(
                          color: Colors.white54,
                          fontSize: 12,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
