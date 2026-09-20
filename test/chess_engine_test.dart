import 'package:chess/chess.dart' as chess;
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('chess game rules', () {
    test('a legal opening move updates the board and turn', () {
      final game = chess.Chess();

      expect(game.move({'from': 'e2', 'to': 'e4'}), isTrue);
      expect(game.get('e4')?.type, chess.PieceType.PAWN);
      expect(game.get('e4')?.color, chess.Color.WHITE);
      expect(game.turn, chess.Color.BLACK);
    });

    test('an illegal move is rejected without changing the position', () {
      final game = chess.Chess();
      final initialFen = game.fen;

      expect(game.move({'from': 'e2', 'to': 'e5'}), isFalse);
      expect(game.fen, initialFen);
      expect(game.turn, chess.Color.WHITE);
    });

    test('checkmate is detected after Fool\'s Mate', () {
      final game = chess.Chess();

      expect(game.move({'from': 'f2', 'to': 'f3'}), isTrue);
      expect(game.move({'from': 'e7', 'to': 'e5'}), isTrue);
      expect(game.move({'from': 'g2', 'to': 'g4'}), isTrue);
      expect(game.move({'from': 'd8', 'to': 'h4'}), isTrue);

      expect(game.in_checkmate, isTrue);
      expect(game.game_over, isTrue);
    });
  });
}
