import 'dart:convert'; 
import 'package:flutter/material.dart';
import 'package:flutter_chess_board/flutter_chess_board.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  final ChessBoardController controller = ChessBoardController();
  String _message = '';

  @override
  void initState() {
    super.initState();
    _fetchGames();
  }

  Future<void> _fetchGames() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('access_token');
    if (token == null) {
      setState(() {
        _message = 'Not authenticated';
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
        _message = 'Failed to fetch games';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ChessEarn'),
        centerTitle: true,
      ),
      body: Center(
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
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Text(_message, style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  controller.game.reset();
                });
              },
              child: const Text('New Game'),
            ),
          ],
        ),
      ),
    );
  }
}