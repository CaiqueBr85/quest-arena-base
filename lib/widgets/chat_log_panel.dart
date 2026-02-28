import 'package:flutter/material.dart';

class ChatLogPanel extends StatelessWidget {
  final List<String> messages;

  const ChatLogPanel({super.key, required this.messages});

  @override
  Widget build(BuildContext context) {
    // Show last 10 messages, newest at the bottom for standard chat feel,
    // or newest at top if requested. Requirements say "reversed (newest first)".
    final displayMessages = messages.reversed.take(10).toList();

    if (displayMessages.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(20),
        child: Center(
          child: Text(
            'No messages',
            style: TextStyle(color: Colors.white24, fontSize: 11),
          ),
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: displayMessages.length,
      itemBuilder: (context, index) {
        final msg = displayMessages[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 4),
          child: Text(
            msg,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 10,
              height: 1.3,
            ),
          ),
        );
      },
    );
  }
}
