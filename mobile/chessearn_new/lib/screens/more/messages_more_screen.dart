import 'package:flutter/material.dart';
import 'package:chessearn_new/theme.dart';

class MessagesMoreScreen extends StatefulWidget {
  const MessagesMoreScreen({super.key});

  @override
  State<MessagesMoreScreen> createState() => _MessagesMoreScreenState();
}

class _MessagesMoreScreenState extends State<MessagesMoreScreen> with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeOut),
    );
    _fadeController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
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
        child: SafeArea(
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: CustomScrollView(
              slivers: [
                SliverAppBar(
                  backgroundColor: Colors.transparent,
                  elevation: 0,
                  leading: IconButton(
                    icon: Icon(Icons.arrow_back, color: ChessEarnTheme.themeColors['text-light']),
                    onPressed: () => Navigator.pop(context),
                  ),
                  title: Text(
                    'Messages',
                    style: TextStyle(color: ChessEarnTheme.themeColors['text-light']),
                  ),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      children: [
                        // Placeholder for Messages
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: Colors.white.withOpacity(0.2)),
                          ),
                          child: Column(
                            children: [
                              Icon(
                                Icons.message,
                                size: 50,
                                color: ChessEarnTheme.themeColors['brand-accent'],
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'No Messages Yet',
                                style: TextStyle(
                                  color: ChessEarnTheme.themeColors['text-light'],
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Start a conversation with your friends!',
                                style: TextStyle(
                                  color: ChessEarnTheme.themeColors['text-muted'],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}