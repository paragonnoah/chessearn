import 'package:flutter/material.dart';
import 'package:chessearn_new/theme.dart';
import 'game_board.dart';
import 'package:chess/chess.dart' as chess;
import 'dart:async';
import 'dart:math';

class PuzzleScreen extends StatefulWidget {
  final String? userId;

  const PuzzleScreen({super.key, required this.userId});

  @override
  _PuzzleScreenState createState() => _PuzzleScreenState();
}

class _PuzzleScreenState extends State<PuzzleScreen> with TickerProviderStateMixin {
  late AnimationController _animationController;
  late AnimationController _progressController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _progressAnimation;

  int userXP = 0;
  int puzzlesSolved = 0;
  int currentAttempts = 3;
  bool isPuzzleActive = false;
  bool isPuzzleSolved = false;
  bool showHint = false;

  String? currentPuzzleFen =
      'rnbqkbnr/pppp1ppp/5n2/5p2/5P2/5N2/PPPP1PPP/RNBQKB1R w KQkq - 1 2'; // Example FEN
  String? solutionMove = 'Nf3'; // Example solution
  String? hintText = 'Consider moving a knight to attack the center.';

  Timer? _dailyUpdateTimer;
  final Random _random = Random();

  late chess.Chess _chess;

  @override
  void initState() {
    super.initState();
    _chess = chess.Chess.fromFEN(currentPuzzleFen ?? chess.Chess.DEFAULT_POSITION);
    _initializeAnimations();
    _startDailyUpdates();
  }

  void _initializeAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _progressController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _progressAnimation = Tween<double>(begin: 0.0, end: puzzlesSolved / 10).animate(
      CurvedAnimation(parent: _progressController, curve: Curves.easeOutCubic),
    );

