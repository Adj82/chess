// ============================================================================
// Section: External Library & Model Imports
// Imports Cloud Firestore, GameModel data structure, and chess engine library.
// ============================================================================
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:chess_live/models/game_model.dart';
import 'package:chess/chess.dart' as chess;

// ============================================================================
// Section: Game Firestore Database Service (`GameService`)
// Service class providing Firestore API interactions for game creation, matchmaking, streaming, and move updates.
// ============================================================================
class GameService {
  // --------------------------------------------------------------------------
  // Sub-Block: Database Instance Reference
  // Singleton instance reference for FirebaseFirestore client.
  // --------------------------------------------------------------------------
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // --------------------------------------------------------------------------
  // Sub-Block: Game Creation Handler (`createGame`)
  // Initializes a new game document in Firestore with default chess FEN, initial turn 'w',
  // and status 'waiting'. Returns the generated document ID.
  // --------------------------------------------------------------------------
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

  // --------------------------------------------------------------------------
  // Sub-Block: Game Join Transaction (`joinGame`)
  // Executes atomic transaction to assign joining player as blackPlayerId and update game status to 'active'.
  // Validates game existence, preventing self-joining or joining full games.
  // --------------------------------------------------------------------------
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

  // --------------------------------------------------------------------------
  // Sub-Block: Real-Time Game Document Stream (`streamGame`)
  // Subscribes to Firestore document changes for gameId and maps snapshots to GameModel.
  // --------------------------------------------------------------------------
  Stream<GameModel> streamGame(String gameId) {
    return _db
        .collection('games')
        .doc(gameId)
        .snapshots()
        .map((doc) => GameModel.fromFirestore(doc));
  }

  // --------------------------------------------------------------------------
  // Sub-Block: Move Submission Transaction (`submitMove`)
  // Validates player identity, turn order, and concurrent board state match before atomically
  // updating board FEN, move PGN history, turn color, and final game result in Firestore.
  // --------------------------------------------------------------------------
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

  // --------------------------------------------------------------------------
  // Sub-Block: Game Resignation Handler (`resignGame`)
  // Allows an active player to resign, changing status to 'finished' and recording winner in Firestore.
  // --------------------------------------------------------------------------
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

  // --------------------------------------------------------------------------
  // Sub-Block: Game Rematch Reset Handler (`resetGame`)
  // Resets a completed game back to default starting FEN and 'active' status for a rematch.
  // --------------------------------------------------------------------------
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
