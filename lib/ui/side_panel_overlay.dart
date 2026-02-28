import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/game_providers.dart';
import '../widgets/inventory_panel.dart';
import '../widgets/quest_panel.dart';
import '../widgets/leaderboard_panel.dart';
import '../widgets/chat_log_panel.dart';

class SidePanelOverlay extends ConsumerWidget {
  const SidePanelOverlay({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final snapshot = ref.watch(gameSnapshotProvider);
    final teamName = ref.watch(teamNameProvider);
    final chatMessages = ref.watch(chatMessagesProvider);

    if (snapshot == null || teamName.isEmpty) return const SizedBox.shrink();

    final myPlayer = snapshot.players[teamName];
    if (myPlayer == null) return const SizedBox.shrink();

    return Container(
      width: 280,
      decoration: BoxDecoration(
        color: const Color(0xFF16213E).withOpacity(0.9),
        borderRadius: const BorderRadius.horizontal(left: Radius.circular(20)),
        border: Border.all(
          color: const Color(0xFF53CFFF).withOpacity(0.1),
          width: 1,
        ),
      ),
      child: ClipRRect(
        borderRadius: const BorderRadius.horizontal(left: Radius.circular(20)),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 1. Inventory
              _SectionHeader(title: 'INVENTORY', icon: Icons.inventory),
              InventoryPanel(
                inventory: myPlayer.inventory,
                speedBoost: myPlayer.speedBoost,
                hasShield: myPlayer.hasShield,
                onUse: (item) {
                  ref.read(wsServiceProvider).useItem(item.itemId);
                },
              ),
              const Divider(color: Colors.white10),

              // 2. Quests
              _SectionHeader(title: 'ACTIVE QUESTS', icon: Icons.assignment),
              QuestPanel(
                quests: snapshot.quests,
                onSubmitAnswer: (id, answer) {
                  ref.read(wsServiceProvider).action(id, answer);
                },
              ),
              const Divider(color: Colors.white10),

              // 3. Leaderboard
              _SectionHeader(title: 'TOP TEAMS', icon: Icons.emoji_events),
              LeaderboardPanel(
                leaderboard: snapshot.leaderboard,
                localTeamName: teamName,
              ),
              const Divider(color: Colors.white10),

              // 4. Chat Log
              _SectionHeader(title: 'MESSAGES', icon: Icons.chat_bubble),
              ChatLogPanel(messages: chatMessages),
            ],
          ),
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final IconData icon;

  const _SectionHeader({required this.title, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
      child: Row(
        children: [
          Icon(icon, size: 14, color: const Color(0xFF53CFFF)),
          const SizedBox(width: 8),
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 10,
              letterSpacing: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}
