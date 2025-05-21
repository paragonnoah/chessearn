import 'package:chessearn/theme.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'screens/home_screen.dart';
import 'screens/game_screen.dart';
import 'services/api_service.dart';
import 'package:flutter_stripe/flutter_stripe.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Stripe
  Stripe.publishableKey = 'pk_test_your_publishable_key_here'; // Replace with your Stripe test publishable key
  await Stripe.instance.applySettings();

  // Initialize ApiService and SharedPreferences
  await ApiService.initializeCookieJar();
  final prefs = await SharedPreferences.getInstance();
  final String? accessToken = prefs.getString('access_token');
  
  // If accessToken exists, route to GameScreen; otherwise, route to HomeScreen
  runApp(ChessEarnApp(
    initialRoute: accessToken != null
        ? GameScreen(
            userId: prefs.getString('userId') ?? '',
            initialPlayMode: '',
          )
        : const HomeScreen(),
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