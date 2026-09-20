import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_stateless_chessboard/flutter_stateless_chessboard.dart';
import 'package:provider/provider.dart';
import 'package:chess_live/providers/chess_provider.dart';
import 'package:chess/chess.dart' as chess;

class GameScreen extends StatelessWidget {
  const GameScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ChessLive'),
        actions: [
          IconButton(
            icon: const Icon(Icons.copy),
            onPressed: () {
              final gameId = Provider.of<ChessProvider>(context, listen: false).gameId;
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
          return Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  children: [
                    Text(
                      provider.status == 'waiting' 
                          ? "Waiting for opponent..." 
                          : (provider.isMyTurn ? "Your Turn" : "Opponent's Turn"),
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: provider.status == 'waiting' 
                            ? Colors.orange 
                            : (provider.isMyTurn ? Colors.green : Colors.grey),
                      ),
                    ),
                    Text(
                      "Playing as ${provider.isWhite ? 'White' : 'Black'}",
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ],
                ),
              ),
              Chessboard(
                fen: provider.fen,
                size: MediaQuery.of(context).size.width,
                orientation: provider.isWhite ? BoardColor.WHITE : BoardColor.BLACK,
                onMove: (move) async {
                  if (provider.isMyTurn) {
                    String promotion = 'q';
                    if (_isPromotion(provider.fen, move)) {
                      promotion = await _showPromotionDialog(context);
                    }
                    provider.makeMove({
                      'from': move.from,
                      'to': move.to,
                      'promotion': promotion,
                    });
                  }
                },
              ),
              const SizedBox(height: 20),
              if (provider.isGameOver)
                Text(
                  'Game Over: ${provider.gameResult}',
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.red),
                )
              else
                ElevatedButton(
                  onPressed: () => provider.resign(),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.red.shade100),
                  child: const Text('Resign', style: TextStyle(color: Colors.red)),
                ),
              const SizedBox(height: 10),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Text(
                    provider.pgn,
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

  bool _isPromotion(String fen, ShortMove move) {
    final game = chess.Chess();
    game.load(fen);
    final piece = game.get(move.from);
    if (piece?.type == chess.PieceType.PAWN) {
      if ((piece?.color == chess.Color.WHITE && move.to[1] == '8') ||
          (piece?.color == chess.Color.BLACK && move.to[1] == '1')) {
        return true;
      }
    }
    return false;
  }

  Future<String> _showPromotionDialog(BuildContext context) async {
    return await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Promotion'),
        content: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _promotionOption(context, 'q', 'Queen'),
            _promotionOption(context, 'r', 'Rook'),
            _promotionOption(context, 'b', 'Bishop'),
            _promotionOption(context, 'n', 'Knight'),
          ],
        ),
      ),
    ) ?? 'q';
  }

  Widget _promotionOption(BuildContext context, String piece, String label) {
    return TextButton(
      onPressed: () => Navigator.pop(context, piece),
      child: Text(label),
    );
  }
}
