import 'package:flutter/material.dart';
import 'package:chess/chess.dart' as chess;
import 'package:chess_live/services/game_service.dart';
import 'dart:async';

class ChessProvider extends ChangeNotifier {
  final chess.Chess _game = chess.Chess();
  final GameService _gameService = GameService();
  StreamSubscription? _subscription;
  String? _gameId;
  bool _isWhite = true;
  String _status = 'waiting';

  String? get gameId => _gameId;
  bool get isWhite => _isWhite;
  String get status => _status;
  String get fen => _game.fen;
  bool get isGameOver => _game.game_over || _status == 'finished';
  bool get isMyTurn => _status == 'active' && ((_game.turn == chess.Color.WHITE && _isWhite) || (_game.turn == chess.Color.BLACK && !_isWhite));
  
  String? get gameResult {
    if (_game.in_checkmate) return "Checkmate";
    if (_game.in_draw) return "Draw";
    if (_game.in_stalemate) return "Stalemate";
    return null;
  }

  void initGame(String gameId, bool isWhite) {
    _gameId = gameId;
    _isWhite = isWhite;
    _subscription?.cancel();
    _subscription = _gameService.streamGame(gameId).listen(
      (gameModel) {
        if (gameModel.pgn.isNotEmpty) {
          _game.load_pgn(gameModel.pgn);
        } else {
          _game.load(gameModel.fen);
        }
        _status = gameModel.status;
        notifyListeners();
      },
      onError: (e) {
        debugPrint("Error in game stream: $e");
      },
    );
  }

  void makeMove(dynamic move) {
    if (!isMyTurn) return;

    final bool result = _game.move(move);
    if (result) {
      if (_gameId != null) {
        _gameService.updateMove(
          _gameId!,
          _game.fen,
          _game.pgn(),
          _game.turn == chess.Color.WHITE ? 'w' : 'b',
        ).catchError((e) {
          debugPrint("Error updating move: $e");
        });
        
        if (_game.game_over) {
          _gameService.finishGame(_gameId!, gameResult ?? "Finished");
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
  
  void resign() {
    if (_gameId != null) {
      _gameService.finishGame(_gameId!, _isWhite ? "White Resigned" : "Black Resigned");
    }
  }

  void resetGame() {
    if (_gameId != null) {
      _gameService.resetGame(_gameId!);
    }
  }
}
