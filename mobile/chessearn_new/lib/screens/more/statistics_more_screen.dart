import 'package:flutter/material.dart';
import 'package:chessearn_new/theme.dart';

class StatisticsMoreScreen extends StatefulWidget {
  const StatisticsMoreScreen({super.key});

  @override
  State<StatisticsMoreScreen> createState() => _StatisticsMoreScreenState();
}

class _StatisticsMoreScreenState extends State<StatisticsMoreScreen> with TickerProviderStateMixin {
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
                    'Statistics',
                    style: TextStyle(color: ChessEarnTheme.themeColors['text-light']),
                  ),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      children: [
                        // Overview Card
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: Colors.white.withOpacity(0.2)),
                          ),
                          child: Column(
                            children: [
                              Text(
                                'Performance Overview',
                                style: TextStyle(
                                  color: ChessEarnTheme.themeColors['text-light'],
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 16),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                children: [
                                  _buildStatItem('Games', '150', Icons.games, Colors.blue),
                                  _buildStatItem('Wins', '85', Icons.emoji_events, Colors.green),
                                  _buildStatItem('Win Rate', '57%', Icons.percent, Colors.orange),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),
                        // Detailed Stats
                        _buildStatCard('Rating', '1450', Icons.star, Colors.purple),
                        _buildStatCard('Best Streak', '10', Icons.local_fire_department, Colors.red),
                        _buildStatCard('Puzzles Solved', '200', Icons.extension, Colors.teal),
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

  Widget _buildStatItem(String title, String value, IconData icon, Color color) {
    return Column(
      children: [
        Icon(icon, color: color, size: 24),
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

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              title,
              style: TextStyle(color: ChessEarnTheme.themeColors['text-light']),
            ),
          ),
          Text(
            value,
            style: TextStyle(
              color: ChessEarnTheme.themeColors['text-light'],
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}