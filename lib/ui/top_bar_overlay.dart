import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/game_providers.dart';

class TopBarOverlay extends ConsumerWidget {
  const TopBarOverlay({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final snapshot = ref.watch(gameSnapshotProvider);
    final teamName = ref.watch(teamNameProvider);

    if (snapshot == null || teamName.isEmpty) return const SizedBox.shrink();

    final myPlayer = snapshot.players[teamName];
    if (myPlayer == null) return const SizedBox.shrink();

    final int gemCount = myPlayer.countItemType('gem');
    final int usableCount = myPlayer.usableItems.length;
    final bool inRoom = myPlayer.inRoom != null;

    return Container(
      color: const Color(0xFF16213E).withOpacity(0.9),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Left side: Team name
          Text(
            teamName,
            style: const TextStyle(
              color: Color(0xFF00FF88),
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),

          if (inRoom)
            Container(
              margin: const EdgeInsets.only(left: 12),
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: const Color(0xFFE94560),
                borderRadius: BorderRadius.circular(4),
              ),
              child: const Text(
                'IN ROOM',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 10,
                ),
              ),
            ),

          const Spacer(),

          // Right side: Stats
          _StatBadge(
            icon: Icons.diamond_outlined,
            iconColor: const Color(0xFF00FFFF),
            text: '$gemCount',
          ),
          const SizedBox(width: 12),
          _StatBadge(
            icon: Icons.inventory_2_outlined,
            iconColor: const Color(0xFFAAAAAA),
            text: '$usableCount',
          ),
          const SizedBox(width: 12),
          _StatBadge(
            icon: Icons.star_border,
            iconColor: const Color(0xFFFFD700),
            text: '${myPlayer.score}',
          ),
          const SizedBox(width: 16),

          // Time/Round status
          Text(
            snapshot.gameActive
                ? 'R${snapshot.round} | ${snapshot.timeRemaining}s'
                : 'Lobby',
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatBadge extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String text;

  const _StatBadge({
    required this.icon,
    required this.iconColor,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: iconColor, size: 16),
        const SizedBox(width: 4),
        Text(
          text,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
      ],
    );
  }
}
