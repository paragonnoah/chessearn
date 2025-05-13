import 'package:chessearn/theme.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'screens/home_screen.dart';
import 'screens/game_screen.dart';
import 'services/api_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await ApiService.initializeCookieJar(); // Replace ApiService.init() with this
  final prefs = await SharedPreferences.getInstance();
  final String? accessToken = prefs.getString('access_token'); // Temporary fallback
  // If accessToken exists, pass a userId; otherwise, route to HomeScreen
  // Note: userId: '' might need to be replaced with a proper userId from the token or prefs
  runApp(ChessEarnApp(
    initialRoute: accessToken != null ? GameScreen(userId: prefs.getString('userId') ?? '') : const HomeScreen(),
  ));
}

class ChessEarnApp extends StatelessWidget {
  final Widget initialRoute;

  const ChessEarnApp({super.key, required this.initialRoute});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ChessEarn',
      theme: ChessEarnTheme.themeData,
      home: initialRoute,
    );
  }
}