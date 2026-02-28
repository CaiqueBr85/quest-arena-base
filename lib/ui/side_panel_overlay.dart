import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/game_providers.dart';
import '../models/game_models.dart';

class SidePanelOverlay extends ConsumerWidget {
  const SidePanelOverlay({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final snapshot = ref.watch(gameSnapshotProvider);
    final teamName = ref.watch(teamNameProvider);

    if (snapshot == null || teamName.isEmpty) return const SizedBox.shrink();

    final myPlayer = snapshot.players[teamName];
    if (myPlayer == null) return const SizedBox.shrink();

    return Container(
      width: 240,
      decoration: BoxDecoration(
        color: const Color(0xFF16213E).withOpacity(0.8),
        borderRadius: const BorderRadius.all(Radius.circular(16)),
        border: Border.all(
          color: const Color(0xFF53CFFF).withOpacity(0.2),
          width: 1,
        ),
      ),
      child: ClipRRect(
        borderRadius: const BorderRadius.all(Radius.circular(16)),
        child: Column(
          children: [
            // 1. Leaderboard
            _Header(title: 'TOP TEAMS', icon: Icons.leaderboard),
            _LeaderboardList(leaderboard: snapshot.leaderboard),

            const Divider(color: Colors.white10, height: 1),

            // 2. Room Info (if any)
            if (myPlayer.inRoom != null) ...[
              _Header(title: 'ROOM INFO', icon: Icons.meeting_room),
              _RoomInfo(roomId: myPlayer.inRoom!),
              const Divider(color: Colors.white10, height: 1),
            ],

            // 3. Inventory
            _Header(title: 'INVENTORY', icon: Icons.inventory),
            Expanded(
              child: _InventoryList(
                inventory: myPlayer.inventory,
                onUse: (item) {
                  if (item.usable) {
                    ref.read(wsServiceProvider).useItem(item.itemId);
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  final String title;
  final IconData icon;

  const _Header({required this.title, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      color: Colors.black26,
      child: Row(
        children: [
          Icon(icon, size: 16, color: const Color(0xFF53CFFF)),
          const SizedBox(width: 8),
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 12,
              letterSpacing: 1.2,
            ),
          ),
        ],
      ),
    );
  }
}

class _LeaderboardList extends StatelessWidget {
  final Map<String, int> leaderboard;

  const _LeaderboardList({required this.leaderboard});

  @override
  Widget build(BuildContext context) {
    // Sort and take top 5
    final sortedTeams = leaderboard.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final topTeams = sortedTeams.take(5).toList();

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: topTeams.length,
      itemBuilder: (context, index) {
        final team = topTeams[index];
        final isFirst = index == 0;

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: Row(
            children: [
              Text(
                '${index + 1}.',
                style: TextStyle(
                  color: isFirst ? const Color(0xFFFFD700) : Colors.white54,
                  fontSize: 12,
                  fontWeight: isFirst ? FontWeight.bold : FontWeight.normal,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  team.key,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: isFirst ? Colors.white : Colors.white70,
                    fontSize: 12,
                    fontWeight: isFirst ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
              ),
              Text(
                '${team.value}',
                style: TextStyle(
                  color: isFirst ? const Color(0xFF00FF88) : Colors.white60,
                  fontSize: 12,
                  fontFamily: 'monospace',
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _RoomInfo extends ConsumerWidget {
  final String roomId;

  const _RoomInfo({required this.roomId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final roomData = ref.watch(currentRoomProvider);

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            roomData?.theme.toUpperCase() ?? 'TREASURE ROOM',
            style: const TextStyle(
              color: Color(0xFFE94560),
              fontSize: 10,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            roomData?.description ?? 'Finding hidden secrets...',
            style: const TextStyle(color: Colors.white70, fontSize: 11),
          ),
        ],
      ),
    );
  }
}

class _InventoryList extends StatelessWidget {
  final List<InventoryItem> inventory;
  final Function(InventoryItem) onUse;

  const _InventoryList({required this.inventory, required this.onUse});

  @override
  Widget build(BuildContext context) {
    if (inventory.isEmpty) {
      return const Center(
        child: Text(
          'Empty',
          style: TextStyle(color: Colors.white24, fontSize: 12),
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(12),
      itemCount: inventory.length,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final item = inventory[index];
        final color = _getItemColor(item.itemType);

        return Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: item.usable ? () => onUse(item) : null,
            borderRadius: BorderRadius.circular(8),
            child: Ink(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: item.usable
                    ? color.withOpacity(0.15)
                    : Colors.white.withOpacity(0.05),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: item.usable ? color.withOpacity(0.4) : Colors.white10,
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    _getItemIcon(item.itemType),
                    size: 18,
                    color: item.usable ? color : Colors.white38,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.name,
                          style: TextStyle(
                            color: item.usable ? Colors.white : Colors.white54,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        if (item.description.isNotEmpty)
                          Text(
                            item.description,
                            style: TextStyle(
                              color: item.usable
                                  ? Colors.white60
                                  : Colors.white24,
                              fontSize: 10,
                            ),
                          ),
                      ],
                    ),
                  ),
                  if (item.usable)
                    const Icon(
                      Icons.play_circle_outline,
                      size: 16,
                      color: Colors.white38,
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Color _getItemColor(String type) {
    switch (type) {
      case 'potion_speed':
        return const Color(0xFF00BFFF);
      case 'potion_shield':
        return const Color(0xFFFFD700);
      case 'scroll_reveal':
        return const Color(0xFFDA70D6);
      case 'key_golden':
        return const Color(0xFFFFE066);
      case 'compass':
        return const Color(0xFF7FFF7F);
      case 'trap':
        return const Color(0xFFFF4444);
      default:
        return Colors.white;
    }
  }

  IconData _getItemIcon(String type) {
    switch (type) {
      case 'potion_speed':
        return Icons.bolt;
      case 'potion_shield':
        return Icons.shield;
      case 'scroll_reveal':
        return Icons.map_outlined;
      case 'key_golden':
        return Icons.vpn_key;
      case 'compass':
        return Icons.explore;
      case 'trap':
        return Icons.warning_amber;
      case 'gem':
        return Icons.diamond;
      default:
        return Icons.help_outline;
    }
  }
}
