import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'screens/game_screen.dart';
import 'screens/login_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  final String? accessToken = prefs.getString('access_token');
  runApp(ChessEarnApp(initialRoute: accessToken != null ? GameScreen() : LoginScreen()));
}

class ChessEarnApp extends StatelessWidget {
  final Widget initialRoute;

  const ChessEarnApp({super.key, required this.initialRoute});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ChessEarn',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: initialRoute,
    );
  }
}