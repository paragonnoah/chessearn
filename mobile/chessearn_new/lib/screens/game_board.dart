import 'package:flutter/material.dart';
import 'package:flutter_chess_board/flutter_chess_board.dart';
import 'package:chess/chess.dart' as chess;
import 'package:stockfish/stockfish.dart';
import 'dart:async';
import 'dart:math';

class GameBoard extends StatefulWidget {
  final bool enableUserMoves;
  final bool showLegalMoves;
  final String? initialFen;
  final Function(String, String, String)? onMove;
  final Function(String)? onSelectSquare;
  final bool playAgainstComputer;
  final String computerDifficulty;
  final bool isUserTurn;
  final double? boardSize;
  final BoardColor boardColor;
  final VoidCallback? onGameStateChange;

  const GameBoard({
    super.key,
    this.enableUserMoves = true,
    this.showLegalMoves = true,
    this.initialFen,
    this.onMove,
    this.onSelectSquare,
    this.playAgainstComputer = false,
    this.computerDifficulty = 'Easy',
    this.isUserTurn = true,
    this.boardSize,
    this.boardColor = BoardColor.brown,
    this.onGameStateChange,
  });

  @override
  GameBoardState createState() => GameBoardState();
}

class GameBoardState extends State<GameBoard> {
  late ChessBoardController _controller;
  String? _selectedSquare;
  List<String> _legalDestinations = [];
  Stockfish? _stockfish;
  bool _isUserTurn = true;
  final Random _random = Random();

