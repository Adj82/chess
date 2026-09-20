import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:chess_live/models/game_model.dart';
import 'package:chess/chess.dart' as chess;

class GameService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<String> createGame(String userId) async {
    final game = GameModel(
      id: '',
      fen: chess.Chess().fen,
      pgn: '',
      turn: 'w',
      whitePlayerId: userId,
      status: 'waiting',
    );

    DocumentReference ref =
        await _db.collection('games').add(game.toFirestore());
    return ref.id;
  }

  Future<void> joinGame(String gameId, String userId) async {
    final ref = _db.collection('games').doc(gameId);
    await _db.runTransaction((transaction) async {
      final snapshot = await transaction.get(ref);
      if (!snapshot.exists) {
        throw StateError('This game does not exist. Check the game ID.');
      }

      final game = GameModel.fromFirestore(snapshot);
      if (game.whitePlayerId == userId) {
        throw StateError('You cannot join your own game.');
      }
      if (game.status != 'waiting' || game.blackPlayerId != null) {
        throw StateError('This game already has two players.');
      }

      transaction.update(ref, {
        'blackPlayerId': userId,
        'status': 'active',
      });
    });
  }

  Stream<GameModel> streamGame(String gameId) {
    return _db
        .collection('games')
        .doc(gameId)
        .snapshots()
        .map((doc) => GameModel.fromFirestore(doc));
  }

  Future<void> submitMove({
    required String gameId,
    required String userId,
    required bool isWhite,
    required String previousFen,
    required String fen,
    required String pgn,
    required String turn,
    String? result,
  }) async {
    final ref = _db.collection('games').doc(gameId);
    await _db.runTransaction((transaction) async {
      final snapshot = await transaction.get(ref);
      if (!snapshot.exists) throw StateError('This game no longer exists.');

      final game = GameModel.fromFirestore(snapshot);
      final isPlayer =
          isWhite ? game.whitePlayerId == userId : game.blackPlayerId == userId;
      final expectedTurn = isWhite ? 'w' : 'b';
      if (!isPlayer || game.status != 'active' || game.turn != expectedTurn) {
        throw StateError('It is no longer your turn.');
      }
      if (game.fen != previousFen) {
        throw StateError('The board changed. Please try your move again.');
      }

      transaction.update(ref, {
        'fen': fen,
        'pgn': pgn,
        'turn': turn,
        if (result != null) 'status': 'finished',
        if (result != null) 'result': result,
      });
    });
  }

  Future<void> resignGame(String gameId, String userId, bool isWhite) async {
    final ref = _db.collection('games').doc(gameId);
    await _db.runTransaction((transaction) async {
      final snapshot = await transaction.get(ref);
      if (!snapshot.exists) throw StateError('This game no longer exists.');
      final game = GameModel.fromFirestore(snapshot);
      final isPlayer =
          isWhite ? game.whitePlayerId == userId : game.blackPlayerId == userId;
      if (!isPlayer || game.status != 'active') {
        throw StateError('This game cannot be resigned.');
      }
      transaction.update(ref, {
        'status': 'finished',
        'result': isWhite ? 'White resigned' : 'Black resigned',
      });
    });
  }

  Future<void> resetGame(String gameId, String userId) async {
    final newGame = chess.Chess();
    final ref = _db.collection('games').doc(gameId);
    await _db.runTransaction((transaction) async {
      final snapshot = await transaction.get(ref);
      if (!snapshot.exists) throw StateError('This game no longer exists.');
      final game = GameModel.fromFirestore(snapshot);
      if ((game.whitePlayerId != userId && game.blackPlayerId != userId) ||
          game.status != 'finished') {
        throw StateError(
            'Only a player can start a rematch after the game ends.');
      }
      transaction.update(ref, {
        'fen': newGame.fen,
        'pgn': '',
        'turn': 'w',
        'status': 'active',
        'result': null,
      });
    });
  }
}
