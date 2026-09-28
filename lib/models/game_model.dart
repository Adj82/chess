// ============================================================================
// Section: External Library Imports
// Imports Cloud Firestore DocumentSnapshot dependencies for data deserialization.
// ============================================================================

import 'package:cloud_firestore/cloud_firestore.dart';

// ============================================================================
// Section: Game Data Model Definition (`GameModel`)
// Immutable model class representing a multiplayer chess game document stored in Firestore.
// ============================================================================
class GameModel {
  // --------------------------------------------------------------------------
  // Sub-Block: Immutable Field Properties
  // Document ID, board states (FEN, PGN), active turn indicator, player UIDs, status, and outcome.
  // --------------------------------------------------------------------------
  final String id;
  final String fen;
  final String pgn;
  final String turn;
  final String whitePlayerId;
  final String? blackPlayerId;
  final String status; // 'waiting', 'active', 'finished'
  final String? result;

  // --------------------------------------------------------------------------
  // Sub-Block: Primary Constructor
  // Creates a GameModel instance with required and optional game attributes.
  // --------------------------------------------------------------------------
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

  // --------------------------------------------------------------------------
  // Sub-Block: Firestore Deserialization (`fromFirestore`)
  // Factory constructor converting a Firestore DocumentSnapshot into a typed GameModel.
  // Throws Exception if the document snapshot contains null data.
  // --------------------------------------------------------------------------
  factory GameModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>?;
    if (data == null) {
      throw Exception("Game document does not exist");
    }
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

  // --------------------------------------------------------------------------
  // Sub-Block: Firestore Serialization (`toFirestore`)
  // Converts instance attributes into a JSON-compatible Map for saving to Firestore.
  // --------------------------------------------------------------------------
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
