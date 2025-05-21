import 'package:flutter/material.dart';
import 'package:chessearn_new/theme.dart';

class WatchScreen extends StatelessWidget {
  final String? userId;

  const WatchScreen({super.key, required this.userId});

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
          'Watch Screen - Coming Soon!',
          style: TextStyle(
            color: ChessEarnTheme.themeColors['text-light'],
            fontSize: 24,
          ),
        ),
      ),
    );
  }
}