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
  final String? timeControl; // New parameter

  const GameScreen({
    super.key,
    required this.userId,
    required this.initialPlayMode,
    this.timeControl,
  });

  @override
  _GameScreenState createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  ChessBoardController controller = ChessBoardController();
  String gameStatus = 'White to move';
  List<String> moveHistory = [];
  bool showLegalMoves = true;
  String? selectedSquare;
  List<String> legalDestinations = [];
  bool playAgainstComputer = false;
  String difficulty = 'Easy';
  bool isUserTurn = true;
  late String playMode;
  int earnedPoints = 0;

  // Timer variables
  late int whiteTime; // In seconds
  late int blackTime; // In seconds
  int whiteIncrement = 0; // Increment per move in seconds
  int blackIncrement = 0; // Increment per move in seconds
  Timer? _timer;
  bool isGameOver = false;

  @override
  void initState() {
    super.initState();
    playMode = widget.initialPlayMode;
    playAgainstComputer = playMode == 'computer';
    
    // Initialize timers based on timeControl (e.g., "15|10" means 15 minutes + 10 seconds increment)
    _initializeTimers();
    
    _checkGameState();
    controller.addListener(_updateLegalMoves);
    _startTimer();
  }

  void _initializeTimers() {
    if (widget.timeControl == null || widget.timeControl == 'N/A') {
      whiteTime = 600; // Default to 10 minutes if no time control
      blackTime = 600;
      return;
    }

    if (widget.timeControl!.contains('d')) {
      // Daily games: set a large timer (e.g., 1 day = 86400 seconds)
      final days = int.parse(widget.timeControl!.replaceAll('d', ''));
      whiteTime = days * 24 * 60 * 60;
      blackTime = whiteTime;
      return;
    }

    final parts = widget.timeControl!.split('|');
    final minutes = int.parse(parts[0]);
    whiteTime = minutes * 60; // Convert minutes to seconds
    blackTime = whiteTime;
    if (parts.length > 1) {
      whiteIncrement = int.parse(parts[1]);
      blackIncrement = whiteIncrement;
    }
  }

  void _startTimer() {
    _timer?.cancel(); // Cancel any existing timer
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
      final moveList = game.moves().map((move) => move.toString()).toList();
      if (moveList.isNotEmpty) {
        moveHistory = moveList.reversed.toList();
      } else {
        moveHistory = [];
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

    // Apply increment after a move
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
      selectedSquare = null;
      legalDestinations.clear();
      isUserTurn = true;
      isGameOver = false;
      _initializeTimers(); // Reset timers
      if (playMode == 'computer' && !isUserTurn) _makeComputerMove();
      _checkGameState();
      _startTimer(); // Restart timer
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
    print('Attempting computer move...');
    print('isUserTurn: $isUserTurn, playAgainstComputer: $playAgainstComputer');
    if (!isUserTurn && playAgainstComputer) {
      final game = controller.game;
      print('Game turn: ${game.turn == chess.Color.WHITE ? 'White' : 'Black'}');
      final computerMove = _getComputerMove(game);
      if (computerMove != null) {
        print('Computer move selected: $computerMove');
        try {
          final from = computerMove.substring(0, 2);
          final to = computerMove.substring(2, 4);
          print('Making move from $from to $to');
          controller.makeMove(from: from, to: to);
          moveHistory.insert(0, computerMove);
          _checkGameState();
          isUserTurn = true;
          print('Computer move completed, isUserTurn: $isUserTurn');
          if (widget.userId != null) {
            ApiService.postGameMove(computerMove).catchError((e) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Failed to sync computer move: $e')),
              );
            });
          }
        } catch (e) {
          print('Error making computer move: $e');
          isUserTurn = true;
        }
      } else {
        print('No computer move available');
        isUserTurn = true;
      }
    } else {
      print('Conditions not met for computer move');
    }
  }

  String? _getComputerMove(chess.Chess game) {
    final legalMoves = game.moves();
    print('Legal moves: $legalMoves');
    if (legalMoves.isEmpty) {
      print('No legal moves available');
      return null;
    }
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
    final move = legalMoves[random.nextInt(legalMoves.length)].toString();
    print('Easy move selected: $move');
    return move;
  }

  String _getMediumMove(chess.Chess game, List<dynamic> legalMoves) {
    for (var move in legalMoves) {
      final tempGame = chess.Chess.fromFEN(game.fen);
      tempGame.move(move);
      final moveStr = move.toString();
      if (moveStr.contains('x')) {
        print('Medium move (capture) selected: $moveStr');
        return moveStr;
      }
    }
    print('No capture move found, falling back to easy move');
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
    print('Hard move selected: $bestMove');
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
                              print('Play vs Computer toggled to: $playAgainstComputer');
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
                                print('Difficulty changed to: $difficulty');
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
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (playMode.isNotEmpty)
                      Column(
                        children: [
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
                                    print('User made a move');
                                    setState(() {
                                      _checkGameState();
                                      print('Game over: ${controller.game.game_over}, Play vs Computer: $playAgainstComputer');
                                      print('Current turn: ${controller.game.turn == chess.Color.WHITE ? 'White' : 'Black'}');
                                      if (playAgainstComputer && !controller.game.game_over && controller.game.turn == chess.Color.BLACK) {
                                        isUserTurn = false;
                                        print('Scheduling computer move');
                                        Future.delayed(const Duration(milliseconds: 500), () {
                                          print('Executing scheduled computer move');
                                          _makeComputerMove();
                                        });
                                      } else {
                                        isUserTurn = true;
                                        print('No computer move scheduled, isUserTurn: $isUserTurn');
                                      }
                                    });
                                    if (showLegalMoves) {
                                      final game = controller.game;
                                      final moves = game.moves().map((move) => move.toString()).toList();
                                      if (moves.isNotEmpty) {
                                        final lastMove = moves.last;
                                        if (lastMove.length >= 2) {
                                          selectedSquare = lastMove.substring(0, 2);
                                          _updateLegalMoves();
                                        }
                                      }
                                    }
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
                                          : moveHistory[index];
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
    controller.removeListener(_updateLegalMoves);
    controller.dispose();
    super.dispose();
  }
}