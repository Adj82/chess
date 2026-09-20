import 'package:cloud_firestore/cloud_firestore.dart';

class GameModel {
  final String id;
  final String fen;
  final String pgn;
  final String turn;
  final String whitePlayerId;
  final String? blackPlayerId;
  final String status; // 'waiting', 'active', 'finished'
  final String? result;

  GameModel({
    required this.id,
    required this.fen,
    required this.pgn,
    required this.turn,
    required this.whitePlayerId,
    this.blackPlayerId,
    required this.status,
    this.result,
  });

  factory GameModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return GameModel(
      id: doc.id,
      fen: data['fen'] ?? '',
      pgn: data['pgn'] ?? '',
      turn: data['turn'] ?? 'w',
      whitePlayerId: data['whitePlayerId'] ?? '',
      blackPlayerId: data['blackPlayerId'],
      status: data['status'] ?? 'waiting',
      result: data['result'],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'fen': fen,
      'pgn': pgn,
      'turn': turn,
      'whitePlayerId': whitePlayerId,
      'blackPlayerId': blackPlayerId,
      'status': status,
      'result': result,
    };
  }
}
