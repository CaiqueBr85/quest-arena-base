import 'package:flutter/material.dart';
import '../models/game_models.dart';

class QuestPanel extends StatefulWidget {
  final Map<String, QuestData> quests;
  final Function(String, String) onSubmitAnswer;

  const QuestPanel({
    super.key,
    required this.quests,
    required this.onSubmitAnswer,
  });

  @override
  State<QuestPanel> createState() => _QuestPanelState();
}

class _QuestPanelState extends State<QuestPanel> {
  final Map<String, TextEditingController> _controllers = {};

  @override
  void dispose() {
    for (final controller in _controllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  TextEditingController _getController(String questId) {
    return _controllers.putIfAbsent(questId, () => TextEditingController());
  }

  @override
  Widget build(BuildContext context) {
    if (widget.quests.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(20),
        child: Center(
          child: Text(
            'No active quests',
            style: TextStyle(color: Colors.white24, fontSize: 12),
          ),
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 12),
      itemCount: widget.quests.length,
      itemBuilder: (context, index) {
        final quest = widget.quests.values.elementAt(index);
        final color = _getQuestColor(quest.questType);

        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: color.withOpacity(0.05),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: color.withOpacity(0.2)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(_getQuestIcon(quest.questType), size: 16, color: color),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      quest.questType.toUpperCase(),
                      style: TextStyle(
                        color: color,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ),
                  Text(
                    '+${quest.reward}',
                    style: const TextStyle(
                      color: Color(0xFF00FF88),
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                quest.description,
                style: const TextStyle(color: Colors.white, fontSize: 12),
              ),

              if (quest.questType == 'riddle') ...[
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _getController(quest.questId),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                        ),
                        decoration: InputDecoration(
                          hintText: 'Your answer...',
                          hintStyle: const TextStyle(color: Colors.white24),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          filled: true,
                          fillColor: Colors.black26,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide.none,
                          ),
                        ),
                        onSubmitted: (val) {
                          if (val.isNotEmpty) {
                            widget.onSubmitAnswer(quest.questId, val);
                            _getController(quest.questId).clear();
                          }
                        },
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      icon: const Icon(Icons.send, size: 20),
                      color: color,
                      onPressed: () {
                        final val = _getController(quest.questId).text;
                        if (val.isNotEmpty) {
                          widget.onSubmitAnswer(quest.questId, val);
                          _getController(quest.questId).clear();
                        }
                      },
                    ),
                  ],
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  Color _getQuestColor(String type) {
    switch (type) {
      case 'riddle':
        return const Color(0xFFDA70D6);
      case 'collect':
        return const Color(0xFF53CFFF);
      case 'exploration':
        return const Color(0xFF00FF88);
      default:
        return Colors.white;
    }
  }

  IconData _getQuestIcon(String type) {
    switch (type) {
      case 'riddle':
        return Icons.psychology_alt;
      case 'collect':
        return Icons.shopping_basket;
      case 'exploration':
        return Icons.explore;
      default:
        return Icons.flag;
    }
  }
}