  @override
  void initState() {
    super.initState();
    _controller = ChessBoardController();
    _isUserTurn = widget.isUserTurn;
    if (widget.initialFen != null) {
      try {
        _controller.loadFen(widget.initialFen!);
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Invalid FEN: $e')),
          );
        }
      }
    }
    if (widget.playAgainstComputer) {
      _initializeStockfish();
      if (!_isUserTurn) {
        Future.delayed(const Duration(milliseconds: 500), _makeComputerMove);
      }
    }
    _controller.addListener(_notifyGameStateChange);
  }

  void _initializeStockfish() {
    _stockfish = Stockfish();
    _stockfish!.stdin = 'uci';
    Future.delayed(const Duration(milliseconds: 500), () {
      if (_stockfish != null && mounted) {
        final skillLevel = widget.computerDifficulty == 'Easy'
            ? 0
            : widget.computerDifficulty == 'Medium'
                ? 10
                : 20;
        _stockfish!.stdin = 'setoption name Skill Level value $skillLevel';
        _stockfish!.stdin = 'isready';
      }
    });
  }

  void _updateLegalMoves(String? square) {
    if (widget.showLegalMoves && square != null && _isUserTurn && widget.enableUserMoves) {
      final game = chess.Chess.fromFEN(_controller.game.fen);
      final moves = game.moves({'square': square, 'verbose': true});
      _legalDestinations = moves.map((move) => move['to'] as String).toList();
      setState(() {});
    } else {
      _legalDestinations.clear();
      setState(() {});
    }
  }

  void _makeComputerMove() async {
    if (!_isUserTurn || !widget.playAgainstComputer || !mounted) return;
    try {
      final fen = _controller.game.fen;
      String? bestMove;
      if (_stockfish != null) {
        _stockfish!.stdin = 'position fen $fen';
        _stockfish!.stdin = 'go movetime 1000';
        final completer = Completer<void>();
        final subscription = _stockfish!.stdout.listen((line) {
          if (line.startsWith('bestmove')) {
            bestMove = line.split(' ')[1];
            completer.complete();
          }
        });
        await completer.future.timeout(const Duration(seconds: 2), onTimeout: () {
          subscription.cancel();
          throw Exception('Stockfish timed out');
        });
        subscription.cancel();
      }
      if (bestMove == null || bestMove!.length < 4) {
        final game = chess.Chess.fromFEN(fen);
        final moves = game.moves({'verbose': true});
        if (moves.isNotEmpty) {
          final move = moves[_random.nextInt(moves.length)];
          bestMove = (move['from'] as String) + (move['to'] as String);
        }
        if (bestMove == null) {
          throw Exception('No valid move found');
        }
      }
      final from = bestMove?.substring(0, 2);
      final to = bestMove!.substring(2, 4);
      _applyMove(from!, to);
    } catch (e) {
      if (mounted) {
        setState(() => _isUserTurn = true);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Computer move error: $e')),
        );
      }
    }
  }

  void _handleSquareTap(String square) {
    if (!widget.enableUserMoves || !_isUserTurn) return;
    final piece = _controller.game.get(square);
    if (_selectedSquare == null) {
      if (piece != null && piece.color == _controller.game.turn) {
        setState(() {
          _selectedSquare = square;
          widget.onSelectSquare?.call(square);
          _updateLegalMoves(square);
        });
      }
    } else {
      if (_legalDestinations.contains(square)) {
        final from = _selectedSquare!;
        final to = square;
        _applyMove(from, to);
      } else {
        setState(() {
          _selectedSquare = null;
          _legalDestinations.clear();
        });
        if (piece != null && piece.color == _controller.game.turn) {
          setState(() {
            _selectedSquare = square;
            widget.onSelectSquare?.call(square);
            _updateLegalMoves(square);
          });
        }
      }
    }
  }

  void _applyMove(String from, String to) {
    final tempGame = chess.Chess.fromFEN(_controller.game.fen);
    final success = tempGame.move({'from': from, 'to': to});

    if (success == true) {
      final history = tempGame.history;
      String sanMove = '$from$to';

      if (history.isNotEmpty && history.last is Map<String, dynamic>) {
        final lastMove = history.last as Map<String, dynamic>;
        if (lastMove.containsKey('san')) {
          sanMove = lastMove['san'] as String;
        }
      }

      _controller.makeMove(from: from, to: to);
      if (mounted) {
        setState(() {
          _selectedSquare = null;
          _legalDestinations.clear();
          if (widget.playAgainstComputer && !_controller.game.game_over && _controller.game.turn == chess.Color.BLACK) {
            _isUserTurn = false;
            Future.delayed(const Duration(milliseconds: 500), _makeComputerMove);
          } else {
            _isUserTurn = true;
          }
        });
        widget.onMove?.call(from, to, sanMove);
        widget.onGameStateChange?.call();
      }
    } else {
      setState(() {
        _selectedSquare = null;
        _legalDestinations.clear();
      });
    }
  }

  void _notifyGameStateChange() {
    if (_controller.game.history.isNotEmpty) {
      widget.onGameStateChange?.call();
    }
  }

  @override
  Widget build(BuildContext context) {
    final effectiveBoardSize = widget.boardSize ?? MediaQuery.of(context).size.width * 0.9;
    final squareSize = effectiveBoardSize / 8;
    return Material(
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 8.0),
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(50),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: AspectRatio(
          aspectRatio: 1,
          child: Stack(
            children: [
              ChessBoard(
                controller: _controller,
                boardColor: widget.boardColor,
                size: effectiveBoardSize,
                enableUserMoves: false,
                onMove: null,
              ),
              if (widget.showLegalMoves && _legalDestinations.isNotEmpty)
                ..._legalDestinations.map((square) {
                  if (square.length < 2) return const SizedBox.shrink();
                  final file = square[0].codeUnitAt(0) - 'a'.codeUnitAt(0);
                  final rank = int.parse(square[1]) - 1;
                  return Positioned(
                    left: file * squareSize + squareSize * 0.4,
                    top: (7 - rank) * squareSize + squareSize * 0.4,
                    child: Container(
                      width: squareSize * 0.2,
                      height: squareSize * 0.2,
                      decoration: const BoxDecoration(
                        color: Colors.blueAccent,
                        shape: BoxShape.circle,
                      ),
                    ),
                  );
                }),
              // Tap handler overlay
              Positioned.fill(
                child: GestureDetector(
                  behavior: HitTestBehavior.translucent,
                  onTapDown: (details) {
                    final renderBox = context.findRenderObject() as RenderBox?;
                    if (renderBox == null) return;
                    final position = renderBox.globalToLocal(details.globalPosition);
                    final file = (position.dx / squareSize).floor();
                    final rank = 7 - (position.dy / squareSize).floor();
                    if (file >= 0 && file < 8 && rank >= 0 && rank < 8) {
                      final square = String.fromCharCode('a'.codeUnitAt(0) + file) + (rank + 1).toString();
                      _handleSquareTap(square);
                    }
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    _stockfish?.dispose();
    _stockfish = null;
    super.dispose();
  }
}