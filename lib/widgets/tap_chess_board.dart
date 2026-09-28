// ============================================================================
// Section: External Library Imports
// Imports Flutter Material UI library for custom chessboard rendering.
// ============================================================================
import 'package:flutter/material.dart';

// ============================================================================
// Section: Interactive TapChessBoard Widget (`TapChessBoard`)
// Custom StatefulWidget implementing tap-to-select and tap-to-move chessboard grid interface.
// ============================================================================
class TapChessBoard extends StatefulWidget {
  // --------------------------------------------------------------------------
  // Sub-Block: Widget Constructor & Property Parameters
  // Defines parameters for FEN string, player orientation, interactivity boolean, move callbacks, and last moves.
  // --------------------------------------------------------------------------
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

// ============================================================================
// Section: TapChessBoard State Logic (`_TapChessBoardState`)
// Manages selected square state, handles user taps, and renders 8x8 grid cells.
// ============================================================================
class _TapChessBoardState extends State<TapChessBoard> {
  // --------------------------------------------------------------------------
  // Sub-Block: Selection State Tracking
  // Currently highlighted selected origin square string (e.g. "e2").
  // --------------------------------------------------------------------------
  String? _selectedSquare;

  // --------------------------------------------------------------------------
  // Sub-Block: Widget Update Lifecycle Hook (`didUpdateWidget`)
  // Clears square selection when FEN board state updates or interactivity changes.
  // --------------------------------------------------------------------------
  @override
  void didUpdateWidget(TapChessBoard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.fen != widget.fen || !widget.isInteractive) {
      _selectedSquare = null;
    }
  }

  // --------------------------------------------------------------------------
  // Sub-Block: User Tap Input Handler (`_handleTap`)
  // Evaluates tapped square: executes move if legal target square, or updates selection if player piece.
  // --------------------------------------------------------------------------
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

  // --------------------------------------------------------------------------
  // Sub-Block: Main Board Grid Builder (`build`)
  // Builds outer board border and 8x8 GridView displaying all 64 chess squares.
  // --------------------------------------------------------------------------
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

          // ------------------------------------------------------------------
          // Sub-Block: Square Cell Rendering & Tap Listener
          // Renders cell background colors (normal light/dark, selected yellow, last move highlight).
          // ------------------------------------------------------------------
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
                    // --------------------------------------------------------
                    // Sub-Block: Legal Target Move Indicator Overlay
                    // Draws dot overlay on empty target squares and border ring on target capture squares.
                    // --------------------------------------------------------
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

                    // --------------------------------------------------------
                    // Sub-Block: Chess Piece Symbol Text Display
                    // Displays Unicode glyph for chess pieces positioned on current square.
                    // --------------------------------------------------------
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

                    // --------------------------------------------------------
                    // Sub-Block: Rank & File Coordinate Corner Labels
                    // Displays file letters ('a'-'h') on bottom row and rank numbers (1-8) on left column.
                    // --------------------------------------------------------
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

  // --------------------------------------------------------------------------
  // Sub-Block: FEN Board Parser (`_piecesFromFen`)
  // Parses chess FEN placement string into a Map of algebraic squares to piece characters.
  // --------------------------------------------------------------------------
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

  // --------------------------------------------------------------------------
  // Sub-Block: White Piece Checker (`_isWhitePiece`)
  // Returns true if piece character is uppercase (White piece convention).
  // --------------------------------------------------------------------------
  bool _isWhitePiece(String piece) => piece == piece.toUpperCase();

  // --------------------------------------------------------------------------
  // Sub-Block: Piece Character to Unicode Glyph Converter (`_pieceGlyph`)
  // Maps standard FEN piece characters ('K','Q','R','B','N','P', etc.) to Unicode chess symbols.
  // --------------------------------------------------------------------------
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

  // --------------------------------------------------------------------------
  // Sub-Block: Coordinate Text Style Helper (`_coordinateStyle`)
  // Computes contrasting text style for rank/file label text based on square light/dark background.
  // --------------------------------------------------------------------------
  TextStyle _coordinateStyle(bool isLight) => TextStyle(
        color: isLight ? const Color(0xffb58863) : const Color(0xfff0d9b5),
        fontSize: 11,
        fontWeight: FontWeight.bold,
      );
}
