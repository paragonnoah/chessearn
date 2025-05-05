import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_chess_board/flutter_chess_board.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'home_screen.dart';

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  final ChessBoardController controller = ChessBoardController();
  String _message = '';
  bool _isLoggedIn = false;
  bool _isOnline = false;
  WebSocketChannel? _channel;
  String? _gameId;
  String? _opponentId;

  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
    _fetchGames();
  }

  Future<void> _checkLoginStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('access_token');
    setState(() {
      _isLoggedIn = token != null;
    });
    if (_isLoggedIn) {
      _connectWebSocket(token!);
    }
  }

  Future<void> _fetchGames() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('access_token');
    if (token == null) {
      setState(() {
        _message = 'Please log in to access online features.';
      });
      return;
    }

    final response = await http.get(
      Uri.parse('http://localhost:5000/api/games'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      setState(() {
        _message = jsonDecode(response.body)['message'];
      });
    } else {
      setState(() {
        _message = 'Failed to fetch games. Please try again.';
      });
    }
  }

  void _connectWebSocket(String token) {
    _channel = WebSocketChannel.connect(
      Uri.parse('ws://localhost:5000'),
    );

    _channel!.stream.listen((message) {
      final data = jsonDecode(message);
      if (data['event'] == 'waiting') {
        setState(() {
          _message = data['data']['message'];
        });
      } else if (data['event'] == 'game_start') {
        setState(() {
          _gameId = data['data']['game_id'];
          _opponentId = data['data']['opponent_id'];
          _isOnline = true;
          _message = 'Game started! Playing against user $_opponentId';
        });
      } else if (data['event'] == 'move_made') {
        final move = data['data']['move'];
        setState(() {
          controller.game.make_move(move);
          _message = 'Opponent played $move';
        });
      } else if (data['event'] == 'opponent_left') {
        setState(() {
          _isOnline = false;
          _message = data['data']['message'];
          _channel?.sink.close();
          _channel = null;
        });
      }
    }, onError: (error) {
      setState(() {
        _message = 'WebSocket error: $error';
      });
    }, onDone: () {
      setState(() {
        _isOnline = false;
        _message = 'WebSocket connection closed';
      });
    });
  }

  void _startOnlineGame() async {
    if (!_isLoggedIn) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please log in to play online')),
      );
      return;
    }
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('access_token');
    final userId = jsonDecode(String.fromCharCodes(base64Decode(token!.split('.')[1] + '==')))['sub'].toString();
    _channel?.sink.add(jsonEncode({
      'event': 'join_game',
      'data': {'user_id': userId},
    }));
  }

  Future<void> _makeMove(String move) async {
    if (_isOnline && _gameId != null) {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('access_token');
      final userId = jsonDecode(String.fromCharCodes(base64Decode(token!.split('.')[1] + '==')))['sub'].toString();
      _channel?.sink.add(jsonEncode({
        'event': 'make_move',
        'data': {'game_id': _gameId, 'user_id': userId, 'move': move},
      }));
    }
  }

  Future<void> _leaveGame() async {
    if (_isOnline && _gameId != null) {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('access_token');
      final userId = jsonDecode(String.fromCharCodes(base64Decode(token!.split('.')[1] + '==')))['sub'].toString();
      _channel?.sink.add(jsonEncode({
        'event': 'leave_game',
        'data': {'game_id': _gameId, 'user_id': userId},
      }));
      _channel?.sink.close();
      setState(() {
        _isOnline = false;
        _gameId = null;
        _opponentId = null;
        _message = 'You left the game';
      });
    }
  }

  void _logout() async {
    _leaveGame();
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('access_token');
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const HomeScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ChessEarn'),
        centerTitle: true,
        backgroundColor: Colors.blueAccent,
        actions: [
          if (_isOnline)
            IconButton(
              icon: const Icon(Icons.exit_to_app),
              onPressed: _leaveGame,
              tooltip: 'Leave Game',
            ),
          if (_isLoggedIn)
            IconButton(
              icon: const Icon(Icons.logout),
              onPressed: _logout,
              tooltip: 'Log Out',
            ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blueAccent, Colors.white],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                width: MediaQuery.of(context).size.width * 0.9,
                height: MediaQuery.of(context).size.width * 0.9,
                child: ChessBoard(
                  controller: controller,
                  boardColor: BoardColor.brown,
                  onMove: () {
                    final move = controller.game.history.last.move;
                    final moveNotation = move.toString();
                    if (_isOnline) {
                      _makeMove(moveNotation);
                    }
                    setState(() {
                      if (controller.game.game_over) {
                        String message = 'Game Over!';
                        if (controller.game.in_checkmate) {
                          message = 'Checkmate!';
                        } else if (controller.game.in_stalemate) {
                          message = 'Stalemate!';
                        } else if (controller.game.in_draw) {
                          message = 'Draw!';
                        }
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(message)),
                        );
                      }
                    });
                  },
                ),
              ),
              const SizedBox(height: 16),
              Text(
                controller.game.in_check
                    ? 'Check!'
                    : '${controller.game.turn} to move',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                _message,
                style: const TextStyle(fontSize: 16, color: Colors.white70),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.blueAccent,
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                      textStyle: const TextStyle(fontSize: 18),
                    ),
                    onPressed: () {
                      setState(() {
                        controller.game.reset();
                        _isOnline = false;
                        _message = '';
                      });
                    },
                    child: const Text('New Local Game'),
                  ),
                  const SizedBox(width: 10),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.blueAccent,
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                      textStyle: const TextStyle(fontSize: 18),
                    ),
                    onPressed: _isOnline ? null : _startOnlineGame,
                    child: const Text('Play Online'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _channel?.sink.close();
    controller.dispose();
    super.dispose();
  }
}