import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:chess_live/providers/auth_provider.dart';
import 'package:chess_live/services/game_service.dart';
import 'package:chess_live/screens/game_screen.dart';
import 'package:chess_live/providers/chess_provider.dart';

class LobbyScreen extends StatefulWidget {
  const LobbyScreen({super.key});

  @override
  State<LobbyScreen> createState() => _LobbyScreenState();
}

class _LobbyScreenState extends State<LobbyScreen> {
  final TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _showError(Object error) {
    final message = error is StateError
        ? error.message.toString()
        : 'Unable to join the game. Please try again.';
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.read<AuthProvider>();
    final gameService = GameService();

    return Scaffold(
      appBar: AppBar(title: const Text('ChessLive Lobby')),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Welcome, ${auth.user?.uid.substring(0, 6)}...'),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                try {
                  final userId = auth.user?.uid;
                  if (userId == null) return;
                  final gameId = await gameService.createGame(userId);
                  if (context.mounted) {
                    context
                        .read<ChessProvider>()
                        .initGame(gameId, true, userId);
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const GameScreen()),
                    );
                  }
                } catch (error) {
                  if (context.mounted) _showError(error);
                }
              },
              child: const Text('Create New Game'),
            ),
            const Divider(height: 40),
            TextField(
              controller: _controller,
              decoration: const InputDecoration(
                labelText: 'Enter Game ID to Join',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () async {
                final gameId = _controller.text.trim();
                final userId = auth.user?.uid;
                if (gameId.isEmpty || userId == null) return;
                try {
                  await gameService.joinGame(gameId, userId);
                  if (context.mounted) {
                    context
                        .read<ChessProvider>()
                        .initGame(gameId, false, userId);
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const GameScreen()),
                    );
                  }
                } catch (error) {
                  if (context.mounted) _showError(error);
                }
              },
              child: const Text('Join Game'),
            ),
          ],
        ),
      ),
    );
  }
}
