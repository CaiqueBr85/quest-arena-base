import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/game_providers.dart';

class RoomHeaderOverlay extends ConsumerWidget {
  const RoomHeaderOverlay({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final roomData = ref.watch(currentRoomProvider);
    if (roomData == null) return const SizedBox.shrink();

    return Container(
      width: double.infinity,
      color: const Color(0xFF16213E).withOpacity(0.9),
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
      child: SafeArea(
        bottom: false,
        child: Row(
          children: [
            const Icon(Icons.meeting_room, color: Color(0xFFE94560), size: 20),
            const SizedBox(width: 12),
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  roomData.theme.toUpperCase(),
                  style: const TextStyle(
                    color: Color(0xFFE94560),
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    letterSpacing: 1.2,
                  ),
                ),
                Text(
                  roomData.description,
                  style: const TextStyle(color: Colors.white70, fontSize: 11),
                ),
              ],
            ),
            const Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.black26,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.white10),
              ),
              child: const Row(
                children: [
                  Icon(
                    Icons.directions_walk,
                    color: Color(0xFF53CFFF),
                    size: 14,
                  ),
                  SizedBox(width: 6),
                  Text(
                    'Walk to EXIT to leave',
                    style: TextStyle(
                      color: Color(0xFF53CFFF),
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
