import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/game_providers.dart';
import '../models/game_models.dart';

class NpcDialogueOverlay extends ConsumerStatefulWidget {
  final NpcDialogue dialogue;

  const NpcDialogueOverlay({super.key, required this.dialogue});

  @override
  ConsumerState<NpcDialogueOverlay> createState() => _NpcDialogueOverlayState();
}

class _NpcDialogueOverlayState extends ConsumerState<NpcDialogueOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<int> _textAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _textAnimation = IntTween(
      begin: 0,
      end: widget.dialogue.dialogue.length,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.linear));

    _controller.forward();
  }

  @override
  void didUpdateWidget(NpcDialogueOverlay oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.dialogue.dialogue != widget.dialogue.dialogue) {
      _controller.reset();
      _textAnimation = IntTween(
        begin: 0,
        end: widget.dialogue.dialogue.length,
      ).animate(CurvedAnimation(parent: _controller, curve: Curves.linear));
      _controller.forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // Close on tap background if desired, but requirements say "CLOSE" button
      },
      child: Container(
        color: Colors.black54,
        child: Center(
          child: Container(
            width: 450,
            constraints: const BoxConstraints(minHeight: 180),
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: const Color(0xFF16213E),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: const Color(0xFFFF6600).withOpacity(0.5),
                width: 2,
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFFF6600).withOpacity(0.2),
                  blurRadius: 20,
                  spreadRadius: 5,
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // NPC Name / Type Header
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFF6600).withOpacity(0.2),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.face_retouching_natural,
                        color: Color(0xFFFF6600),
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      widget.dialogue.npcType.toUpperCase(),
                      style: const TextStyle(
                        color: Color(0xFFFF6600),
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        letterSpacing: 1.5,
                      ),
                    ),
                    const Spacer(),
                    if (widget.dialogue.thinking) const _ThinkingDots(),
                  ],
                ),
                const SizedBox(height: 20),

                // Dialogue Text
                AnimatedBuilder(
                  animation: _textAnimation,
                  builder: (context, child) {
                    final text = widget.dialogue.dialogue.substring(
                      0,
                      _textAnimation.value,
                    );
                    return Text(
                      text,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        height: 1.5,
                        fontFamily: 'Roboto',
                      ),
                    );
                  },
                ),

                const SizedBox(height: 32),

                // Actions
                Align(
                  alignment: Alignment.bottomRight,
                  child: TextButton(
                    onPressed: () {
                      ref.read(npcDialogueProvider.notifier).clear();
                    },
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                      backgroundColor: const Color(0xFFFF6600).withOpacity(0.1),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                        side: const BorderSide(color: Color(0xFFFF6600)),
                      ),
                    ),
                    child: const Text(
                      'CLOSE [X]',
                      style: TextStyle(
                        color: Color(0xFFFF6600),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ThinkingDots extends StatefulWidget {
  const _ThinkingDots();

  @override
  State<_ThinkingDots> createState() => _ThinkingDotsState();
}

class _ThinkingDotsState extends State<_ThinkingDots>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final dots = '.' * ((_controller.value * 3).floor() + 1);
        return Text(
          'Thinking $dots',
          style: const TextStyle(
            color: Colors.white54,
            fontSize: 12,
            fontStyle: FontStyle.italic,
          ),
        );
      },
    );
  }
}
