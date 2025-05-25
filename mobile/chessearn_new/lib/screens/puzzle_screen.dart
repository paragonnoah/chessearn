import 'package:flutter/material.dart';
import 'package:chessearn_new/theme.dart';

class PuzzleScreen extends StatefulWidget {
  final String? userId;

  const PuzzleScreen({super.key, required this.userId});

  @override
  _PuzzleScreenState createState() => _PuzzleScreenState();
}

class _PuzzleScreenState extends State<PuzzleScreen> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    _scaleAnimation = Tween<double>(begin: 0.9, end: 1.1).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _animationController.repeat(reverse: true); // Continuous pulsing effect
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  // Placeholder action for buttons
  void _onButtonTap(String action) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '$action (Coming Soon!)',
          style: TextStyle(color: ChessEarnTheme.themeColors['text-light']),
        ),
        backgroundColor: ChessEarnTheme.themeColors['surface-dark'] ?? Colors.grey[800],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              ChessEarnTheme.themeColors['brand-gradient-start'] ?? Colors.black,
              ChessEarnTheme.themeColors['brand-gradient-end'] ?? Colors.blueGrey[900]!,
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            stops: const [0.0, 0.8],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header with Back Arrow, Chessboard, and Title
              Container(
                padding: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      ChessEarnTheme.themeColors['brand-dark']!.withOpacity(0.9),
                      ChessEarnTheme.themeColors['surface-dark']!.withOpacity(0.7),
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: ChessEarnTheme.themeColors['brand-accent']!.withOpacity(0.3),
                      blurRadius: 15,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        IconButton(
                          icon: Icon(
                            Icons.arrow_back,
                            color: ChessEarnTheme.themeColors['text-light'],
                          ),
                          onPressed: () {
                            Navigator.pop(context); // Navigate back to MainScreen
                          },
                        ),
                        const SizedBox(width: 8),
                        const Icon(
                          Icons.sports_esports, // Chess-related icon
                          color: Colors.white,
                          size: 40,
                        ),
                        const SizedBox(width: 10),
                        Text(
                          'Chess Odyssey',
                          style: TextStyle(
                            color: ChessEarnTheme.themeColors['text-light'],
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            shadows: [
                              Shadow(
                                color: ChessEarnTheme.themeColors['brand-accent']!.withOpacity(0.5),
                                offset: const Offset(2, 2),
                                blurRadius: 4,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    if (widget.userId == null)
                      Text(
                        'Guest Mode',
                        style: TextStyle(
                          color: ChessEarnTheme.themeColors['text-muted'],
                          fontSize: 16,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                  ],
                ),
              ),
              // Coach Avatar and Message
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 40,
                      backgroundImage: const AssetImage('assets/images/coach_avatar.png'), // Non-const
                      backgroundColor: ChessEarnTheme.themeColors['brand-accent'],
                      child: Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: ChessEarnTheme.themeColors['text-light']!.withOpacity(0.3),
                            width: 2,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(12.0),
                        decoration: BoxDecoration(
                          color: ChessEarnTheme.themeColors['surface-dark']!.withOpacity(0.9),
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: ChessEarnTheme.themeColors['brand-accent']!.withOpacity(0.2),
                              blurRadius: 10,
                            ),
                          ],
                        ),
                        child: Text(
                          'Master your game with puzzles! Enhance your strategy and foresight.',
                          style: TextStyle(
                            color: ChessEarnTheme.themeColors['text-light'],
                            fontSize: 16,
                            height: 1.3,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              // Puzzle Progress
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Puzzles Solved: 0',
                      style: TextStyle(
                        color: ChessEarnTheme.themeColors['text-light'],
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.all(8.0),
                      decoration: BoxDecoration(
                        color: ChessEarnTheme.themeColors['brand-accent']!.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        'Level 1',
                        style: TextStyle(
                          color: ChessEarnTheme.themeColors['brand-accent'],
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              // Interactive Puzzle Options
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                  child: ListView(
                    children: [
                      _buildPuzzleButton(
                        icon: Icons.play_arrow,
                        label: 'Start Puzzle Journey',
                        color: Colors.green[700]!,
                        onTap: () => _onButtonTap('Start Puzzle Journey'),
                      ),
                      _buildPuzzleButton(
                        icon: Icons.flash_on,
                        label: 'Quick Challenge',
                        color: Colors.orange[700]!,
                        onTap: () => _onButtonTap('Quick Challenge'),
                      ),
                      _buildPuzzleButton(
                        icon: Icons.calendar_today,
                        label: 'Daily Brainteaser',
                        color: Colors.teal[700]!,
                        onTap: () => _onButtonTap('Daily Brainteaser'),
                      ),
                      _buildPuzzleButton(
                        icon: Icons.shield,
                        label: 'Tactical Duel',
                        color: Colors.purple[700]!,
                        onTap: () => _onButtonTap('Tactical Duel'),
                      ),
                      _buildPuzzleButton(
                        icon: Icons.edit,
                        label: 'Create Your Own',
                        color: Colors.blueGrey[700]!,
                        onTap: () => _onButtonTap('Create Your Own'),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Custom puzzle button with animation
  Widget _buildPuzzleButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: AnimatedBuilder(
        animation: _animationController,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: onTap,
                borderRadius: BorderRadius.circular(15),
                child: Container(
                  padding: const EdgeInsets.all(16.0),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        color.withOpacity(0.9),
                        color.withOpacity(0.6),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(15),
                    boxShadow: [
                      BoxShadow(
                        color: color.withOpacity(0.3),
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Icon(
                        icon,
                        color: ChessEarnTheme.themeColors['text-light'],
                        size: 30,
                      ),
                      Text(
                        label,
                        style: TextStyle(
                          color: ChessEarnTheme.themeColors['text-light'],
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Icon(
                        Icons.arrow_forward_ios,
                        color: Colors.white70,
                        size: 20,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}