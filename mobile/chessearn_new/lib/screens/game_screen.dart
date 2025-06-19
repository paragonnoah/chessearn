import 'package:flutter/material.dart';
import 'package:flutter_chess_board/flutter_chess_board.dart';
import 'package:chessearn_new/screens/game_board.dart';
import 'package:chessearn_new/screens/home_screen.dart';
import 'package:chessearn_new/screens/profile_screen.dart';
import 'package:chessearn_new/screens/chess_chat_screen.dart';
import 'package:chessearn_new/services/api_service.dart';
import 'package:chessearn_new/theme.dart';
import 'dart:async';
import 'dart:math';

class GameScreen extends StatefulWidget {
  final String? userId;
  final String initialPlayMode;
  final String? timeControl;
  final String? opponentId;

  const GameScreen({
    super.key,
    required this.userId,
    required this.initialPlayMode,
    this.timeControl,
    this.opponentId,
    required String gameId,
  });

  @override
  _GameScreenState createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  String gameStatus = 'White to move';
  List<String> moveHistory = [];
  List<Map<String, String>> pairedMoves = [];
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
  String? lastFenBeforeMove;

  late int whiteTime;
  late int blackTime;
  int whiteIncrement = 0;
  int blackIncrement = 0;
  Timer? _timer;
  bool isGameOver = false;

  @override
  void initState() {
    super.initState();
    playMode = widget.initialPlayMode;
    playAgainstComputer = playMode == 'computer';
    _initializeTimers();
    _checkGameState();
    lastFenBeforeMove = null;
    _startTimer();
    if (playMode == 'online' && widget.opponentId != null) {
      _startOnlineGameWithOpponent();
    }
  }

  Future<void> _startOnlineGameWithOpponent() async {
    try {
      await ApiService.postGameMove('start_game:${widget.opponentId}');
    } catch (e) {
      if (mounted) {
        setState(() {
          gameStatus = 'Failed to start game: $e';
        });
      }
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
        if (isUserTurn && !playAgainstComputer) {
          whiteTime = (whiteTime - 1).clamp(0, whiteTime);
          if (whiteTime <= 0) {
            gameStatus = 'Time out! Black wins!';
            isGameOver = true;
            timer.cancel();
          }
        } else if (!isUserTurn) {
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
    if (!mounted) return;
    setState(() {
      gameStatus = 'White to move';
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
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to sync move: $e')),
          );
        }
      });
    }

