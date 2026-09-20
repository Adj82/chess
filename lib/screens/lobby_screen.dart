import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:chess_live/providers/auth_provider.dart';
import 'package:chess_live/services/game_service.dart';
import 'package:chess_live/screens/game_screen.dart';
import 'package:chess_live/providers/chess_provider.dart';

class LobbyScreen extends StatelessWidget {
  const LobbyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.read<AuthProvider>();
    final gameService = GameService();
    final TextEditingController controller = TextEditingController();

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
                final gameId = await gameService.createGame(auth.user!.uid);
                if (context.mounted) {
                  context.read<ChessProvider>().initGame(gameId, true);
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const GameScreen()),
                  );
                }
              },
              child: const Text('Create New Game'),
            ),
            const Divider(height: 40),
            TextField(
              controller: controller,
              decoration: const InputDecoration(
                labelText: 'Enter Game ID to Join',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () async {
                if (controller.text.isNotEmpty) {
                  await gameService.joinGame(controller.text, auth.user!.uid);
                  if (context.mounted) {
                    context.read<ChessProvider>().initGame(controller.text, false);
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const GameScreen()),
                    );
                  }
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
