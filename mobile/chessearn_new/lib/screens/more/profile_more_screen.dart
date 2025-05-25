import 'package:flutter/material.dart';
import 'package:chessearn_new/theme.dart';

class ProfileMoreScreen extends StatefulWidget {
  final String userId;

  const ProfileMoreScreen({super.key, required this.userId});

  @override
  State<ProfileMoreScreen> createState() => _ProfileMoreScreenState();
}

class _ProfileMoreScreenState extends State<ProfileMoreScreen> with TickerProviderStateMixin {
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

  void _editProfile() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Edit Profile feature coming soon!')),
    );
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
                    'Profile',
                    style: TextStyle(color: ChessEarnTheme.themeColors['text-light']),
                  ),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      children: [
                        // Profile Header
                        CircleAvatar(
                          radius: 50,
                          backgroundColor: ChessEarnTheme.themeColors['brand-accent'],
                          child: Icon(
                            Icons.person,
                            color: ChessEarnTheme.themeColors['text-light'],
                            size: 50,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'User ${widget.userId}',
                          style: TextStyle(
                            color: ChessEarnTheme.themeColors['text-light'],
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'Chess Enthusiast',
                          style: TextStyle(
                            color: ChessEarnTheme.themeColors['text-muted'],
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 20),
                        ElevatedButton.icon(
                          onPressed: _editProfile,
                          icon: const Icon(Icons.edit),
                          label: const Text('Edit Profile'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: ChessEarnTheme.themeColors['brand-accent'],
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                          ),
                        ),
                        const SizedBox(height: 20),
                        // Stats
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: Colors.white.withOpacity(0.2)),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              _buildStatItem('Games', '150', Icons.games),
                              _buildStatItem('Wins', '85', Icons.emoji_events),
                              _buildStatItem('Rating', '1450', Icons.star),
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

  Widget _buildStatItem(String title, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: ChessEarnTheme.themeColors['brand-accent'], size: 24),
        const SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            color: ChessEarnTheme.themeColors['text-light'],
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          title,
          style: TextStyle(
            color: ChessEarnTheme.themeColors['text-muted'],
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}