    if (!isGameOver) {
      if (isUserTurn) {
        whiteTime += whiteIncrement;
      } else {
        blackTime += blackIncrement;
      }
    }
  }

  Future<void> _logout() async {
    await ApiService.logout();
    if (mounted) {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const HomeScreen()));
    }
  }

  void _resetGame() {
    if (!mounted) return;
    setState(() {
      gameStatus = 'White to move';
      moveHistory.clear();
      pairedMoves.clear();
      selectedSquare = null;
      legalDestinations.clear();
      isUserTurn = true;
      isGameOver = false;
      drawOffered = false;
      drawAccepted = false;
      lastFenBeforeMove = null;
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
    if (!mounted || moveHistory.isEmpty) return;
    setState(() {
      moveHistory.removeLast();
      if (moveHistory.isNotEmpty) moveHistory.removeLast();
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
    });
  }

  void _updateLegalMoves() {
    if (!mounted) return;
    if (showLegalMoves && selectedSquare != null && isUserTurn) {
      legalDestinations.clear();
      setState(() {});
    } else {
      legalDestinations.clear();
      setState(() {});
    }
  }

  void _makeComputerMove() {
    if (!mounted || !isUserTurn || !playAgainstComputer) return;
    // Placeholder; rely on GameBoard's computer move logic
    const move = 'e7e5';
    final from = move.substring(0, 2);
    final to = move.substring(2, 4);
    setState(() {
      moveHistory.insert(0, '$from$to');
      _checkGameState();
      isUserTurn = true;
    });
  }

  void _selectPlayMode(String mode) {
    if (!mounted) return;
    setState(() {
      playMode = mode;
      playAgainstComputer = mode == 'computer';
      if (mode == 'computer' && !isUserTurn) _makeComputerMove();
    });
  }

  void _offerDraw() {
    if (!mounted || isGameOver) return;
    setState(() {
      drawOffered = true;
    });

    if (playAgainstComputer) {
      final random = Random();
      final acceptDraw = random.nextBool();
      Future.delayed(const Duration(seconds: 1), () {
        if (mounted) {
          setState(() {
            if (acceptDraw) {
              drawAccepted = true;
              gameStatus = 'Draw accepted!';
              isGameOver = true;
            } else {
              drawOffered = false;
            }
          });
        }
      });
    }
  }

  void _resignGame() {
    if (!mounted || isGameOver) return;
    setState(() {
      gameStatus = 'You resigned! Opponent wins!';
      isGameOver = true;
    });
  }

  void _showSettingsDialog() {
    if (!mounted) return;
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

  Future<void> _syncMoveWithOpponent(String move) async {
    if (!mounted) return;
    try {
      await ApiService.postGameMove('$move:${widget.opponentId}');
      isUserTurn = false;
    } catch (e) {
      setState(() {
        gameStatus = 'Failed to sync move: $e';
      });
      isUserTurn = true;
    }
  }

  String _getCurrentFen() {
    return 'rnbqkbnr/pppp1ppp/5n2/5p2/5P2/5N2/PPPP1PPP/RNBQKB1R w KQkq - 1 2';
  }

  // --- CHAT NAVIGATION ---
  void _openChatBox() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ChessChatScreen(
          currentUserName: widget.userId ?? "You",
          opponentName: widget.opponentId ?? "Opponent",
        ),
      ),
    );
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
                      IconButton(
                        icon: const Icon(Icons.forum, color: Colors.white),
                        tooltip: "Open Chat",
                        onPressed: _openChatBox,
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.pushReplacement(
                              context, MaterialPageRoute(builder: (context) => const HomeScreen()));
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
                                  color: isUserTurn ? ChessEarnTheme.themeColors['brand-accent'] : ChessEarnTheme.themeColors['text-light'],
                                  fontSize: 16,
                                ),
                              ),
                              const SizedBox(width: 20),
                              Text(
                                'Black: ${_formatTime(blackTime)}',
                                style: TextStyle(
                                  color: !isUserTurn ? ChessEarnTheme.themeColors['brand-accent'] : ChessEarnTheme.themeColors['text-light'],
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
                                  color: Colors.black.withAlpha(50),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: GameBoard(
                              initialFen: null,
                              enableUserMoves: isUserTurn || !playAgainstComputer || playMode == 'online',
                              showLegalMoves: showLegalMoves,
                              playAgainstComputer: playAgainstComputer,
                              computerDifficulty: difficulty,
                              isUserTurn: isUserTurn,
                              boardSize: boardSize,
                              boardColor: BoardColor.brown,
                              onMove: (from, to, sanMove) {
                                if (!mounted) return;
                                setState(() {
                                  moveHistory.insert(0, sanMove);
                                  _checkGameState();
                                  if (playAgainstComputer && !isGameOver && !isUserTurn) {
                                    isUserTurn = false;
                                    Future.delayed(const Duration(milliseconds: 500), _makeComputerMove);
                                  } else if (playMode == 'online' && widget.opponentId != null && !isGameOver) {
                                    isUserTurn = false;
                                    _syncMoveWithOpponent(sanMove);
                                  } else {
                                    isUserTurn = true;
                                  }
                                  lastFenBeforeMove = _getCurrentFen();
                                });
                              },
                              onSelectSquare: (square) {
                                if (!mounted) return;
                                setState(() {
                                  selectedSquare = square;
                                  _updateLegalMoves();
                                });
                              },
                              onGameStateChange: () {
                                if (!mounted) return;
                                setState(() {
                                  _checkGameState();
                                  if (gameStatus.contains('Checkmate! You win!')) earnedPoints += 50;
                                  isGameOver = gameStatus.contains('Checkmate') || gameStatus.contains('Stalemate') || gameStatus.contains('Time out') || gameStatus.contains('Draw');
                                });
                              },
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
                                  height: 120,
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
                          // Chat Button
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Row(
                              children: [
                                ElevatedButton.icon(
                                  onPressed: _openChatBox,
                                  icon: const Icon(Icons.forum),
                                  label: const Text("Open Chat"),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: ChessEarnTheme.themeColors['brand-accent'],
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
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
    super.dispose();
  }
}