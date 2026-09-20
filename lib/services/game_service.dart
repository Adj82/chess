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
    
    DocumentReference ref = await _db.collection('games').add(game.toFirestore());
    return ref.id;
  }

  Future<void> joinGame(String gameId, String userId) async {
    await _db.collection('games').doc(gameId).update({
      'blackPlayerId': userId,
      'status': 'active',
    });
  }

  Stream<GameModel> streamGame(String gameId) {
    return _db.collection('games').doc(gameId).snapshots().map((doc) => GameModel.fromFirestore(doc));
  }
  
  Future<void> updateMove(String gameId, String fen, String pgn, String turn) async {
    await _db.collection('games').doc(gameId).update({
      'fen': fen,
      'pgn': pgn,
      'turn': turn,
    });
  }

  Future<void> finishGame(String gameId, String? result) async {
    await _db.collection('games').doc(gameId).update({
      'status': result == null ? 'active' : 'finished',
      'result': result,
    });
  }

  Future<void> resetGame(String gameId) async {
    final newGame = chess.Chess();
    await _db.collection('games').doc(gameId).update({
      'fen': newGame.fen,
      'pgn': '',
      'turn': 'w',
      'status': 'active',
      'result': null,
    });
  }
}
