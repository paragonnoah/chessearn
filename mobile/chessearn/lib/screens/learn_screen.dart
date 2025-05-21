import 'package:flutter/material.dart';
import 'package:chessearn/theme.dart';

class LearnScreen extends StatelessWidget {
  final String? userId;

  const LearnScreen({super.key, required this.userId});

  @override
  Widget build(BuildContext context) {
    return Container(
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
        child: Text(
          'Learn Screen - Coming Soon!',
          style: TextStyle(
            color: ChessEarnTheme.themeColors['text-light'],
            fontSize: 24,
          ),
        ),
      ),
    );
  }
}