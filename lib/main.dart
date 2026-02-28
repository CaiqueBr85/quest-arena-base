/// Quest Arena — Flutter Client Entry Point
///
/// Two-screen app:
///   1. JoinScreen — enter server URL + team name, connect via WebSocket.
///   2. QuestArenaWidget — Flame game canvas + Flutter overlays (YOUR TASK!).
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quest_arena_client/game/quest_arena_widget.dart';
import 'package:quest_arena_client/providers/game_providers.dart';

void main() {
  runApp(const ProviderScope(child: QuestArenaApp()));
}

// ---------------------------------------------------------------------------
// App root
// ---------------------------------------------------------------------------
class QuestArenaApp extends StatelessWidget {
  const QuestArenaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Quest Arena',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF0A0A1A),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF0F3460),
          brightness: Brightness.dark,
        ),
      ),
      home: const JoinScreen(),
    );
  }
}

// ---------------------------------------------------------------------------
// Join Screen
// ---------------------------------------------------------------------------
class JoinScreen extends ConsumerStatefulWidget {
  const JoinScreen({super.key});

  @override
  ConsumerState<JoinScreen> createState() => _JoinScreenState();
}

class _JoinScreenState extends ConsumerState<JoinScreen> {
  final _serverController = TextEditingController(
    text: 'ws://localhost:8000/ws',
  );
  final _teamController = TextEditingController();
  bool _connecting = false;
  String? _error;

  @override
  void dispose() {
    _serverController.dispose();
    _teamController.dispose();
    super.dispose();
  }

  void _connect() {
    final teamName = _teamController.text.trim();
    final serverUrl = _serverController.text.trim();

    if (teamName.isEmpty) {
      setState(() => _error = 'Please enter a team name');
      return;
    }
    if (serverUrl.isEmpty) {
      setState(() => _error = 'Please enter a server URL');
      return;
    }

    setState(() {
      _connecting = true;
      _error = null;
    });

    final ws = ref.read(wsServiceProvider);
    ws.connect(serverUrl);

    // Start provider-level message handler BEFORE navigating
    ref.read(messageHandlerProvider.notifier).start();

    // Store team name in provider
    ref.read(teamNameProvider.notifier).set(teamName);
    ref.read(isConnectedProvider.notifier).set(true);

    // Send join message
    ws.join(teamName);

    // Navigate to game screen (Flame)
    if (mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const QuestArenaWidget()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(32),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 400),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.sports_esports,
                  size: 72,
                  color: Color(0xFFE94560),
                ),
                const SizedBox(height: 16),
                const Text(
                  'QUEST ARENA',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: 4,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Multiplayer Real-Time Quest Game',
                  style: TextStyle(color: Colors.white54, fontSize: 14),
                ),
                const SizedBox(height: 40),
                TextField(
                  controller: _serverController,
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(
                    labelText: 'Server URL',
                    labelStyle: TextStyle(color: Colors.white54),
                    prefixIcon: Icon(Icons.dns, color: Colors.white38),
                    border: OutlineInputBorder(),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Color(0xFF0F3460)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Color(0xFF53CFFF)),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _teamController,
                  style: const TextStyle(color: Colors.white),
                  textCapitalization: TextCapitalization.words,
                  decoration: const InputDecoration(
                    labelText: 'Team Name',
                    labelStyle: TextStyle(color: Colors.white54),
                    prefixIcon: Icon(Icons.group, color: Colors.white38),
                    border: OutlineInputBorder(),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Color(0xFF0F3460)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Color(0xFF53CFFF)),
                    ),
                  ),
                  onSubmitted: (_) => _connect(),
                ),
                if (_error != null) ...[
                  const SizedBox(height: 12),
                  Text(
                    _error!,
                    style: const TextStyle(color: Color(0xFFE94560)),
                  ),
                ],
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: _connecting ? null : _connect,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFE94560),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: _connecting
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Text(
                            'JOIN GAME',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 2,
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
