import 'package:flutter/material.dart';

class TapChessBoard extends StatefulWidget {
  const TapChessBoard({
    super.key,
    required this.fen,
    required this.isWhiteAtBottom,
    required this.isInteractive,
    required this.isMyPiece,
    required this.legalDestinations,
    required this.onMove,
    this.lastMoveFrom,
    this.lastMoveTo,
  });

  final String fen;
  final bool isWhiteAtBottom;
  final bool isInteractive;
  final bool Function(String square) isMyPiece;
  final List<String> Function(String square) legalDestinations;
  final Future<void> Function(String from, String to) onMove;
  final String? lastMoveFrom;
  final String? lastMoveTo;

  @override
  State<TapChessBoard> createState() => _TapChessBoardState();
}

class _TapChessBoardState extends State<TapChessBoard> {
  String? _selectedSquare;

  @override
  void didUpdateWidget(TapChessBoard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.fen != widget.fen || !widget.isInteractive) {
      _selectedSquare = null;
    }
  }

  void _handleTap(String square) async {
    if (!widget.isInteractive) return;
    final selected = _selectedSquare;
    final legalTargets = selected == null
        ? const <String>[]
        : widget.legalDestinations(selected);

    if (selected != null && legalTargets.contains(square)) {
      setState(() => _selectedSquare = null);
      await widget.onMove(selected, square);
      return;
    }

    if (widget.isMyPiece(square)) {
      setState(() => _selectedSquare = square);
    } else {
      setState(() => _selectedSquare = null);
    }
  }

  @override
  Widget build(BuildContext context) {
    final pieces = _piecesFromFen(widget.fen);
    final legalTargets = _selectedSquare == null
        ? const <String>[]
        : widget.legalDestinations(_selectedSquare!);
    final files = widget.isWhiteAtBottom
        ? const ['a', 'b', 'c', 'd', 'e', 'f', 'g', 'h']
        : const ['h', 'g', 'f', 'e', 'd', 'c', 'b', 'a'];
    final ranks = widget.isWhiteAtBottom
        ? const [8, 7, 6, 5, 4, 3, 2, 1]
        : const [1, 2, 3, 4, 5, 6, 7, 8];

    return DecoratedBox(
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xff5a3e2b), width: 3),
        borderRadius: BorderRadius.circular(4),
      ),
      child: GridView.builder(
        physics: const NeverScrollableScrollPhysics(),
        itemCount: 64,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 8,
        ),
        itemBuilder: (context, index) {
          final row = index ~/ 8;
          final column = index % 8;
          final square = '${files[column]}${ranks[row]}';
          final isLight = (row + column).isEven;
          final isSelected = square == _selectedSquare;
          final isLastMove =
              square == widget.lastMoveFrom || square == widget.lastMoveTo;
          final isLegalTarget = legalTargets.contains(square);
          final piece = pieces[square];

          return Semantics(
            button: true,
            label: '$square${piece == null ? '' : ', $piece'}',
            child: InkWell(
              onTap: () => _handleTap(square),
              child: Container(
                decoration: BoxDecoration(
                  color: isSelected
                      ? const Color(0xfff6d860)
                      : isLastMove
                          ? const Color(0xffd7d66f)
                          : isLight
                              ? const Color(0xfff0d9b5)
                              : const Color(0xffb58863),
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    if (isLegalTarget)
                      Container(
                        width: piece == null ? 15 : double.infinity,
                        height: piece == null ? 15 : double.infinity,
                        margin: piece == null ? null : const EdgeInsets.all(5),
                        decoration: BoxDecoration(
                          color: piece == null
                              ? Colors.black.withValues(alpha: 0.24)
                              : Colors.transparent,
                          shape: piece == null
                              ? BoxShape.circle
                              : BoxShape.rectangle,
                          border: piece == null
                              ? null
                              : Border.all(
                                  color: Colors.black.withValues(alpha: 0.28),
                                  width: 4),
                        ),
                      ),
                    if (piece != null)
                      Text(
                        _pieceGlyph(piece),
                        style: TextStyle(
                          fontSize: 42,
                          height: 1,
                          color: _isWhitePiece(piece)
                              ? Colors.white
                              : Colors.black,
                          shadows: const [
                            Shadow(color: Colors.black45, blurRadius: 1)
                          ],
                        ),
                      ),
                    if (column == 0)
                      Positioned(
                        top: 2,
                        left: 3,
                        child: Text('${ranks[row]}',
                            style: _coordinateStyle(isLight)),
                      ),
                    if (row == 7)
                      Positioned(
                        right: 3,
                        bottom: 1,
                        child: Text(files[column],
                            style: _coordinateStyle(isLight)),
                      ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Map<String, String> _piecesFromFen(String fen) {
    final pieces = <String, String>{};
    final rows = fen.split(' ').first.split('/');
    for (var row = 0; row < 8; row++) {
      var file = 0;
      for (final character in rows[row].split('')) {
        final emptySquares = int.tryParse(character);
        if (emptySquares != null) {
          file += emptySquares;
        } else {
          pieces['${String.fromCharCode('a'.codeUnitAt(0) + file)}${8 - row}'] =
              character;
          file++;
        }
      }
    }
    return pieces;
  }

  bool _isWhitePiece(String piece) => piece == piece.toUpperCase();

  String _pieceGlyph(String piece) {
    const glyphs = {
      'K': '♔',
      'Q': '♕',
      'R': '♖',
      'B': '♗',
      'N': '♘',
      'P': '♙',
      'k': '♚',
      'q': '♛',
      'r': '♜',
      'b': '♝',
      'n': '♞',
      'p': '♟',
    };
    return glyphs[piece]!;
  }

  TextStyle _coordinateStyle(bool isLight) => TextStyle(
        color: isLight ? const Color(0xffb58863) : const Color(0xfff0d9b5),
        fontSize: 11,
        fontWeight: FontWeight.bold,
      );
}
