// ============================================================================
// Section: External Library & Application Module Imports
// Imports Flutter Material UI components, Provider state management, and application providers/services.
// ============================================================================
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:chess_live/providers/auth_provider.dart';
import 'package:chess_live/screens/game_screen.dart';
import 'package:chess_live/providers/chess_provider.dart';
import '../services/game_service.dart';

// ============================================================================
// Section: Lobby Screen Widget (`LobbyScreen`)
// StatefulWidget providing matchmaking hub for creating or joining online games.
// ============================================================================
class LobbyScreen extends StatefulWidget {
  // --------------------------------------------------------------------------
  // Sub-Block: Constructor
  // Standard const constructor with optional widget key parameter.
  // --------------------------------------------------------------------------
  const LobbyScreen({super.key});

  @override
  State<LobbyScreen> createState() => _LobbyScreenState();
}

// ============================================================================
// Section: Lobby Screen State & Matchmaking Actions (`_LobbyScreenState`)
// Manages text input controller for Game IDs, creates game sessions, joins existing games, and navigates.
// ============================================================================
class _LobbyScreenState extends State<LobbyScreen> {
  // --------------------------------------------------------------------------
  // Sub-Block: Text Input Controller
  // Text controller for reading entered Game ID string.
  // --------------------------------------------------------------------------
  final TextEditingController _controller = TextEditingController();

  // --------------------------------------------------------------------------
  // Sub-Block: Controller Disposal (`dispose`)
  // Disposes text editing controller when widget is removed from tree.
  // --------------------------------------------------------------------------
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  // --------------------------------------------------------------------------
  // Sub-Block: SnackBar Error Display (`_showError`)
  // Displays user-friendly error message inside a SnackBar banner.
  // --------------------------------------------------------------------------
  void _showError(Object error) {
    final message = error is StateError
        ? error.message.toString()
        : 'Unable to join the game. Please try again.';
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  // --------------------------------------------------------------------------
  // Sub-Block: Main Screen UI Builder (`build`)
  // Renders welcome greeting, "Create New Game" button, Game ID textfield, and "Join Game" button.
  // --------------------------------------------------------------------------
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
            // ----------------------------------------------------------------
            // Sub-Block: Welcome Greeting Header
            // Displays user UID prefix.
            // ----------------------------------------------------------------
            Text('Welcome, ${auth.user?.uid.substring(0, 6)}...'),
            const SizedBox(height: 20),

            // ----------------------------------------------------------------
            // Sub-Block: Create New Game Button Action
            // Creates new Firestore game document, initializes local provider as White player,
            // and navigates to GameScreen.
            // ----------------------------------------------------------------
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

            // ----------------------------------------------------------------
            // Sub-Block: Game ID Input TextField
            // TextField where users enter a target game ID to join.
            // ----------------------------------------------------------------
            TextField(
              controller: _controller,
              decoration: const InputDecoration(
                labelText: 'Enter Game ID to Join',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 10),

            // ----------------------------------------------------------------
            // Sub-Block: Join Game Button Action
            // Joins specified game ID via GameService, initializes local provider as Black player,
            // and navigates to GameScreen.
            // ----------------------------------------------------------------
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