    _animationController.repeat(reverse: true);
    _progressController.forward();
  }

  void _startDailyUpdates() {
    _dailyUpdateTimer = Timer.periodic(const Duration(seconds: 30), (timer) {
      if (mounted) {
        setState(() {
          if (_random.nextDouble() < 0.3) {
            userXP += _random.nextInt(10) + 5;
          }
        });
      }
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    _progressController.dispose();
    _dailyUpdateTimer?.cancel();
    super.dispose();
  }

  void _startPuzzle() {
    setState(() {
      isPuzzleActive = true;
      currentAttempts = 3;
      isPuzzleSolved = false;
      showHint = false;
      _chess = chess.Chess.fromFEN(currentPuzzleFen ?? chess.Chess.DEFAULT_POSITION);
    });
  }

  void _onUserMove(String from, String to, String san) {
    if (!isPuzzleActive || isPuzzleSolved) return;

    _chess.move({'from': from, 'to': to});
    if (san == solutionMove) {
      setState(() {
        isPuzzleSolved = true;
        puzzlesSolved++;
        userXP += 25;
        currentAttempts = 3;
      });
      _showSnackbar('Puzzle Solved! +25 XP');
    } else if (currentAttempts > 1) {
      setState(() {
        currentAttempts--;
      });
      _showSnackbar('Incorrect move. $currentAttempts attempts left.');
      Future.delayed(const Duration(milliseconds: 600), () => _makeAIMove());
    } else {
      setState(() {
        isPuzzleActive = false;
      });
      _showSnackbar('Puzzle failed. Solution: $solutionMove');
    }
    setState(() {});
  }

  void _makeAIMove() {
    if (_chess.game_over) return;
    final moves = List<Map<String, dynamic>>.from(_chess.generate_moves({'verbose': true}));
    if (moves.isNotEmpty) {
      final move = moves[_random.nextInt(moves.length)];
      _chess.move({'from': move['from'], 'to': move['to']});
      setState(() {});
      _showSnackbar("AI played: ${move['san']}");
    }
  }

  void _toggleHint() {
    setState(() {
      showHint = !showHint;
    });
  }

  void _showSnackbar(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
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
        child: SafeArea(
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: SingleChildScrollView(
              child: Column(
                children: [
                  _buildHeader(),
                  _buildProgressSection(),
                  _buildPuzzleArea(),
                  if (isPuzzleActive) _buildPuzzleControls(),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Row(
        children: [
          Hero(
            tag: 'puzzle_icon',
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Icon(
                Icons.extension,
                color: ChessEarnTheme.themeColors['text-light'],
                size: 24,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Puzzle Odyssey',
                  style: TextStyle(
                    color: ChessEarnTheme.themeColors['text-light'],
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Sharpen your skills • ${_getTimeOfDayGreeting()}',
                  style: TextStyle(
                    color: ChessEarnTheme.themeColors['text-light']!.withOpacity(0.8),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          _buildLevelBadge(),
        ],
      ),
    );
  }

  Widget _buildLevelBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Colors.amber, Colors.orange],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.amber.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.star, color: Colors.white, size: 16),
          SizedBox(width: 4),
          Text(
            'Level 1',
            style: TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressSection() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.2)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Puzzle Progress',
                style: TextStyle(
                  color: ChessEarnTheme.themeColors['text-light'],
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                '${(puzzlesSolved / 10 * 100).toInt()}%',
                style: const TextStyle(
                  color: Colors.green,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          AnimatedBuilder(
            animation: _progressAnimation,
            builder: (context, child) {
              return LinearProgressIndicator(
                value: _progressAnimation.value,
                backgroundColor: Colors.white.withOpacity(0.2),
                valueColor: AlwaysStoppedAnimation<Color>(
                  Color.lerp(Colors.red, Colors.green, _progressAnimation.value)!,
                ),
                borderRadius: BorderRadius.circular(4),
                minHeight: 6,
              );
            },
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _buildStatCard("Puzzles", "$puzzlesSolved/10", Icons.extension, Colors.blue),
              const SizedBox(width: 12),
              _buildStatCard("Attempts", "$currentAttempts", Icons.replay, Colors.orange),
              const SizedBox(width: 12),
              _buildStatCard("XP", _formatNumber(userXP), Icons.stars, Colors.purple),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.2)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(height: 4),
            Text(
              value,
              style: TextStyle(
                color: color,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              title,
              style: TextStyle(
                color: Colors.white.withOpacity(0.7),
                fontSize: 11,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPuzzleArea() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.2)),
      ),
      child: Column(
        children: [
          Text(
            'Daily Puzzle',
            style: TextStyle(
              color: ChessEarnTheme.themeColors['text-light'],
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          if (!isPuzzleActive)
            ElevatedButton(
              onPressed: _startPuzzle,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              ),
              child: const Text('Start Puzzle'),
            )
          else
            Column(
              children: [
                SizedBox(
                  height: 320,
                  child: GameBoard(
                    initialFen: _chess.fen,
                    enableUserMoves: isPuzzleActive && !isPuzzleSolved,
                    showLegalMoves: true,
                    onMove: (from, to, san) => _onUserMove(from, to, san),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  isPuzzleSolved ? 'Solution: $solutionMove' : 'Make your move!',
                  style: TextStyle(
                    color: ChessEarnTheme.themeColors['text-light'],
                    fontSize: 16,
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildPuzzleControls() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton(
                onPressed: _toggleHint,
                style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
                child: Text(showHint ? 'Hide Hint' : 'Show Hint'),
              ),
              if (showHint)
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(left: 8.0),
                    child: Text(
                      hintText!,
                      style: TextStyle(color: ChessEarnTheme.themeColors['text-light']),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 10),
          TextField(
            decoration: InputDecoration(
              labelText: 'Enter Move (e.g., Nf3)',
              labelStyle: TextStyle(color: ChessEarnTheme.themeColors['text-light']),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            ),
            onSubmitted: (moveSan) {
              final legalMoves = List<Map<String, dynamic>>.from(_chess.generate_moves({'verbose': true}));
              Map<String, dynamic>? found;
              for (final m in legalMoves) {
                if (m['san'] == moveSan) {
                  found = m;
                  break;
                }
              }
              if (found != null) {
                _onUserMove(found['from'], found['to'], found['san']);
              } else {
                _showSnackbar('Invalid move or format.');
              }
            },
          ),
        ],
      ),
    );
  }

  String _getTimeOfDayGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning';
    if (hour < 17) return 'Good afternoon';
    return 'Good evening';
  }

  String _formatNumber(int number) {
    if (number >= 1000) {
      return '${(number / 1000).toStringAsFixed(1)}k';
    }
    return number.toString();
  }
}

class LearningCategory {
  final String title;
  final IconData icon;
  final Color color;
  final List<Lesson> lessons;

  LearningCategory({
    required this.title,
    required this.icon,
    required this.color,
    required this.lessons,
  });
}

class Lesson {
  final String title;
  final String description;
  final IconData icon;
  final int difficulty;
  bool completed;
  final String content;

  Lesson(this.title, this.description, this.icon, this.difficulty, this.completed, this.content);
}