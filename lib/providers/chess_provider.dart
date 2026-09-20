import 'package:flutter/material.dart';
import 'package:chess/chess.dart' as chess;
import 'package:chess_live/services/game_service.dart';
import 'dart:async';

class ChessProvider extends ChangeNotifier {
  final chess.Chess _game = chess.Chess();
  final GameService _gameService = GameService();
  StreamSubscription? _subscription;
  String? _gameId;
  String? _userId;
  bool _isWhite = true;
  String _status = 'waiting';
  String? _result;

  String? get gameId => _gameId;
  bool get isWhite => _isWhite;
  String get status => _status;
  String get fen => _game.fen;
  bool get isGameOver => _game.game_over || _status == 'finished';
  bool get isInCheck => _game.in_check && !_game.game_over;
  bool get isMyTurn =>
      _status == 'active' &&
      ((_game.turn == chess.Color.WHITE && _isWhite) ||
          (_game.turn == chess.Color.BLACK && !_isWhite));

  String? get gameResult {
    if (_game.in_checkmate) {
      final winner = _game.turn == chess.Color.WHITE ? 'Black' : 'White';
      return '$winner wins by checkmate';
    }
    if (_game.in_stalemate) return 'Draw by stalemate';
    if (_game.in_draw) return 'Draw';
    return _result;
  }

  List<String> get moveHistory =>
      _game.san_moves().whereType<String>().toList();

  String? get lastMoveFrom =>
      _game.history.isEmpty ? null : _game.history.last.move.fromAlgebraic;

  String? get lastMoveTo =>
      _game.history.isEmpty ? null : _game.history.last.move.toAlgebraic;

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

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  String get pgn => _game.pgn();

  Future<void> resign() async {
    if (_gameId != null && _userId != null) {
      await _gameService.resignGame(_gameId!, _userId!, _isWhite);
    }
  }

  Future<void> resetGame() async {
    if (_gameId != null && _userId != null) {
      await _gameService.resetGame(_gameId!, _userId!);
    }
  }
}
