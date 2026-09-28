// ============================================================================
// Section: External Library & Application Module Imports
// Imports Flutter Material UI, Clipboard services, Provider, ChessProvider, simple board types, and TapChessBoard.
// ============================================================================
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:chess_live/providers/chess_provider.dart';
import 'package:simple_chess_board/simple_chess_board.dart';
import 'package:chess_live/widgets/tap_chess_board.dart';

// ============================================================================
// Section: Gameplay Screen Widget (`GameScreen`)
// Primary interactive gameplay screen widget.
// ============================================================================
class GameScreen extends StatefulWidget {
  // --------------------------------------------------------------------------
  // Sub-Block: Constructor
  // Standard const constructor with optional widget key parameter.
  // --------------------------------------------------------------------------
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

// ============================================================================
// Section: Gameplay Screen State & User Interactions (`_GameScreenState`)
// Manages gameplay screen lifecycle, game over popups, pawn promotion dialogs, and game actions.
// ============================================================================
class _GameScreenState extends State<GameScreen> {
  // --------------------------------------------------------------------------
  // Sub-Block: Announced Result Tracker
  // Prevents duplicate dialog popups by tracking previously announced game outcome.
  // --------------------------------------------------------------------------
  String? _announcedResult;

  // --------------------------------------------------------------------------
  // Sub-Block: Main Gameplay Layout Builder (`build`)
  // Renders AppBar with Game ID copy action, turn status banner, player orientation info,
  // interactive TapChessBoard widget, Resign/Rematch actions, and move history log container.
  // --------------------------------------------------------------------------
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // ----------------------------------------------------------------------
      // Sub-Block: AppBar & Copy Game ID Action
      // AppBar containing IconButton to copy active Game ID to system clipboard.
      // ----------------------------------------------------------------------
      appBar: AppBar(
        title: const Text('ChessLive'),
        actions: [
          IconButton(
            icon: const Icon(Icons.copy),
            onPressed: () {
              final gameId =
                  Provider.of<ChessProvider>(context, listen: false).gameId;
              if (gameId != null) {
                Clipboard.setData(ClipboardData(text: gameId));
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Game ID copied to clipboard')),
                );
              }
            },
          ),
        ],
      ),

