import 'package:flutter/material.dart';
import 'package:chessearn_new/services/api_service.dart';
import 'package:chessearn_new/theme.dart';
import 'package:chessearn_new/screens/game_screen.dart';

class OpenGamesScreen extends StatefulWidget {
  final String? userId;
  const OpenGamesScreen({super.key, required this.userId});
  @override
  _OpenGamesScreenState createState() => _OpenGamesScreenState();
}

class _OpenGamesScreenState extends State<OpenGamesScreen> with TickerProviderStateMixin {
  bool _isRated = true;
  int _baseTime = 300;
  int _increment = 0;
  double _betAmount = 10.0;
  bool _isLoading = false;
  
  late AnimationController _slideController;
  late AnimationController _pulseController;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _pulseAnimation;

  final _presets = [
    {'name': 'Blitz', 'time': 300, 'inc': 0, 'icon': Icons.flash_on, 'color': Colors.orange},
    {'name': 'Rapid', 'time': 900, 'inc': 10, 'icon': Icons.timer, 'color': Colors.green},
    {'name': 'Classic', 'time': 1800, 'inc': 30, 'icon': Icons.schedule, 'color': Colors.blue},
  ];

  @override
  void initState() {
    super.initState();
    _slideController = AnimationController(vsync: this, duration: const Duration(milliseconds: 600));
    _pulseController = AnimationController(vsync: this, duration: const Duration(milliseconds: 1500));
    
    _slideAnimation = Tween<Offset>(begin: const Offset(0, 1), end: Offset.zero)
        .animate(CurvedAnimation(parent: _slideController, curve: Curves.elasticOut));
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.1)
        .animate(CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut));
    
    _slideController.forward();
    _pulseController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _slideController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  Future<void> _createGame() async {
    if (widget.userId == null) return;
    setState(() => _isLoading = true);
    
    try {
      String gameId = await ApiService.createGame(
        isRated: _isRated,
        baseTime: _baseTime,
        increment: _increment,
        betAmount: _betAmount,
      );
      
      _showSuccessSnackBar();
      
      Navigator.pushReplacement(
        context,
        PageRouteBuilder(
          pageBuilder: (context, animation, _) => GameScreen(
            userId: widget.userId,
            initialPlayMode: 'online',
            timeControl: '$_baseTime|$_increment',
            gameId: gameId,
          ),
          transitionsBuilder: (context, animation, _, child) {
            return SlideTransition(
              position: Tween<Offset>(begin: const Offset(1, 0), end: Offset.zero).animate(animation),
              child: child,
            );
          },
        ),
      );
    } catch (e) {
      _showErrorSnackBar(e.toString());
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showSuccessSnackBar() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Row(
          children: [
            Icon(Icons.check_circle, color: Colors.white, size: 20),
            SizedBox(width: 8),
            Text('Game created successfully!'),
          ],
        ),
        backgroundColor: Colors.green.shade600,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  void _showErrorSnackBar(String error) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error, color: Colors.white, size: 20),
            const SizedBox(width: 8),
            Expanded(child: Text('Failed: $error')),
          ],
        ),
        backgroundColor: Colors.red.shade600,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(seconds: 4),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ChessEarnTheme.getColor('background-dark'),
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 120,
            floating: false,
            pinned: true,
            backgroundColor: ChessEarnTheme.getColor('brand-dark'),
            flexibleSpace: FlexibleSpaceBar(
              title: const Text('Create Game', style: TextStyle(fontWeight: FontWeight.bold)),
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      ChessEarnTheme.getColor('brand-dark')!,
                      ChessEarnTheme.getColor('brand-accent')!.withOpacity(0.3),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: SlideTransition(
              position: _slideAnimation,
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    _buildHeroCard(),
                    const SizedBox(height: 24),
                    _buildPresetsGrid(),
                    const SizedBox(height: 24),
                    _buildCustomSettings(),
                    const SizedBox(height: 32),
                    _buildCreateButton(),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeroCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            ChessEarnTheme.getColor('brand-accent')!.withOpacity(0.1),
            ChessEarnTheme.getColor('brand-accent')!.withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: ChessEarnTheme.getColor('brand-accent')!.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: ChessEarnTheme.getColor('brand-accent')!.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.add_circle, size: 40, color: ChessEarnTheme.getColor('brand-accent')),
          ),
          const SizedBox(height: 16),
          Text(
            'Start Your Match',
            style: TextStyle(
              color: ChessEarnTheme.getColor('text-light'),
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Configure your game settings and challenge players worldwide',
            textAlign: TextAlign.center,
            style: TextStyle(color: ChessEarnTheme.getColor('text-muted'), fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget _buildPresetsGrid() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quick Presets',
          style: TextStyle(
            color: ChessEarnTheme.getColor('text-light'),
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: _presets.map((preset) => Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: _buildPresetCard(preset),
            ),
          )).toList(),
        ),
      ],
    );
  }

  Widget _buildPresetCard(Map<String, dynamic> preset) {
    bool isSelected = _baseTime == preset['time'] && _increment == preset['inc'];
    return GestureDetector(
      onTap: () => setState(() {
        _baseTime = preset['time'];
        _increment = preset['inc'];
      }),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? preset['color'].withOpacity(0.2) : ChessEarnTheme.getColor('surface-dark'),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? preset['color'] : Colors.transparent,
            width: 2,
          ),
        ),
        child: Column(
          children: [
            Icon(preset['icon'], color: preset['color'], size: 24),
            const SizedBox(height: 8),
            Text(
              preset['name'],
              style: TextStyle(
                color: ChessEarnTheme.getColor('text-light'),
                fontWeight: FontWeight.w600,
                fontSize: 12,
              ),
            ),
            Text(
              '${preset['time']~/60}+${preset['inc']}',
              style: TextStyle(color: ChessEarnTheme.getColor('text-muted'), fontSize: 10),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCustomSettings() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: ChessEarnTheme.getColor('surface-dark'),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Game Settings',
            style: TextStyle(
              color: ChessEarnTheme.getColor('text-light'),
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          _buildRatedSwitch(),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(child: _buildTimeInput()),
              const SizedBox(width: 12),
              Expanded(child: _buildIncrementInput()),
            ],
          ),
          const SizedBox(height: 16),
          _buildBetInput(),
        ],
      ),
    );
  }

  Widget _buildRatedSwitch() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: ChessEarnTheme.getColor('background-dark'),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(Icons.star, color: _isRated ? Colors.amber : ChessEarnTheme.getColor('text-muted'), size: 20),
          const SizedBox(width: 12),
          Text('Rated Game', style: TextStyle(color: ChessEarnTheme.getColor('text-light'))),
          const Spacer(),
          Switch.adaptive(
            value: _isRated,
            onChanged: (value) => setState(() => _isRated = value),
            activeColor: ChessEarnTheme.getColor('brand-accent'),
          ),
        ],
      ),
    );
  }

  Widget _buildTimeInput() {
    return _buildInputField(
      label: 'Time (min)',
      value: (_baseTime / 60).toInt().toString(),
      icon: Icons.timer,
      onChanged: (value) => _baseTime = (int.tryParse(value) ?? 5) * 60,
    );
  }

  Widget _buildIncrementInput() {
    return _buildInputField(
      label: 'Increment (sec)',
      value: _increment.toString(),
      icon: Icons.add,
      onChanged: (value) => _increment = int.tryParse(value) ?? 0,
    );
  }

  Widget _buildBetInput() {
    return _buildInputField(
      label: 'Bet Amount',
      value: _betAmount.toString(),
      icon: Icons.monetization_on,
      onChanged: (value) => _betAmount = double.tryParse(value) ?? 10.0,
    );
  }

  Widget _buildInputField({
    required String label,
    required String value,
    required IconData icon,
    required Function(String) onChanged,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: ChessEarnTheme.getColor('background-dark'),
        borderRadius: BorderRadius.circular(12),
      ),
      child: TextField(
        controller: TextEditingController(text: value),
        style: TextStyle(color: ChessEarnTheme.getColor('text-light')),
        keyboardType: TextInputType.number,
        onChanged: onChanged,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(color: ChessEarnTheme.getColor('text-muted')),
          prefixIcon: Icon(icon, color: ChessEarnTheme.getColor('brand-accent'), size: 20),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
          filled: true,
          fillColor: Colors.transparent,
        ),
      ),
    );
  }

  Widget _buildCreateButton() {
    return ScaleTransition(
      scale: _isLoading ? _pulseAnimation : const AlwaysStoppedAnimation(1.0),
      child: Container(
        width: double.infinity,
        height: 56,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            colors: [
              ChessEarnTheme.getColor('brand-accent')!,
              ChessEarnTheme.getColor('brand-accent')!.withOpacity(0.8),
            ],
          ),
          boxShadow: [
            BoxShadow(
              color: ChessEarnTheme.getColor('brand-accent')!.withOpacity(0.4),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: _isLoading ? null : _createGame,
            child: Center(
              child: _isLoading
                  ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                    )
                  : const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.rocket_launch, color: Colors.white, size: 24),
                        SizedBox(width: 8),
                        Text(
                          'Create Game',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
            ),
          ),
        ),
      ),
    );
  }
}