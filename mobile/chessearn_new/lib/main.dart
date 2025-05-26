import 'package:chessearn_new/theme.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'screens/home_screen.dart';
import 'screens/game_screen.dart';
import 'services/api_service.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:async';

Future<void> requestPermissions() async {
  Map<Permission, PermissionStatus> statuses = await [
    Permission.camera,
    Permission.photos,
  ].request();
  if (!statuses[Permission.camera]!.isGranted ||
      !statuses[Permission.photos]!.isGranted) {
    print("Permissions denied - some features may not work");
  }
}

Future<Widget> _initializeApp({required String? userId}) async {
  // Initialize SharedPreferences (minimal impact, keep on main thread)
  final prefs = await SharedPreferences.getInstance();
  final String? accessToken = prefs.getString('access_token');

  // Defer Stripe initialization to background
  Future.microtask(() async {
    Stripe.publishableKey = 'pk_test_your_actual_stripe_key_here'; // Replace with your key
    await Stripe.instance.applySettings();
  });

  // Defer API initialization to background
  Future.microtask(() async {
    await ApiService.initializeCookieJar();
  });

  // Return initial route immediately
  return accessToken != null
      ? GameScreen(
          userId: userId ?? prefs.getString('userId') ?? '',
          initialPlayMode: 'computer',
        )
      : const HomeScreen();
}

void main() {
  runZonedGuarded(() async {
    WidgetsFlutterBinding.ensureInitialized();

    // Request permissions (needs to be on main thread for UI prompts)
    await requestPermissions();

    // Initialize app and get initial route
    final initialRoute = await _initializeApp(userId: null);

    // Run the app
    runApp(ChessEarnApp(initialRoute: initialRoute));
  }, (error, stackTrace) {
    print('Uncaught error: $error');
    print('Stack trace: $stackTrace');
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