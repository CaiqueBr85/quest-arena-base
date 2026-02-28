import 'package:flutter/material.dart';

class DPadControls extends StatelessWidget {
  final ValueChanged<String> onMove;

  const DPadControls({super.key, required this.onMove});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Up
        _DirButton(icon: Icons.keyboard_arrow_up, onTap: () => onMove('north')),
        const SizedBox(height: 8),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Left
            _DirButton(
              icon: Icons.keyboard_arrow_left,
              onTap: () => onMove('west'),
            ),
            const SizedBox(width: 8),
            // Center indicator
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: const Color(0xFF16213E).withOpacity(0.5),
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 8),
            // Right
            _DirButton(
              icon: Icons.keyboard_arrow_right,
              onTap: () => onMove('east'),
            ),
          ],
        ),
        const SizedBox(height: 8),
        // Down
        _DirButton(
          icon: Icons.keyboard_arrow_down,
          onTap: () => onMove('south'),
        ),
      ],
    );
  }
}

class _DirButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _DirButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: Ink(
          width: 52,
          height: 52,
          decoration: BoxDecoration(
            color: const Color(0xFF16213E),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: const Color(0xFF53CFFF).withOpacity(0.3),
              width: 2,
            ),
          ),
          child: Icon(icon, color: const Color(0xFF53CFFF), size: 32),
        ),
      ),
    );
  }
}
