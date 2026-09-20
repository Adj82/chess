import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:chess_live/providers/chess_provider.dart';
import 'package:simple_chess_board/simple_chess_board.dart';

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
              Expanded(
                child: Center(
                  child: SimpleChessBoard(
                    fen: provider.fen,
                    blackSideAtBottom: !provider.isWhite,
                    whitePlayerType: provider.isWhite ? PlayerType.human : PlayerType.computer,
                    blackPlayerType: !provider.isWhite ? PlayerType.human : PlayerType.computer,
                    chessBoardColors: ChessBoardColors(), // Using default colors
                    cellHighlights: const {},
                    onMove: ({required ShortMove move}) {
                      if (provider.isMyTurn) {
                        provider.makeMove({
                          'from': move.from,
                          'to': move.to,
                          'promotion': 'q', 
                        });
                      }
                    },
                    onPromote: () => _handlePromotion(context),
                    onPromotionCommited: ({required ShortMove moveDone, required PieceType pieceType}) {
                      if (provider.isMyTurn) {
                        provider.makeMove({
                          'from': moveDone.from,
                          'to': moveDone.to,
                          'promotion': pieceType.name[0].toLowerCase(),
                        });
                      }
                    },
                    onTap: ({required String cellCoordinate}) {},
                  ),
                ),
              ),
              const SizedBox(height: 20),
              if (provider.isGameOver)
                Column(
                  children: [
                    Text(
                      'Game Over: ${provider.gameResult}',
                      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.red),
                    ),
                    ElevatedButton(
                      onPressed: () => provider.resetGame(),
                      child: const Text('New Game / Rematch'),
                    ),
                  ],
                )
              else
                ElevatedButton(
                  onPressed: () => provider.resign(),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.red.shade100),
                  child: const Text('Resign', style: TextStyle(color: Colors.red)),
                ),
              const SizedBox(height: 10),
              Container(
                height: 100,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: SingleChildScrollView(
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
}
