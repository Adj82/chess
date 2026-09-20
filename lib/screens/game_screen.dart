import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:chess_live/providers/chess_provider.dart';
import 'package:simple_chess_board/simple_chess_board.dart';

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  String? _announcedResult;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
      body: Consumer<ChessProvider>(
        builder: (context, provider, child) {
          _maybeAnnounceResult(provider);
          final lastMove =
              provider.lastMoveFrom != null && provider.lastMoveTo != null
                  ? BoardArrow(
                      from: provider.lastMoveFrom!,
                      to: provider.lastMoveTo!,
                      color: Colors.amber.shade700,
                    )
                  : null;
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                child: _GameStatus(provider: provider),
              ),
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
              Expanded(
                child: Center(
                  child: AspectRatio(
                    aspectRatio: 1,
                    child: SimpleChessBoard(
                      fen: provider.fen,
                      blackSideAtBottom: !provider.isWhite,
                      whitePlayerType: provider.isWhite
                          ? PlayerType.human
                          : PlayerType.computer,
                      blackPlayerType: !provider.isWhite
                          ? PlayerType.human
                          : PlayerType.computer,
                      chessBoardColors: ChessBoardColors(),
                      cellHighlights: const {},
                      lastMoveToHighlight: lastMove,
                      highlightLastMoveSquares: true,
                      showPossibleMoves: true,
                      playSounds: true,
                      isInteractive: provider.isMyTurn && !provider.isGameOver,
                      nonInteractiveText: provider.status == 'waiting'
                          ? 'WAITING FOR OPPONENT'
                          : 'OPPONENT\'S TURN',
                      onMove: ({required ShortMove move}) {
                        provider.makeMove({
                          'from': move.from,
                          'to': move.to,
                          'promotion': 'q',
                        });
                      },
                      onPromote: () => _handlePromotion(context),
                      onPromotionCommited: (
                          {required ShortMove moveDone,
                          required PieceType pieceType}) {
                        provider.makeMove({
                          'from': moveDone.from,
                          'to': moveDone.to,
                          'promotion': pieceType.name[0].toLowerCase(),
                        });
                      },
                      onTap: ({required String cellCoordinate}) {},
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),
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

class _GameStatus extends StatelessWidget {
  const _GameStatus({required this.provider});

  final ChessProvider provider;

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
