import 'package:flutter/material.dart';
import '../models/game_models.dart';

class InventoryPanel extends StatelessWidget {
  final List<InventoryItem> inventory;
  final int speedBoost;
  final bool hasShield;
  final Function(InventoryItem) onUse;

  const InventoryPanel({
    super.key,
    required this.inventory,
    required this.speedBoost,
    required this.hasShield,
    required this.onUse,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Active Effects
        if (speedBoost > 0 || hasShield)
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
            child: Wrap(
              spacing: 8,
              children: [
                if (speedBoost > 0)
                  _EffectBadge(
                    icon: Icons.bolt,
                    label: '${speedBoost}s',
                    color: const Color(0xFF00BFFF),
                  ),
                if (hasShield)
                  const _EffectBadge(
                    icon: Icons.shield,
                    label: 'SHIELD',
                    color: Color(0xFFFFD700),
                  ),
              ],
            ),
          ),

        if (inventory.isEmpty)
          const Padding(
            padding: EdgeInsets.all(20),
            child: Center(
              child: Text(
                'No items',
                style: TextStyle(color: Colors.white24, fontSize: 12),
              ),
            ),
          )
        else
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 12),
            itemCount: inventory.length,
            separatorBuilder: (_, __) => const SizedBox(height: 4),
            itemBuilder: (context, index) {
              final item = inventory[index];
              final color = _getItemColor(item.itemType);

              return Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.03),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: item.usable
                        ? color.withOpacity(0.3)
                        : Colors.white10,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(_getItemIcon(item.itemType), size: 16, color: color),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.name,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            item.description,
                            style: const TextStyle(
                              color: Colors.white38,
                              fontSize: 9,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    if (item.usable)
                      IconButton(
                        visualDensity: VisualDensity.compact,
                        icon: const Icon(Icons.play_arrow, size: 16),
                        color: color,
                        onPressed: () => onUse(item),
                      ),
                  ],
                ),
              );
            },
          ),
      ],
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
        return Colors.white60;
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
      default:
        return Icons.inventory_2_outlined;
    }
  }
}

class _EffectBadge extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _EffectBadge({
    required this.icon,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: color.withOpacity(0.5)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 10, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 9,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
