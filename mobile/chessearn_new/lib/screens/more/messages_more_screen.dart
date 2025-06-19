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

  void _onStartMessage() {
    // TODO: Replace this with your navigation to friend search or new chat screen
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Start a new message (choose a friend)!')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'new_message_fab',
        onPressed: _onStartMessage,
        backgroundColor: ChessEarnTheme.themeColors['brand-accent'],
        icon: const Icon(Icons.person_add_alt_1_rounded, color: Colors.white),
        label: const Text(
          "Message a Friend",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
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
                  actions: [
                    IconButton(
                      tooltip: "New Message",
                      icon: Icon(Icons.edit_location_alt_rounded, color: ChessEarnTheme.themeColors['brand-accent']),
                      onPressed: _onStartMessage,
                    ),
                  ],
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
                                Icons.message_rounded,
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
                              const SizedBox(height: 16),
                              // Place Icon Button
                              ElevatedButton.icon(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: ChessEarnTheme.themeColors['brand-accent'],
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                                  elevation: 2,
                                ),
                                onPressed: _onStartMessage,
                                icon: const Icon(Icons.place_rounded),
                                label: const Text(
                                  "Find & Message Friends",
                                  style: TextStyle(fontWeight: FontWeight.w600),
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