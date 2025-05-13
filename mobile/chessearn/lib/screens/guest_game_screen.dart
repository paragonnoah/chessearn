import 'package:flutter/material.dart';
import 'package:flutter_chess_board/flutter_chess_board.dart';
import 'package:chess/chess.dart' as chess;
import 'package:chessearn/screens/home_screen.dart';
import 'package:chessearn/theme.dart';

class GuestGameScreen extends StatefulWidget {
  const GuestGameScreen({super.key});

  @override
  _GuestGameScreenState createState() => _GuestGameScreenState();
}

class _GuestGameScreenState extends State<GuestGameScreen> {
  ChessBoardController controller = ChessBoardController();
  String gameStatus = 'White to move';
  List<String> moveHistory = [];
  bool showLegalMoves = true; // State for toggling move indicators
  String? selectedSquare; // Use String for algebraic notation (e.g., 'e2')
  List<String> legalDestinations = []; // Store legal destination squares

  @override
  void initState() {
    super.initState();
    _checkGameState();
    controller.addListener(_updateLegalMoves);
  }

  void _checkGameState() {
    setState(() {
      final game = controller.game;
      if (game.in_checkmate) {
        gameStatus = 'Checkmate!';
      } else if (game.in_stalemate) {
        gameStatus = 'Stalemate!';
      } else if (game.in_check) {
        gameStatus = 'Check!';
      } else {
        gameStatus = '${game.turn == chess.Color.WHITE ? 'White' : 'Black'} to move';
      }

     final moveList = game.moves();
if (moveList.every((move) => move is String)) {
  moveHistory = (moveList as List<String>).reversed.toList();
} else {
  moveHistory = [];
}
    });
  }

  void _resetGame() {
    setState(() {
      controller.game = chess.Chess();
      gameStatus = 'White to move';
      moveHistory.clear();
      selectedSquare = null;
      legalDestinations.clear();
      _checkGameState();
    });
  }

  void _undoMove() {
    setState(() {
      if (moveHistory.isNotEmpty) {
        final game = controller.game;
        game.undo();
        moveHistory.removeLast();
        selectedSquare = null;
        legalDestinations.clear();
        _checkGameState();
      }
    });
  }

  void _updateLegalMoves() {
    if (showLegalMoves && selectedSquare != null) {
      final game = controller.game;
      final moves = game.generate_moves({'square': selectedSquare}) as List<Map>;
      legalDestinations = moves.map((move) {
        return move['to'] as String;
      }).toList();
      setState(() {});
    } else {
      legalDestinations.clear();
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final boardSize = MediaQuery.of(context).size.width * 0.9;
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              ChessEarnTheme.themeColors['brand-gradient-start']!,
              ChessEarnTheme.themeColors['brand-gradient-end']!,
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Column(
          children: [
            // Navigation Bar
            Container(
              padding: const EdgeInsets.all(16.0),
              color: ChessEarnTheme.themeColors['brand-dark'],
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'ChessEarn (Guest)',
                    style: TextStyle(
                      color: ChessEarnTheme.themeColors['text-light'],
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Row(
                    children: [
                      TextButton(
                        onPressed: () {
                          Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const HomeScreen()));
                        },
                        child: Text('Home', style: TextStyle(color: ChessEarnTheme.themeColors['brand-accent'])),
                      ),
                      TextButton(
                        onPressed: () {},
                        child: Text('Bet', style: TextStyle(color: ChessEarnTheme.themeColors['brand-accent'])),
                      ),
                      // No Profile button for guests
                      ElevatedButton(
                        onPressed: () {
                          // Guest logout can simply go to HomeScreen
                          Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const HomeScreen()));
                        },
                        child: const Text('Exit'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // Main Content
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Toggle for showing legal moves
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Show Legal Moves',
                            style: TextStyle(
                              color: ChessEarnTheme.themeColors['text-light'],
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Switch(
                            value: showLegalMoves,
                            onChanged: (value) {
                              setState(() {
                                showLegalMoves = value;
                                if (!showLegalMoves) {
                                  selectedSquare = null;
                                  legalDestinations.clear();
                                }
                              });
                            },
                            activeColor: ChessEarnTheme.themeColors['brand-accent'],
                          ),
                        ],
                      ),
                    ),
                    // Chessboard with legal move indicators
                    Container(
                      margin: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 16.0),
                      decoration: BoxDecoration(
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Stack(
                        children: [
                          ChessBoard(
                            controller: controller,
                            boardColor: BoardColor.brown,
                            size: boardSize,
                            onMove: () {
                              _checkGameState();
                              if (showLegalMoves) {
                                final game = controller.game;
                                final moves = game.moves();
                                if (moves.isNotEmpty) {
                                  final lastMove = moves.last;
                                  if (lastMove.length >= 2) {
                                    selectedSquare = lastMove.substring(0, 2);
                                    _updateLegalMoves();
                                  }
                                }
                              }
                            },
                            enableUserMoves: true,
                          ),
                          if (showLegalMoves && legalDestinations.isNotEmpty)
                            ...legalDestinations.map((square) {
                              if (square.length < 2) return const SizedBox.shrink();
                              final file = square[0].codeUnitAt(0) - 'a'.codeUnitAt(0);
                              final rank = int.parse(square[1]) - 1;
                              final squareSize = boardSize / 8;
                              return Positioned(
                                left: file * squareSize + squareSize * 0.4,
                                top: (7 - rank) * squareSize + squareSize * 0.4,
                                child: Container(
                                  width: squareSize * 0.2,
                                  height: squareSize * 0.2,
                                  decoration: BoxDecoration(
                                    color: ChessEarnTheme.themeColors['brand-accent']!.withOpacity(0.5),
                                    shape: BoxShape.circle,
                                  ),
                                ),
                              );
                            }),
                        ],
                      ),
                    ),
                    // Game Status
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Text(
                        gameStatus,
                        style: TextStyle(fontSize: 18, color: ChessEarnTheme.themeColors['text-light']),
                      ),
                    ),
                    // Action Buttons
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ElevatedButton(
                          onPressed: _resetGame,
                          child: const Text('New Game'),
                        ),
                        const SizedBox(width: 10),
                        ElevatedButton(
                          onPressed: moveHistory.isNotEmpty ? _undoMove : null,
                          child: const Text('Undo Move'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    // Move History
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Move History',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: ChessEarnTheme.themeColors['text-light'],
                            ),
                          ),
                          const SizedBox(height: 10),
                          Container(
                            height: 150,
                            padding: const EdgeInsets.all(8.0),
                            decoration: BoxDecoration(
                              color: ChessEarnTheme.themeColors['surface-dark']!.withOpacity(0.5),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: ListView.builder(
                              itemCount: moveHistory.length,
                              itemBuilder: (context, index) {
                                final moveNumber = (index ~/ 2) + 1;
                                final isWhiteMove = index % 2 == 0;
                                final moveText = isWhiteMove
                                    ? '$moveNumber. ${moveHistory[index]}'
                                    : '${moveHistory[index]}';
                                return Text(
                                  moveText,
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: ChessEarnTheme.themeColors['text-light'],
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    controller.removeListener(_updateLegalMoves);
    controller.dispose();
    super.dispose();
  }
}