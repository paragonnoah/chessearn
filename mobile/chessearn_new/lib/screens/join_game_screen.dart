import 'package:flutter/material.dart';
import 'package:chessearn_new/screens/game_screen.dart';
import 'package:chessearn_new/services/api_service.dart';
import 'package:chessearn_new/theme.dart';

class JoinGameScreen extends StatefulWidget {
  final String? userId;
  const JoinGameScreen({super.key, required this.userId});

  @override
  JoinGameScreenState createState() => JoinGameScreenState();
}

class JoinGameScreenState extends State<JoinGameScreen> with TickerProviderStateMixin {
  List<Map<String, dynamic>> _availableGames = [];
  bool _isLoading = true;
  double _minStake = 0.0;
  double _maxStake = 100.0;
  int _minTime = 0;
  int _maxTime = 600;
  late AnimationController _refreshController;

  @override
  void initState() {
    super.initState();
    _refreshController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _fetchAvailableGames();
  }

  @override
  void dispose() {
    _refreshController.dispose();
    super.dispose();
  }

  Future<void> _fetchAvailableGames() async {
    setState(() => _isLoading = true);
    _refreshController.forward();
    
    try {
      final games = await _mockFetchGames();
      setState(() {
        _availableGames = games.where((game) {
          final stake = game['bet_amount'] ?? 0.0;
          final time = game['base_time'] ?? 0;
          return stake >= _minStake && stake <= _maxStake && 
                 time >= _minTime && time <= _maxTime;
        }).toList();
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _availableGames = [];
        _isLoading = false;
      });
    } finally {
      _refreshController.reset();
    }
  }

  Future<List<Map<String, dynamic>>> _mockFetchGames() async {
    await Future.delayed(const Duration(milliseconds: 800));
    return [
      {
        'id': 'game1',
        'white_player_id': 'user1',
        'white_player_name': 'ChessMaster',
        'status': 'pending',
        'bet_amount': 10.0,
        'base_time': 300,
        'increment': 0,
        'rating': 1450,
      },
      {
        'id': 'game2',
        'white_player_id': 'user2',
        'white_player_name': 'QueenSlayer',
        'status': 'pending',
        'bet_amount': 25.0,
        'base_time': 600,
        'increment': 2,
        'rating': 1620,
      },
      {
        'id': 'game3',
        'white_player_id': 'user3',
        'white_player_name': 'KnightRider',
        'status': 'pending',
        'bet_amount': 5.0,
        'base_time': 180,
        'increment': 1,
        'rating': 1280,
      },
    ];
  }

  Future<void> _joinGame(String gameId) async {
    if (widget.userId == null) return;
    
    try {
      await ApiService.joinGame(gameId);
      final game = _availableGames.firstWhere((g) => g['id'] == gameId);
      
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => GameScreen(
            userId: widget.userId,
            initialPlayMode: 'online',
            gameId: gameId,
            timeControl: '${game['base_time']}|${game['increment']}',
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to join game: $e'),
          backgroundColor: Colors.red[400],
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void _applyFilters(double minStake, double maxStake, int minTime, int maxTime) {
    setState(() {
      _minStake = minStake;
      _maxStake = maxStake;
      _minTime = minTime;
      _maxTime = maxTime;
    });
    _fetchAvailableGames();
  }

  Widget _buildFilterSection() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.tune, color: ChessEarnTheme.getColor('brand-dark'), size: 20),
              const SizedBox(width: 8),
              Text(
                'Filters',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: ChessEarnTheme.getColor('brand-dark'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildFilterField(
                  label: 'Min Stake',
                  suffix: 'Credits',
                  onChanged: (value) => _applyFilters(
                    double.tryParse(value) ?? 0.0, _maxStake, _minTime, _maxTime,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildFilterField(
                  label: 'Max Stake',
                  suffix: 'Credits',
                  onChanged: (value) => _applyFilters(
                    _minStake, double.tryParse(value) ?? 100.0, _minTime, _maxTime,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildFilterField(
                  label: 'Min Time',
                  suffix: 'sec',
                  onChanged: (value) => _applyFilters(
                    _minStake, _maxStake, int.tryParse(value) ?? 0, _maxTime,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildFilterField(
                  label: 'Max Time',
                  suffix: 'sec',
                  onChanged: (value) => _applyFilters(
                    _minStake, _maxStake, _minTime, int.tryParse(value) ?? 600,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFilterField({
    required String label,
    required String suffix,
    required Function(String) onChanged,
  }) {
    return TextField(
      decoration: InputDecoration(
        labelText: label,
        suffixText: suffix,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: ChessEarnTheme.getColor('brand-dark'), width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
      keyboardType: TextInputType.number,
      onChanged: onChanged,
    );
  }

  Widget _buildGameCard(Map<String, dynamic> game) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: ChessEarnTheme.getColor('brand-dark').withOpacity(0.1),
                borderRadius: BorderRadius.circular(25),
              ),
              child: Icon(
                Icons.person,
                color: ChessEarnTheme.getColor('brand-dark'),
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    game['white_player_name'] ?? 'Unknown Player',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.star, color: Colors.amber[600], size: 16),
                      const SizedBox(width: 4),
                      Text(
                        '${game['rating'] ?? 'Unrated'}',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(width: 16),
                      Icon(Icons.access_time, color: Colors.blue[600], size: 16),
                      const SizedBox(width: 4),
                      Text(
                        '${game['base_time']}s + ${game['increment']}s',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.monetization_on, color: Colors.green[600], size: 16),
                      const SizedBox(width: 4),
                      Text(
                        '${game['bet_amount']} Credits',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.green[700],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            ElevatedButton(
              onPressed: () => _joinGame(game['id']),
              style: ElevatedButton.styleFrom(
                backgroundColor: ChessEarnTheme.getColor('brand-dark'),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                elevation: 2,
              ),
              child: const Text(
                'Join',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          'Join Game',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: ChessEarnTheme.getColor('brand-dark'),
        elevation: 0,
        actions: [
          IconButton(
            icon: RotationTransition(
              turns: _refreshController,
              child: const Icon(Icons.refresh, color: Colors.white),
            ),
            onPressed: _fetchAvailableGames,
          ),
        ],
      ),
      body: Column(
        children: [
          _buildFilterSection(),
          Expanded(
            child: _isLoading
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(
                            ChessEarnTheme.getColor('brand-dark'),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Loading games...',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  )
                : _availableGames.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.sports_esports_outlined,
                              size: 64,
                              color: Colors.grey[400],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'No games available',
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.grey[600],
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Try adjusting your filters',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[500],
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        itemCount: _availableGames.length,
                        padding: const EdgeInsets.only(bottom: 16),
                        itemBuilder: (context, index) {
                          return _buildGameCard(_availableGames[index]);
                        },
                      ),
          ),
        ],
      ),
    );
  }
}