import 'package:chessearn_new/theme.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'screens/home_screen.dart';
import 'screens/game_screen.dart';
import 'services/api_service.dart';
import 'package:flutter_stripe/flutter_stripe.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Stripe (required early)
  Stripe.publishableKey = 'pk_test_your_publishable_key_here'; // Replace with your actual Stripe test key
  await Stripe.instance.applySettings();

  // Initialize SharedPreferences early
  final prefs = await SharedPreferences.getInstance();
  final String? accessToken = prefs.getString('access_token');

  // Start the app immediately
  runApp(ChessEarnApp(
    initialRoute: accessToken != null
        ? GameScreen(
            userId: prefs.getString('userId') ?? '',
            initialPlayMode: '',
          )
        : const HomeScreen(),
  ));

  // Defer heavy initialization
  WidgetsBinding.instance.addPostFrameCallback((_) async {
    await ApiService.initializeCookieJar();
  });
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