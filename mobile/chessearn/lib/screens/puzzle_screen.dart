import 'package:flutter/material.dart';
import 'package:chessearn/theme.dart';

class PuzzleScreen extends StatelessWidget {
  final String? userId;

  const PuzzleScreen({super.key, required this.userId});

  @override
  Widget build(BuildContext context) {
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
        child: Center(
          child: Text('Puzzle Screen - Coming Soon!', style: TextStyle(color: ChessEarnTheme.themeColors['text-light'], fontSize: 24)),
        ),
      ),
    );
  }
}