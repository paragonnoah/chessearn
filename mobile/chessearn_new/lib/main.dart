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
    Permission.storage,
  ].request();
  if (!statuses[Permission.camera]!.isGranted || !statuses[Permission.storage]!.isGranted) {
    print("Permissions denied - some features may not work");
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Stripe
  Stripe.publishableKey = 'pk_test_51YourActualStripeKeyHere'; // Replace with your key
  await Stripe.instance.applySettings();

  // Request permissions
  await requestPermissions();

  // Initialize SharedPreferences
  final prefs = await SharedPreferences.getInstance();
  final String? accessToken = prefs.getString('access_token');

  // Start the app with error handling
  runZonedGuarded(() {
    runApp(ChessEarnApp(
      initialRoute: accessToken != null
          ? GameScreen(
              userId: prefs.getString('userId') ?? '',
              initialPlayMode: 'computer',
            )
          : const HomeScreen(),
    ));
  }, (error, stackTrace) {
    print('Uncaught error: $error');
    print('Stack trace: $stackTrace');
  });

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