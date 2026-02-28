/// Quest Arena — Game Widget (STARTER STUB)
///
/// This is a placeholder that shows connection status and chat messages.
/// YOUR GOAL: Replace this with a full Flame GameWidget that renders
/// the 20x20 tile map, players, NPCs, items, and Flutter UI overlays.
///
/// See README.md for step-by-step tasks.
library;

import 'dart:async';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quest_arena_client/providers/game_providers.dart';
import 'package:quest_arena_client/game/quest_arena_game.dart';
import '../ui/top_bar_overlay.dart';
import '../ui/dpad_overlay.dart';

// import 'overlays/side_panel_overlay.dart';
// import 'overlays/npc_dialogue_overlay.dart';
// import 'overlays/item_toast_overlay.dart';

class QuestArenaWidget extends ConsumerStatefulWidget {
  const QuestArenaWidget({super.key});

  @override
  ConsumerState<QuestArenaWidget> createState() => _QuestArenaWidgetState();
}

class _QuestArenaWidgetState extends ConsumerState<QuestArenaWidget> {
  late QuestArenaGame _game;
  Timer? _itemEffectTimer;

  @override
  void initState() {
    super.initState();
    _game = QuestArenaGame(ref);
  }

  @override
  void dispose() {
    _itemEffectTimer?.cancel();
    super.dispose();
  }

  void _scheduleItemEffectDismissal() {
    _itemEffectTimer?.cancel();
    _itemEffectTimer = Timer(const Duration(seconds: 3), () {
      if (mounted) {
        ref.read(itemEffectProvider.notifier).clear();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final snapshot = ref.watch(gameSnapshotProvider);
    // ignore: unused_local_variable
    final npcDialogue = ref.watch(npcDialogueProvider);
    // ignore: unused_local_variable
    final itemEffect = ref.watch(itemEffectProvider);

    // Auto-dismiss item effect
    ref.listen<Object?>(itemEffectProvider, (previous, next) {
      if (next != null) {
        _scheduleItemEffectDismissal();
      }
    });

    if (snapshot == null) {
      return Scaffold(
        backgroundColor: const Color(0xFF0A0A1A),
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: const [
              CircularProgressIndicator(color: Color(0xFF53CFFF)),
              SizedBox(height: 16),
              Text(
                'Waiting for game state...',
                style: TextStyle(color: Colors.white54),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFF0A0A1A),
      body: Stack(
        children: [
          // 1. Core Flame Game Layer (Takes up the whole screen space initially)
          Positioned.fill(child: GameWidget<QuestArenaGame>(game: _game)),

          // 2. Overlays Layer (Commented out until Tasks 8-12 are done)
          const Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SafeArea(child: TopBarOverlay()),
          ),

          const Positioned(
            bottom: 32,
            left: 0,
            right: 0,
            child: SafeArea(child: DPadOverlay()),
          ),

          /*

          const Positioned(
            top: 80,
            right: 16,
            bottom: 16,
            child: SafeArea(child: SidePanelOverlay()),
          ),
          */

          // 3. Conditional Overlays
          /*
          if (npcDialogue != null)
            Positioned.fill(
              child: NpcDialogueOverlay(dialogue: npcDialogue),
            ),
            
          if (itemEffect != null)
            Positioned(
              bottom: 120,
              left: 0,
              right: 0,
              child: Center(child: ItemToastOverlay(effect: itemEffect)),
            ),
          */
        ],
      ),
    );
  }
}
