// ============================================================================
// Section: External Library & Service Imports
// Import Flutter Material UI, local chess rules engine, GameService, and async stream library.
// ============================================================================
import 'package:flutter/material.dart';
import 'package:chess/chess.dart' as chess;
import 'package:chess_live/services/game_service.dart';
import 'dart:async';

// ============================================================================
// Section: Chess State Provider (`ChessProvider`)
// Provider class managing local chess board engine calculations, legal moves,
// move history, and synchronization with backend GameService.
// ============================================================================
class ChessProvider extends ChangeNotifier {
  // --------------------------------------------------------------------------
  // Sub-Block: Internal Engine & Service Instances
  // Private instances for local chess rules engine (`chess.Chess`) and Firestore GameService.
  // --------------------------------------------------------------------------
  final chess.Chess _game = chess.Chess();
  final GameService _gameService = GameService();

  // --------------------------------------------------------------------------
  // Sub-Block: Internal Session State Variables
  // Tracks active subscription, game ID, user ID, player color assignment, status, and game result.
  // --------------------------------------------------------------------------
  StreamSubscription? _subscription;
  String? _gameId;
  String? _userId;
  bool _isWhite = true;
  String _status = 'waiting';
  String? _result;

  // --------------------------------------------------------------------------
  // Sub-Block: Basic Game State Getters
  // Public getters exposing active game ID, color orientation, game status, and board FEN string.
  // --------------------------------------------------------------------------
  String? get gameId => _gameId;
  bool get isWhite => _isWhite;
  String get status => _status;
  String get fen => _game.fen;

  // --------------------------------------------------------------------------
  // Sub-Block: Board Status Getters
  // Computes whether the game is over, if king is currently in check, or if it is local player's turn.
  // --------------------------------------------------------------------------
  bool get isGameOver => _game.game_over || _status == 'finished';
  bool get isInCheck => _game.in_check && !_game.game_over;
  bool get isMyTurn =>
      _status == 'active' &&
      ((_game.turn == chess.Color.WHITE && _isWhite) ||
          (_game.turn == chess.Color.BLACK && !_isWhite));

  // --------------------------------------------------------------------------
  // Sub-Block: Game Result Evaluator Getter (`gameResult`)
  // Formats human-readable game outcome string for checkmate, stalemate, draw, or resignation.
  // --------------------------------------------------------------------------
  String? get gameResult {
    if (_game.in_checkmate) {
      final winner = _game.turn == chess.Color.WHITE ? 'Black' : 'White';
      return '$winner wins by checkmate';
    }
    if (_game.in_stalemate) return 'Draw by stalemate';
    if (_game.in_draw) return 'Draw';
    return _result;
  }

  // --------------------------------------------------------------------------
  // Sub-Block: Move Notation & Last Move Getters
  // Exposes SAN move history list, last move origin square, and last move target square.
  // --------------------------------------------------------------------------
  List<String> get moveHistory =>
      _game.san_moves().whereType<String>().toList();

  String? get lastMoveFrom =>
      _game.history.isEmpty ? null : _game.history.last.move.fromAlgebraic;

  String? get lastMoveTo =>
      _game.history.isEmpty ? null : _game.history.last.move.toAlgebraic;

  // --------------------------------------------------------------------------
  // Sub-Block: Piece Ownership Verifier (`isMyPiece`)
  // Checks if a piece located on a specified square belongs to the local player's assigned color.
  // --------------------------------------------------------------------------
  bool isMyPiece(String square) {
    final piece = _game.get(square);
    if (piece == null) return false;
    return _isWhite
        ? piece.color == chess.Color.WHITE
        : piece.color == chess.Color.BLACK;
  }

  // --------------------------------------------------------------------------
  // Sub-Block: Legal Destinations Computer (`legalDestinations`)
  // Returns list of valid algebraic target squares for a selected piece if it is local player's turn.
  // --------------------------------------------------------------------------
  List<String> legalDestinations(String square) {
    if (!isMyTurn || !isMyPiece(square)) return const [];
    return _game
        .moves({'square': square, 'asObjects': true})
        .cast<chess.Move>()
        .map((move) => move.toAlgebraic)
        .toList();
  }

  // --------------------------------------------------------------------------
  // Sub-Block: Remote Game Listener Setup (`initGame`)
  // Binds provider session to a game ID and listens to real-time Firestore updates via GameService stream.
  // --------------------------------------------------------------------------
  void initGame(String gameId, bool isWhite, String userId) {
    _gameId = gameId;
    _isWhite = isWhite;
    _userId = userId;
    _subscription?.cancel();
    _subscription = _gameService.streamGame(gameId).listen(
      (gameModel) {
        if (gameModel.pgn.isNotEmpty) {
          _game.load_pgn(gameModel.pgn);
        } else {
          _game.load(gameModel.fen);
        }
        _status = gameModel.status;
        _result = gameModel.result;
        notifyListeners();
      },
      onError: (e) {
        debugPrint("Error in game stream: $e");
      },
    );
  }

  // --------------------------------------------------------------------------
  // Sub-Block: Move Execution Handler (`makeMove`)
  // Validates and applies moves locally on engine, sends updated FEN/PGN to Firestore, and rolls back on failure.
  // --------------------------------------------------------------------------
  Future<void> makeMove(Map<String, dynamic> move) async {
    if (!isMyTurn) return;

    final previousFen = _game.fen;
    final previousPgn = _game.pgn();
    final bool result = _game.move(move);
    if (result) {
      final gameId = _gameId;
      final userId = _userId;
      if (gameId != null && userId != null) {
        try {
          await _gameService.submitMove(
            gameId: gameId,
            userId: userId,
            isWhite: _isWhite,
            previousFen: previousFen,
            fen: _game.fen,
            pgn: _game.pgn(),
            turn: _game.turn == chess.Color.WHITE ? 'w' : 'b',
            result: _game.game_over ? gameResult ?? 'Game finished' : null,
          );
        } catch (e) {
          _game.load_pgn(previousPgn);
          debugPrint("Error updating move: $e");
        }
      }
      notifyListeners();
    }
  }

  // --------------------------------------------------------------------------
  // Sub-Block: Resource Cleanup (`dispose`)
  // Cancels active Firestore stream subscription when provider is disposed.
  // --------------------------------------------------------------------------
  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  // --------------------------------------------------------------------------
  // Sub-Block: PGN String Getter
  // Returns raw PGN notation string from local engine instance.
  // --------------------------------------------------------------------------
  String get pgn => _game.pgn();

  // --------------------------------------------------------------------------
  // Sub-Block: Resignation Dispatcher (`resign`)
  // Sends resignation command for current game session to GameService.
  // --------------------------------------------------------------------------
  Future<void> resign() async {
    if (_gameId != null && _userId != null) {
      await _gameService.resignGame(_gameId!, _userId!, _isWhite);
    }
  }

  // --------------------------------------------------------------------------
  // Sub-Block: Game Rematch Dispatcher (`resetGame`)
  // Sends reset command for current game session to GameService for a rematch.
  // --------------------------------------------------------------------------
  Future<void> resetGame() async {
    if (_gameId != null && _userId != null) {
      await _gameService.resetGame(_gameId!, _userId!);
    }
  }
}
