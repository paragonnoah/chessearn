import 'package:flutter/material.dart';
import 'package:flutter_chess_board/flutter_chess_board.dart';
import 'package:chess/chess.dart' as chess;
import 'package:chessearn_new/screens/home_screen.dart';
import 'package:chessearn_new/screens/profile_screen.dart';
import 'package:chessearn_new/services/api_service.dart';
import 'package:chessearn_new/theme.dart';
import 'dart:math';
import 'dart:async';

class GameScreen extends StatefulWidget {
  final String? userId;
  final String initialPlayMode;
  final String? timeControl;
  final String? opponentId; // Added to accept the friend's userId

  const GameScreen({
    super.key,
    required this.userId,
    required this.initialPlayMode,
    this.timeControl,
    this.opponentId,
  });

  @override
  _GameScreenState createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  ChessBoardController controller = ChessBoardController();
  String gameStatus = 'White to move';
  List<String> moveHistory = []; // Track SAN moves manually
  List<Map<String, String>> pairedMoves = []; // For displaying moves like "1. e4 e5"
  bool showLegalMoves = true;
  String? selectedSquare;
  List<String> legalDestinations = [];
  bool playAgainstComputer = false;
  String difficulty = 'Easy';
  bool isUserTurn = true;
  late String playMode;
  int earnedPoints = 0;
  bool drawOffered = false;
  bool drawAccepted = false;
  String? lastFenBeforeMove; // Track the FEN before the last move, explicitly typed as String?

  // Timer variables
  late int whiteTime;
  late int blackTime;
  int whiteIncrement = 0;
  int blackIncrement = 0;
  Timer? _timer;
  bool isGameOver = false;

  // Messages section
  List<Map<String, String>> messages = [
    {'sender': 'You', 'text': 'Good luck!'},
    {'sender': 'Opponent', 'text': 'Thanks, you too!'},
  ];

  @override
  void initState() {
    super.initState();
    playMode = widget.initialPlayMode;
    playAgainstComputer = playMode == 'computer';
    _initializeTimers();
    _checkGameState();
    lastFenBeforeMove = controller.game.fen; // Initialize with starting position
    _startTimer();
    if (playMode == 'online' && widget.opponentId != null) {
      _startOnlineGameWithOpponent();
    }
  }

  void _startOnlineGameWithOpponent() async {
    try {
      // Notify the backend to start a game session with the opponent
      await ApiService.postGameMove('start_game:${widget.opponentId}');
      setState(() {
        messages.add({'sender': 'System', 'text': 'Game started with opponent!'});
      });
    } catch (e) {
      setState(() {
        gameStatus = 'Failed to start game: $e';
      });
    }
  }

