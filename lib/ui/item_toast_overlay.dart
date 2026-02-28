import 'package:flutter/material.dart';
import '../models/game_models.dart';

class ItemToastOverlay extends StatelessWidget {
  final ItemEffect effect;

  const ItemToastOverlay({super.key, required this.effect});

  @override
  Widget build(BuildContext context) {
    final color = _getEffectColor();
    final icon = _getEffectIcon();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF16213E).withOpacity(0.95),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: color, width: 2),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.3),
            blurRadius: 12,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(width: 12),
          Text(
            effect.message,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  Color _getEffectColor() {
    if (!effect.success && effect.action == 'use') return Colors.redAccent;

    switch (effect.action) {
      case 'pickup':
        return const Color(0xFF00FF88);
      case 'use':
        return const Color(0xFF53CFFF);
      case 'trap_triggered':
        return const Color(0xFFFF4444);
      default:
        return Colors.white70;
    }
  }

  IconData _getEffectIcon() {
    switch (effect.action) {
      case 'pickup':
        return Icons.add_circle_outline;
      case 'use':
        return Icons.play_circle_filled;
      case 'trap_triggered':
        return Icons.warning;
      default:
        return Icons.info_outline;
    }
  }
}
