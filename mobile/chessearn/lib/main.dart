import 'package:flutter/material.dart';
import 'screens/login_screen.dart';

void main() {
  runApp(const ChessEarnApp());
}

class ChessEarnApp extends StatelessWidget {
  const ChessEarnApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ChessEarn',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      home: const LoginScreen(),
    );
  }
}