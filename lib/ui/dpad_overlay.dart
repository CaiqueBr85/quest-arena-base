import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/game_providers.dart';
import '../widgets/dpad_controls.dart';

class DPadOverlay extends ConsumerWidget {
  const DPadOverlay({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ws = ref.read(wsServiceProvider);

    return Container(
      padding: const EdgeInsets.only(left: 16, bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // The D-Pad
          DPadControls(
            onMove: (direction) {
              ws.move(direction);
            },
          ),

          const SizedBox(width: 48), // Padding equivalent to Spacer
          // Action Buttons
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _ActionButton(
                label: 'USE [I]',
                color: const Color(0xFF00BFFF),
                icon: Icons.inventory_2,
                onTap: () => _handleUseItem(ref),
              ),
              const SizedBox(height: 16),
              _ActionButton(
                label: 'TALK [E]',
                color: const Color(0xFFFF6600),
                icon: Icons.chat_bubble_outline,
                onTap: () => _handleTalk(ref),
              ),
            ],
          ),

          // Padding roughly leaving space for side panel overlay
          const SizedBox(width: 250),
        ],
      ),
    );
  }

  void _handleTalk(WidgetRef ref) {
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

  void _handleUseItem(WidgetRef ref) {
    final snapshot = ref.read(gameSnapshotProvider);
    final teamName = ref.read(teamNameProvider);
    final ws = ref.read(wsServiceProvider);

    if (snapshot == null || teamName.isEmpty) return;

    final myPlayer = snapshot.players[teamName];
    if (myPlayer == null) return;

    if (myPlayer.usableItems.isNotEmpty) {
      ws.useItem(myPlayer.usableItems.first.itemId);
    }
  }
}

class _ActionButton extends StatelessWidget {
  final String label;
  final Color color;
  final IconData icon;
  final VoidCallback onTap;

  const _ActionButton({
    required this.label,
    required this.color,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Ink(
          width: 80,
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: color.withOpacity(0.2),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: color, width: 2),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: color, size: 28),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
