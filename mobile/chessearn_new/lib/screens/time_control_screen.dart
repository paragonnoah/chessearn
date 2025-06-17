import 'package:flutter/material.dart';
import 'package:chessearn_new/screens/game_screen.dart';
import 'package:chessearn_new/services/api_service.dart';
import 'package:chessearn_new/theme.dart';

class TimeControlScreen extends StatefulWidget {
  final String? userId;
  const TimeControlScreen({super.key, required this.userId});

  @override
  _TimeControlScreenState createState() => _TimeControlScreenState();
}

class _TimeControlScreenState extends State<TimeControlScreen> with TickerProviderStateMixin {
  String _selectedTimeControl = '15|10'; // Default to 15|10
  late AnimationController _fadeController;
  late AnimationController _scaleController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
    );
    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.elasticOut),
    );
    
    _fadeController.forward();
    _scaleController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _scaleController.dispose();
    super.dispose();
  }

  Future<void> _startGame() async {
    setState(() {
      _isLoading = true;
    });
    
    try {
      // Parse time control into baseTime and increment
      final parts = _selectedTimeControl.split('|');
      int baseTime = int.parse(parts[0]);
      int increment = parts.length > 1 ? int.parse(parts[1].replaceAll('d', '')) : 0;
      bool isDaily = _selectedTimeControl.contains('d');

      // Create game using ApiService with named parameters
      String gameId = await ApiService.createGame(
        isRated: true, // Default to rated, can be made configurable
        baseTime: isDaily ? 0 : baseTime, // Adjust for daily games
        increment: isDaily ? 0 : increment,
        betAmount: 0.0, // Default bet amount, can be made configurable
      );

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => GameScreen(
            userId: widget.userId,
            initialPlayMode: 'online', // Default to online mode
            timeControl: _selectedTimeControl,
            gameId: gameId, // Pass the created gameId
          ),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to start game: $e'),
          backgroundColor: Colors.red.shade700,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ChessEarnTheme.themeColors['background-dark'],
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 120,
            floating: false,
            pinned: true,
            backgroundColor: ChessEarnTheme.themeColors['brand-dark'],
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                'New Game',
                style: TextStyle(
                  color: ChessEarnTheme.themeColors['text-light'],
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      ChessEarnTheme.themeColors['brand-dark']!,
                      ChessEarnTheme.themeColors['brand-dark']!.withOpacity(0.8),
                    ],
                  ),
                ),
              ),
            ),
            leading: IconButton(
              icon: Icon(Icons.arrow_back_ios, color: ChessEarnTheme.themeColors['text-light']),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          SliverToBoxAdapter(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: ScaleTransition(
                scale: _scaleAnimation,
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Hero section with chess icon
                      _buildHeroSection(),
                      const SizedBox(height: 32),
                      
                      // Time control selection
                      _buildTimeControlCard(),
                      const SizedBox(height: 24),
                      
                      // Start Game button
                      _buildStartGameButton(),
                      const SizedBox(height: 32),
                      
                      // Game modes section
                      _buildGameModesSection(),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeroSection() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 24),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [
                  ChessEarnTheme.themeColors['brand-accent']!,
                  ChessEarnTheme.themeColors['brand-accent']!.withOpacity(0.7),
                ],
              ),
              boxShadow: [
                BoxShadow(
                  color: ChessEarnTheme.themeColors['brand-accent']!.withOpacity(0.3),
                  blurRadius: 20,
                  spreadRadius: 5,
                ),
              ],
            ),
            child: const Icon(
              Icons.sports_esports,
              size: 48,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Ready to Play?',
            style: TextStyle(
              color: ChessEarnTheme.themeColors['text-light'],
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Choose your time control and start your game',
            style: TextStyle(
              color: ChessEarnTheme.themeColors['text-muted'],
              fontSize: 14,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildTimeControlCard() {
    return Container(
      decoration: BoxDecoration(
        color: ChessEarnTheme.themeColors['surface-dark'],
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: ChessEarnTheme.themeColors['brand-accent']!.withOpacity(0.3),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => _showTimeControlDialog(context),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: ChessEarnTheme.themeColors['brand-accent']!.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.timer,
                    color: ChessEarnTheme.themeColors['brand-accent'],
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Time Control',
                        style: TextStyle(
                          color: ChessEarnTheme.themeColors['text-muted'],
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _selectedTimeControl.replaceAll('|', ' + '),
                        style: TextStyle(
                          color: ChessEarnTheme.themeColors['text-light'],
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.keyboard_arrow_down,
                  color: ChessEarnTheme.themeColors['text-muted'],
                  size: 24,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStartGameButton() {
    return Container(
      height: 56,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: LinearGradient(
          colors: [
            ChessEarnTheme.themeColors['brand-accent']!,
            ChessEarnTheme.themeColors['brand-accent']!.withOpacity(0.8),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: ChessEarnTheme.themeColors['brand-accent']!.withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: _isLoading ? null : _startGame,
          child: Center(
            child: _isLoading
                ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  )
                : const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.play_arrow,
                        color: Colors.white,
                        size: 24,
                      ),
                      SizedBox(width: 8),
                      Text(
                        'Start Game',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }

  Widget _buildGameModesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Game Modes',
          style: TextStyle(
            color: ChessEarnTheme.themeColors['text-light'],
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 16),
        _buildOptionCard(
          icon: Icons.emoji_events,
          title: 'Tournaments',
          subtitle: 'Compete with multiple players',
          color: Colors.amber,
          onTap: () {
            _showComingSoonSnackBar('Tournaments');
          },
        ),
        _buildOptionCard(
          icon: Icons.people,
          title: 'Play a Friend',
          subtitle: 'Challenge your friends',
          color: Colors.green,
          onTap: () {
            _showComingSoonSnackBar('Play a Friend');
          },
        ),
        _buildOptionCard(
          icon: Icons.smart_toy,
          title: 'Play a Bot',
          subtitle: 'Practice against AI',
          color: Colors.blue,
          onTap: () async {
            setState(() {
              _isLoading = true;
            });
            try {
              String gameId = await ApiService.createGame(
                isRated: false,
                baseTime: 5,
                increment: 0,
                betAmount: 0.0,
              );
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => GameScreen(
                    userId: widget.userId,
                    initialPlayMode: 'computer',
                    timeControl: _selectedTimeControl,
                    gameId: gameId,
                  ),
                ),
              );
            } catch (e) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Failed to start bot game: $e'),
                  backgroundColor: Colors.red.shade700,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              );
            } finally {
              setState(() {
                _isLoading = false;
              });
            }
          },
        ),
        _buildOptionCard(
          icon: Icons.school,
          title: 'Play Coach',
          subtitle: 'Learn from expert guidance',
          color: Colors.purple,
          onTap: () {
            _showComingSoonSnackBar('Play Coach');
          },
        ),
        const SizedBox(height: 16),
        _buildExpandableSection(),
      ],
    );
  }

  Widget _buildOptionCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: ChessEarnTheme.themeColors['surface-dark'],
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: color.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    icon,
                    color: color,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          color: ChessEarnTheme.themeColors['text-light'],
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        style: TextStyle(
                          color: ChessEarnTheme.themeColors['text-muted'],
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios,
                  color: ChessEarnTheme.themeColors['text-muted'],
                  size: 16,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildExpandableSection() {
    return Container(
      decoration: BoxDecoration(
        color: ChessEarnTheme.themeColors['surface-dark'],
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: ChessEarnTheme.themeColors['text-muted']!.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          iconColor: ChessEarnTheme.themeColors['brand-accent'],
          collapsedIconColor: ChessEarnTheme.themeColors['text-muted'],
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: ChessEarnTheme.themeColors['brand-accent']!.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.more_horiz,
                  color: ChessEarnTheme.themeColors['brand-accent'],
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'More Options',
                style: TextStyle(
                  color: ChessEarnTheme.themeColors['text-light'],
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Column(
                children: [
                  _buildSimpleOptionCard(
                    icon: Icons.tune,
                    title: 'Custom Game',
                    onTap: () {
                      _showComingSoonSnackBar('Custom Game');
                    },
                  ),
                  _buildSimpleOptionCard(
                    icon: Icons.person_pin_circle,
                    title: 'Play in Person',
                    onTap: () {
                      _showComingSoonSnackBar('Play in Person');
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSimpleOptionCard({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Icon(
                  icon,
                  color: ChessEarnTheme.themeColors['brand-accent'],
                  size: 20,
                ),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: TextStyle(
                    color: ChessEarnTheme.themeColors['text-light'],
                    fontSize: 14,
                  ),
                ),
                const Spacer(),
                Icon(
                  Icons.arrow_forward_ios,
                  color: ChessEarnTheme.themeColors['text-muted'],
                  size: 12,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showComingSoonSnackBar(String feature) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$feature feature coming soon!'),
        backgroundColor: ChessEarnTheme.themeColors['brand-accent'],
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  void _showTimeControlDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            constraints: const BoxConstraints(maxWidth: 400, maxHeight: 600),
            decoration: BoxDecoration(
              color: ChessEarnTheme.themeColors['surface-dark'],
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: ChessEarnTheme.themeColors['brand-dark'],
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(20),
                      topRight: Radius.circular(20),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.timer,
                        color: ChessEarnTheme.themeColors['brand-accent'],
                        size: 24,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'Select Time Control',
                        style: TextStyle(
                          color: ChessEarnTheme.themeColors['text-light'],
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const Spacer(),
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: Icon(
                          Icons.close,
                          color: ChessEarnTheme.themeColors['text-muted'],
                        ),
                      ),
                    ],
                  ),
                ),
                Flexible(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        _buildTimeControlSection(
                          title: 'Bullet',
                          subtitle: 'Fast-paced games',
                          icon: Icons.flash_on,
                          color: Colors.red,
                          options: [
                            {'label': '1 min', 'value': '1|0'},
                            {'label': '1|1', 'value': '1|1'},
                            {'label': '2|1', 'value': '2|1'},
                          ],
                        ),
                        _buildTimeControlSection(
                          title: 'Blitz',
                          subtitle: 'Quick thinking',
                          icon: Icons.bolt,
                          color: Colors.orange,
                          options: [
                            {'label': '3 min', 'value': '3|0'},
                            {'label': '3|2', 'value': '3|2'},
                            {'label': '5 min', 'value': '5|0'},
                          ],
                        ),
                        _buildTimeControlSection(
                          title: 'Rapid',
                          subtitle: 'Balanced gameplay',
                          icon: Icons.timer,
                          color: Colors.green,
                          options: [
                            {'label': '10 min', 'value': '10|0'},
                            {'label': '15|10', 'value': '15|10'},
                            {'label': '30 min', 'value': '30|0'},
                          ],
                        ),
                        _buildTimeControlSection(
                          title: 'Daily',
                          subtitle: 'Think carefully',
                          icon: Icons.today,
                          color: Colors.blue,
                          options: [
                            {'label': '1 day', 'value': '1d'},
                            {'label': '3 days', 'value': '3d'},
                            {'label': '7 days', 'value': '7d'},
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildTimeControlSection({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required List<Map<String, String>> options,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: ChessEarnTheme.themeColors['text-light'],
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: ChessEarnTheme.themeColors['text-muted'],
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8.0,
            runSpacing: 8.0,
            children: options.map((option) {
              bool isSelected = _selectedTimeControl == option['value'];
              return Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isSelected ? color : ChessEarnTheme.themeColors['text-muted']!.withOpacity(0.3),
                    width: 1.5,
                  ),
                ),
                child: Material(
                  color: isSelected ? color.withOpacity(0.1) : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(12),
                    onTap: () {
                      setState(() {
                        _selectedTimeControl = option['value']!;
                      });
                      Navigator.pop(context);
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      child: Text(
                        option['label']!,
                        style: TextStyle(
                          color: isSelected ? color : ChessEarnTheme.themeColors['text-light'],
                          fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}