      // ----------------------------------------------------------------------
      // Sub-Block: Main Screen Body & Consumer Subscription
      // Listens to ChessProvider state changes to re-render board, status, and move log.
      // ----------------------------------------------------------------------
      body: Consumer<ChessProvider>(
        builder: (context, provider, child) {
          _maybeAnnounceResult(provider);
          return Column(
            children: [
              // --------------------------------------------------------------
              // Sub-Block: Turn Status Card Banner
              // Displays game status message and active check warning.
              // --------------------------------------------------------------
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                child: _GameStatus(provider: provider),
              ),

              // --------------------------------------------------------------
              // Sub-Block: Player Color Assignment Row
              // Displays player role indicators for top/bottom player colors.
              // --------------------------------------------------------------
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Row(
                  children: [
                    const Icon(Icons.person_outline, size: 18),
                    const SizedBox(width: 6),
                    Text(provider.isWhite ? 'You — White' : 'Opponent — White'),
                    const Spacer(),
                    Text(provider.isWhite ? 'Opponent — Black' : 'You — Black'),
                    const SizedBox(width: 6),
                    const Icon(Icons.person_outline, size: 18),
                  ],
                ),
              ),

              // --------------------------------------------------------------
              // Sub-Block: Chess Board Container Widget
              // Wraps TapChessBoard widget in AspectRatio container centered on screen.
              // --------------------------------------------------------------
              Expanded(
                child: Center(
                  child: AspectRatio(
                    aspectRatio: 1,
                    child: TapChessBoard(
                      fen: provider.fen,
                      isWhiteAtBottom: provider.isWhite,
                      isInteractive: provider.isMyTurn && !provider.isGameOver,
                      isMyPiece: provider.isMyPiece,
                      legalDestinations: provider.legalDestinations,
                      lastMoveFrom: provider.lastMoveFrom,
                      lastMoveTo: provider.lastMoveTo,
                      onMove: (from, to) => _moveFromBoard(provider, from, to),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),

              // --------------------------------------------------------------
              // Sub-Block: Game End Actions (Rematch vs Resign Buttons)
              // Displays game over outcome text & New Game/Rematch button when finished,
              // or Resign button during active gameplay.
              // --------------------------------------------------------------
              if (provider.isGameOver)
                Column(
                  children: [
                    Text(
                      provider.gameResult ?? 'Game finished',
                      style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.red),
                    ),
                    ElevatedButton(
                      onPressed: () =>
                          _runGameAction(context, provider.resetGame),
                      child: const Text('New Game / Rematch'),
                    ),
                  ],
                )
              else
                ElevatedButton(
                  onPressed: () => _runGameAction(context, provider.resign),
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red.shade100),
                  child:
                      const Text('Resign', style: TextStyle(color: Colors.red)),
                ),
              const SizedBox(height: 10),

              // --------------------------------------------------------------
              // Sub-Block: Move History Scroll Log
              // Displays scrollable list of executed moves in SAN format.
              // --------------------------------------------------------------
              Container(
                height: 88,
                width: double.infinity,
                margin: const EdgeInsets.fromLTRB(12, 0, 12, 12),
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: SingleChildScrollView(
                  child: provider.moveHistory.isEmpty
                      ? const Text('Moves will appear here.',
                          textAlign: TextAlign.center)
                      : Text(
                          provider.moveHistory.join('\n'),
                          style: const TextStyle(fontFamily: 'monospace'),
                        ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  // --------------------------------------------------------------------------
  // Sub-Block: Pawn Promotion Selection Dialog (`_handlePromotion`)
  // Displays AlertDialog for user to select promotion piece (Queen, Rook, Bishop, Knight).
  // --------------------------------------------------------------------------
  Future<PieceType?> _handlePromotion(BuildContext context) async {
    return await showDialog<PieceType>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Promotion'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: const Text('Queen'),
              onTap: () => Navigator.pop(context, PieceType.queen),
            ),
            ListTile(
              title: const Text('Rook'),
              onTap: () => Navigator.pop(context, PieceType.rook),
            ),
            ListTile(
              title: const Text('Bishop'),
              onTap: () => Navigator.pop(context, PieceType.bishop),
            ),
            ListTile(
              title: const Text('Knight'),
              onTap: () => Navigator.pop(context, PieceType.knight),
            ),
          ],
        ),
      ),
    );
  }

  // --------------------------------------------------------------------------
  // Sub-Block: Board Move Execution Handler (`_moveFromBoard`)
  // Detects pawn promotion moves to trigger promotion selection dialog, then submits move map to provider.
  // --------------------------------------------------------------------------
  Future<void> _moveFromBoard(
    ChessProvider provider,
    String from,
    String to,
  ) async {
    var promotion = 'q';
    if (to.endsWith('1') || to.endsWith('8')) {
      final selected = await _handlePromotion(context);
      if (selected == null) return;
      promotion = selected.name[0].toLowerCase();
    }
    await provider.makeMove({'from': from, 'to': to, 'promotion': promotion});
  }

  // --------------------------------------------------------------------------
  // Sub-Block: Action Error Handling Wrapper (`_runGameAction`)
  // Runs async game actions (Resign/Reset) and catches exceptions to display SnackBar alerts.
  // --------------------------------------------------------------------------
  Future<void> _runGameAction(
    BuildContext context,
    Future<void> Function() action,
  ) async {
    try {
      await action();
    } catch (error) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Unable to update the game. Please try again.')),
        );
      }
    }
  }

  // --------------------------------------------------------------------------
  // Sub-Block: Game Over Dialog Trigger (`_maybeAnnounceResult`)
  // Triggers post-frame barrier-dismissible AlertDialog when game ends in checkmate or draw.
  // --------------------------------------------------------------------------
  void _maybeAnnounceResult(ChessProvider provider) {
    final result = provider.gameResult;
    if (!provider.isGameOver) {
      _announcedResult = null;
      return;
    }
    if (result == null || _announcedResult == result) return;
    _announcedResult = result;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (dialogContext) => AlertDialog(
          icon: const Icon(Icons.emoji_events, size: 42, color: Colors.amber),
          title: const Text('Game over'),
          content: Text(result, textAlign: TextAlign.center),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('View board'),
            ),
          ],
        ),
      );
    });
  }
}

// ============================================================================
// Section: Game Status Banner Component Widget (`_GameStatus`)
// Displays current turn message badge ("Your move", "Check", "Game over", etc.)
// ============================================================================
class _GameStatus extends StatelessWidget {
  // --------------------------------------------------------------------------
  // Sub-Block: Constructor & Parameters
  // Requires ChessProvider instance reference to compute status message & color.
  // --------------------------------------------------------------------------
  const _GameStatus({required this.provider});

  final ChessProvider provider;

  // --------------------------------------------------------------------------
  // Sub-Block: Status Banner UI Builder (`build`)
  // Computes status message string and badge color based on turn, check, or game over state.
  // --------------------------------------------------------------------------
  @override
  Widget build(BuildContext context) {
    final waiting = provider.status == 'waiting';
    final finished = provider.isGameOver;
    final check = provider.isInCheck;
    final message = waiting
        ? 'Waiting for an opponent'
        : finished
            ? 'Game over'
            : check
                ? 'Check — protect your king'
                : provider.isMyTurn
                    ? 'Your move'
                    : 'Opponent is thinking';
    final color = waiting
        ? Colors.orange
        : finished || check
            ? Colors.red
            : provider.isMyTurn
                ? Colors.green
                : Colors.blueGrey;

    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Icon(check ? Icons.warning_amber_rounded : Icons.circle,
                color: color, size: 20),
            const SizedBox(width: 10),
            Expanded(
              child: Text(message,
                  style: const TextStyle(fontWeight: FontWeight.bold)),
            ),
            Text('You play ${provider.isWhite ? 'White' : 'Black'}'),
          ],
        ),
      ),
    );
  }
}