  void _initializeTimers() {
    if (widget.timeControl == null || widget.timeControl == 'N/A') {
      whiteTime = 600;
      blackTime = 600;
      return;
    }

    if (widget.timeControl!.contains('d')) {
      final days = int.parse(widget.timeControl!.replaceAll('d', ''));
      whiteTime = days * 24 * 60 * 60;
      blackTime = whiteTime;
      return;
    }

    final parts = widget.timeControl!.split('|');
    final minutes = int.parse(parts[0]);
    whiteTime = minutes * 60;
    blackTime = whiteTime;
    if (parts.length > 1) {
      whiteIncrement = int.parse(parts[1]);
      blackIncrement = whiteIncrement;
    }
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (isGameOver) {
        timer.cancel();
        return;
      }
      setState(() {
        if (controller.game.turn == chess.Color.WHITE && isUserTurn) {
          whiteTime = (whiteTime - 1).clamp(0, whiteTime);
          if (whiteTime <= 0) {
            gameStatus = 'Time out! Black wins!';
            isGameOver = true;
            timer.cancel();
          }
        } else if (controller.game.turn == chess.Color.BLACK && !isUserTurn) {
          blackTime = (blackTime - 1).clamp(0, blackTime);
          if (blackTime <= 0) {
            gameStatus = 'Time out! White wins!';
            if (playAgainstComputer) earnedPoints += 50;
            isGameOver = true;
            timer.cancel();
          }
        }
      });
    });
  }

  String _formatTime(int seconds) {
    final minutes = (seconds ~/ 60).toString().padLeft(2, '0');
    final secs = (seconds % 60).toString().padLeft(2, '0');
    return '$minutes:$secs';
  }

  void _checkGameState() {
    setState(() {
      final game = controller.game;
      if (game.in_checkmate) {
        gameStatus = playAgainstComputer && !isUserTurn
            ? 'Checkmate! You lose!'
            : 'Checkmate! You win! +50 points';
        if (gameStatus.contains('You win!')) earnedPoints += 50;
        isGameOver = true;
      } else if (game.in_stalemate) {
        gameStatus = 'Stalemate!';
        isGameOver = true;
      } else if (game.in_check) {
        gameStatus = playAgainstComputer && !isUserTurn
            ? 'Check! Computer is in check.'
            : 'Check!';
      } else {
        gameStatus = '${game.turn == chess.Color.WHITE ? 'White' : 'Black'} to move';
      }

      // Update paired moves from moveHistory
      pairedMoves = [];
      for (int i = 0; i < moveHistory.length; i += 2) {
        final moveNumber = (i ~/ 2) + 1;
        final whiteMove = moveHistory[i];
        final blackMove = i + 1 < moveHistory.length ? moveHistory[i + 1] : '';
        pairedMoves.add({
          'moveNumber': moveNumber.toString(),
          'whiteMove': whiteMove,
          'blackMove': blackMove,
        });
      }
    });

    if (widget.userId != null && moveHistory.isNotEmpty) {
      final lastMove = moveHistory.last;
      ApiService.postGameMove(lastMove).catchError((e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to sync move: $e')),
        );
      });
    }

    if (!isGameOver) {
      if (controller.game.turn == chess.Color.BLACK && isUserTurn) {
        whiteTime += whiteIncrement;
      } else if (controller.game.turn == chess.Color.WHITE && !isUserTurn) {
        blackTime += blackIncrement;
      }
    }
  }

  Future<void> _logout() async {
    await ApiService.logout();
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const HomeScreen()));
  }

  void _resetGame() {
    setState(() {
      controller.game.reset();
      gameStatus = 'White to move';
      moveHistory.clear();
      pairedMoves.clear();
      selectedSquare = null;
      legalDestinations.clear();
      isUserTurn = true;
      isGameOver = false;
      drawOffered = false;
      drawAccepted = false;
      messages = [
        {'sender': 'You', 'text': 'Good luck!'},
        {'sender': 'Opponent', 'text': 'Thanks, you too!'},
      ];
      lastFenBeforeMove = controller.game.fen;
      _initializeTimers();
      if (playMode == 'computer' && !isUserTurn) _makeComputerMove();
      _checkGameState();
      _startTimer();
      if (playMode == 'online' && widget.opponentId != null) {
        _startOnlineGameWithOpponent();
      }
    });
  }

  void _undoMove() {
    setState(() {
      if (moveHistory.isNotEmpty) {
        final game = controller.game;
        game.undo();
        if (moveHistory.length > 1) game.undo(); // Undo both moves if possible
        moveHistory.removeLast();
        if (moveHistory.isNotEmpty) moveHistory.removeLast(); // Remove pair
        pairedMoves.clear();
        for (int i = 0; i < moveHistory.length; i += 2) {
          final moveNumber = (i ~/ 2) + 1;
          final whiteMove = moveHistory[i];
          final blackMove = i + 1 < moveHistory.length ? moveHistory[i + 1] : '';
          pairedMoves.add({
            'moveNumber': moveNumber.toString(),
            'whiteMove': whiteMove,
            'blackMove': blackMove,
          });
        }
        selectedSquare = null;
        legalDestinations.clear();
        isUserTurn = true;
        if (playMode == 'computer' && !isUserTurn) _makeComputerMove();
        _checkGameState();
      }
    });
  }

  void _updateLegalMoves() {
    if (showLegalMoves && selectedSquare != null && isUserTurn) {
      final game = controller.game;
      final moves = game.generate_moves({'square': selectedSquare}) as List<Map>;
      legalDestinations = moves.map((move) => move['to'].toString()).toList();
      setState(() {});
    } else {
      legalDestinations.clear();
      setState(() {});
    }
  }

  void _makeComputerMove() {
    if (!isUserTurn && playAgainstComputer) {
      final game = controller.game;
      final computerMove = _getComputerMove(game);
      if (computerMove != null) {
        try {
          final from = computerMove.substring(0, 2);
          final to = computerMove.substring(2, 4);
          final tempGame = chess.Chess.fromFEN(game.fen);
          final moveResult = tempGame.move({'from': from, 'to': to});
          if (moveResult is Map<String, dynamic> && moveResult.containsKey('san')) {
            final sanMove = moveResult['san'] as String;
            controller.makeMove(from: from, to: to);
            moveHistory.insert(0, sanMove);
            messages.add({'sender': 'Opponent', 'text': 'Nice move!'});
            _checkGameState();
            isUserTurn = true;
            if (widget.userId != null) {
              ApiService.postGameMove(sanMove).catchError((e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Failed to sync computer move: $e')),
                );
              });
            }
          } else {
            isUserTurn = true;
          }
        } catch (e) {
          isUserTurn = true;
        }
      } else {
        isUserTurn = true;
      }
    }
  }

  String? _getComputerMove(chess.Chess game) {
    final legalMoves = game.moves();
    if (legalMoves.isEmpty) return null;
    if (difficulty == 'Easy') {
      return _getEasyMove(legalMoves);
    } else if (difficulty == 'Medium') {
      return _getMediumMove(game, legalMoves);
    } else {
      return _getHardMove(game, legalMoves);
    }
  }

  String _getEasyMove(List<dynamic> legalMoves) {
    final random = Random();
    return legalMoves[random.nextInt(legalMoves.length)].toString();
  }

  String _getMediumMove(chess.Chess game, List<dynamic> legalMoves) {
    for (var move in legalMoves) {
      final tempGame = chess.Chess.fromFEN(game.fen);
      tempGame.move(move);
      final moveStr = move.toString();
      if (moveStr.contains('x')) return moveStr;
    }
    return _getEasyMove(legalMoves);
  }

  String _getHardMove(chess.Chess game, List<dynamic> legalMoves) {
    int bestScore = -9999;
    String? bestMove;
    for (var move in legalMoves) {
      final tempGame = chess.Chess.fromFEN(game.fen);
      tempGame.move(move);
      int score = -_evaluateBoard(tempGame, 1);
      if (score > bestScore) {
        bestScore = score;
        bestMove = move.toString();
      }
    }
    return bestMove ?? _getEasyMove(legalMoves);
  }

  int _evaluateBoard(chess.Chess game, int depth) {
    if (game.in_checkmate || depth == 0) {
      return game.turn == chess.Color.BLACK ? -9999 : 9999;
    }
    if (game.in_stalemate || game.insufficient_material) {
      return 0;
    }
    int score = 0;
    final pieceValues = {'p': 1, 'n': 3, 'b': 3, 'r': 5, 'q': 9, 'k': 0};
    const files = ['a', 'b', 'c', 'd', 'e', 'f', 'g', 'h'];
    const ranks = ['1', '2', '3', '4', '5', '6', '7', '8'];
    for (var file in files) {
      for (var rank in ranks) {
        final square = '$file$rank';
        final piece = game.get(square);
        if (piece != null) {
          final pieceType = piece.type.toString().toLowerCase();
          final isWhite = piece.color == chess.Color.WHITE;
          final value = pieceValues[pieceType] ?? 0;
          score += (isWhite ? value : -value);
        }
      }
    }
    return score;
  }

  void _selectPlayMode(String mode) {
    setState(() {
      playMode = mode;
      playAgainstComputer = mode == 'computer';
      if (mode == 'computer' && !isUserTurn) _makeComputerMove();
    });
  }

  void _offerDraw() {
    if (isGameOver) return;
    setState(() {
      drawOffered = true;
      messages.add({'sender': 'You', 'text': 'I offer a draw.'});
    });

    if (playAgainstComputer) {
      final random = Random();
      final acceptDraw = random.nextBool();
      Future.delayed(const Duration(seconds: 1), () {
        setState(() {
          if (acceptDraw) {
            drawAccepted = true;
            gameStatus = 'Draw accepted!';
            isGameOver = true;
            messages.add({'sender': 'Opponent', 'text': 'Draw accepted!'});
          } else {
            messages.add({'sender': 'Opponent', 'text': 'Draw declined.'});
            drawOffered = false;
          }
        });
      });
    }
  }

  void _resignGame() {
    if (isGameOver) return;
    setState(() {
      gameStatus = 'You resigned! Opponent wins!';
      isGameOver = true;
      messages.add({'sender': 'You', 'text': 'I resign.'});
      messages.add({'sender': 'Opponent', 'text': 'Good game!'});
    });
  }

  void _showSettingsDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Settings'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Settings options coming soon!'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _handleMove() {
    final game = controller.game;
    if (game.history.isNotEmpty && isUserTurn) {
      final currentFen = game.fen;
      if (lastFenBeforeMove != null) {
        final tempGame = chess.Chess.fromFEN(lastFenBeforeMove!);
        final moves = tempGame.generate_moves();
        for (var move in moves) {
          final tempGameCopy = chess.Chess.fromFEN(lastFenBeforeMove!);
          final moveResult = tempGameCopy.move({
            'from': move['from'],
            'to': move['to'],
          });
          if (moveResult is Map<String, dynamic> && moveResult.containsKey('san')) {
            final newFen = tempGameCopy.fen;
            if (newFen == currentFen) {
              final sanMove = moveResult['san'] as String;
              setState(() {
                moveHistory.insert(0, sanMove);
                _checkGameState();
                messages.add({'sender': 'You', 'text': 'Your move!'});
                if (playAgainstComputer && !game.game_over && game.turn == chess.Color.BLACK) {
                  isUserTurn = false;
                  Future.delayed(const Duration(milliseconds: 500), () {
                    _makeComputerMove();
                  });
                } else if (playMode == 'online' && widget.opponentId != null && !game.game_over) {
                  isUserTurn = false;
                  _syncMoveWithOpponent(sanMove);
                } else {
                  isUserTurn = true;
                }
                lastFenBeforeMove = currentFen; // Update for the next move
              });
              break;
            }
          }
        }
      }
    }
    if (showLegalMoves) {
      final moves = game.moves();
      if (moves.isNotEmpty) {
        final lastMove = moves.last;
        final moveStr = lastMove.toString();
        if (moveStr.length >= 2) {
          selectedSquare = moveStr.substring(0, 2);
          _updateLegalMoves();
        }
      }
    }
  }

  Future<void> _syncMoveWithOpponent(String move) async {
    try {
      await ApiService.postGameMove('$move:${widget.opponentId}');
      setState(() {
        messages.add({'sender': 'System', 'text': 'Move synced with opponent!'});
      });
      // Placeholder for receiving opponent's move (requires WebSocket or polling)
      isUserTurn = false; // Wait for opponent's move
    } catch (e) {
      setState(() {
        gameStatus = 'Failed to sync move: $e';
      });
      isUserTurn = true; // Allow user to retry or continue
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
            // Header
            Container(
              padding: const EdgeInsets.all(16.0),
              color: ChessEarnTheme.themeColors['brand-dark'],
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'ChessEarn',
                    style: TextStyle(
                      color: ChessEarnTheme.themeColors['text-light'],
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      shadows: const [
                        Shadow(
                          color: Colors.black45,
                          offset: Offset(2, 2),
                          blurRadius: 4,
                        ),
                      ],
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
                      TextButton(
                        onPressed: widget.userId != null
                            ? () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (context) => ProfileScreen(userId: widget.userId!)),
                                );
                              }
                            : null,
                        child: Text('Profile', style: TextStyle(color: ChessEarnTheme.themeColors['brand-accent'])),
                      ),
                      ElevatedButton(
                        onPressed: widget.userId != null ? _logout : null,
                        child: const Text('Logout'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            if (widget.userId == null)
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  'Playing as Guest - Sign up to earn rewards!',
                  style: TextStyle(color: ChessEarnTheme.themeColors['text-muted'], fontSize: 16),
                ),
              ),
            // Timers and Play Mode
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: [
                  if (playMode.isEmpty)
                    Column(
                      children: [
                        Text('Select Play Mode', style: TextStyle(color: ChessEarnTheme.themeColors['text-light'], fontSize: 18)),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            ElevatedButton(
                              onPressed: () => _selectPlayMode('computer'),
                              child: const Text('Vs Computer'),
                            ),
                            const SizedBox(width: 10),
                            ElevatedButton(
                              onPressed: () => _selectPlayMode('online'),
                              child: const Text('Play Online'),
                            ),
                          ],
                        ),
                      ],
                    ),
                  if (playMode == 'computer')
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text('Play vs Computer'),
                        Switch(
                          value: playAgainstComputer,
                          onChanged: (value) {
                            setState(() {
                              playAgainstComputer = value;
                              if (value && !isUserTurn) _makeComputerMove();
                            });
                          },
                          activeColor: ChessEarnTheme.themeColors['brand-accent'],
                        ),
                        if (playAgainstComputer)
                          DropdownButton<String>(
                            value: difficulty,
                            onChanged: (String? newValue) {
                              setState(() {
                                difficulty = newValue!;
                                if (!isUserTurn) _makeComputerMove();
                              });
                            },
                            items: ['Easy', 'Medium', 'Hard']
                                .map<DropdownMenuItem<String>>((String value) {
                              return DropdownMenuItem<String>(
                                value: value,
                                child: Text(value),
                              );
                            }).toList(),
                          ),
                      ],
                    ),
                  if (playMode.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Text(
                            'Time Control: ${widget.timeControl ?? "N/A"}',
                            style: TextStyle(color: ChessEarnTheme.themeColors['text-light'], fontSize: 16),
                          ),
                          Row(
                            children: [
                              Text(
                                'White: ${_formatTime(whiteTime)}',
                                style: TextStyle(
                                  color: controller.game.turn == chess.Color.WHITE
                                      ? ChessEarnTheme.themeColors['brand-accent']
                                      : ChessEarnTheme.themeColors['text-light'],
                                  fontSize: 16,
                                ),
                              ),
                              const SizedBox(width: 20),
                              Text(
                                'Black: ${_formatTime(blackTime)}',
                                style: TextStyle(
                                  color: controller.game.turn == chess.Color.BLACK
                                      ? ChessEarnTheme.themeColors['brand-accent']
                                      : ChessEarnTheme.themeColors['text-light'],
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
            // Main Game Content
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (playMode.isNotEmpty)
                      Column(
                        children: [
                          // Chessboard
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
                                    // Capture the FEN before the move is processed (use the current FEN as pre-move state)
                                    lastFenBeforeMove = controller.game.fen;
                                    _handleMove();
                                  },
                                  enableUserMoves: isUserTurn || !playAgainstComputer || playMode == 'online',
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
                          // Game Status and Points
                          Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              children: [
                                Text(
                                  gameStatus,
                                  style: TextStyle(fontSize: 18, color: ChessEarnTheme.themeColors['text-light']),
                                ),
                                Text(
                                  'Earned Points: $earnedPoints',
                                  style: TextStyle(fontSize: 16, color: ChessEarnTheme.themeColors['brand-accent']),
                                ),
                              ],
                            ),
                          ),
                          // Options: Draw, Resign, Settings
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                ElevatedButton(
                                  onPressed: drawOffered || isGameOver ? null : _offerDraw,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.blueAccent,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                  child: const Text('Draw'),
                                ),
                                ElevatedButton(
                                  onPressed: isGameOver ? null : _resignGame,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.redAccent,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                  child: const Text('Resign'),
                                ),
                                ElevatedButton(
                                  onPressed: _showSettingsDialog,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.grey,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                  child: const Text('Settings'),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 20),
                          // Move History
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Moves',
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
                                    color: ChessEarnTheme.themeColors['surface-dark'],
                                    borderRadius: BorderRadius.circular(10),
                                    boxShadow: const [
                                      BoxShadow(
                                        color: Colors.black26,
                                        offset: Offset(0, 2),
                                        blurRadius: 4,
                                      ),
                                    ],
                                  ),
                                  child: ListView.builder(
                                    itemCount: pairedMoves.length,
                                    itemBuilder: (context, index) {
                                      final move = pairedMoves[index];
                                      return Padding(
                                        padding: const EdgeInsets.symmetric(vertical: 4.0),
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.start,
                                          children: [
                                            SizedBox(
                                              width: 40,
                                              child: Text(
                                                '${move['moveNumber']}.',
                                                style: const TextStyle(
                                                  fontSize: 16,
                                                  color: Colors.white,
                                                ),
                                              ),
                                            ),
                                            Expanded(
                                              child: Text(
                                                move['whiteMove']!,
                                                style: const TextStyle(
                                                  fontSize: 16,
                                                  color: Colors.white,
                                                ),
                                              ),
                                            ),
                                            if (move['blackMove']!.isNotEmpty)
                                              Expanded(
                                                child: Text(
                                                  move['blackMove']!,
                                                  style: const TextStyle(
                                                    fontSize: 16,
                                                    color: Colors.white,
                                                  ),
                                                ),
                                              ),
                                          ],
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 20),
                          // Messages Section
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Messages',
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
                                    boxShadow: const [
                                      BoxShadow(
                                        color: Colors.black26,
                                        offset: Offset(0, 2),
                                        blurRadius: 4,
                                      ),
                                    ],
                                  ),
                                  child: ListView.builder(
                                    itemCount: messages.length,
                                    itemBuilder: (context, index) {
                                      final message = messages[index];
                                      final isUser = message['sender'] == 'You';
                                      return Padding(
                                        padding: const EdgeInsets.symmetric(vertical: 4.0),
                                        child: Row(
                                          mainAxisAlignment:
                                              isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
                                          children: [
                                            if (!isUser)
                                              const Icon(Icons.person, color: Colors.white, size: 16),
                                            const SizedBox(width: 8),
                                            Container(
                                              padding: const EdgeInsets.all(8.0),
                                              decoration: BoxDecoration(
                                                color: isUser ? Colors.blueAccent : Colors.grey,
                                                borderRadius: BorderRadius.circular(8),
                                              ),
                                              child: Text(
                                                '${message['sender']}: ${message['text']}',
                                                style: const TextStyle(color: Colors.white),
                                              ),
                                            ),
                                            if (isUser)
                                              const SizedBox(width: 8),
                                            if (isUser)
                                              const Icon(Icons.person, color: Colors.white, size: 16),
                                          ],
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 20),
                          // New Game and Undo Buttons
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              ElevatedButton(
                                onPressed: _resetGame,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.green,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                                child: const Text('New Game'),
                              ),
                              const SizedBox(width: 10),
                              ElevatedButton(
                                onPressed: moveHistory.isNotEmpty && !isGameOver ? _undoMove : null,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.orange,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                                child: const Text('Undo Move'),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
                        ],
                      ),
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
    _timer?.cancel();
    controller.dispose();
    super.dispose();
  }
}

extension on bool {
  bool containsKey(String s) => false; // Always return false for bool, as it doesn’t support keys
  
  dynamic operator [](String other) => throw UnsupportedError('Cannot use index operator on bool'); // Throw error to prevent invalid usage
}

extension on chess.Move {
  dynamic operator [](String other) {
    if (other == 'from') return fromAlgebraic;
    if (other == 'to') return toAlgebraic;
    if (other == 'san') return null; // SAN isn’t directly on Move, handled by game.move
    return null; // Default to null for unsupported keys
  }
}