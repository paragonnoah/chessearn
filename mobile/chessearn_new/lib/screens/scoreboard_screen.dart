
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:chessearn_new/services/api_service.dart';
import 'package:chessearn_new/screens/more/profile_more_screen.dart';
import 'package:chessearn_new/theme.dart';

class ScoreboardScreen extends StatefulWidget {
  final String? userId;

  const ScoreboardScreen({super.key, required this.userId});

  @override
  State<ScoreboardScreen> createState() => _ScoreboardScreenState();
}

class _ScoreboardScreenState extends State<ScoreboardScreen> {
  List<Map<String, dynamic>> _leaderboard = [];
  bool _isLoading = true;
  bool _hasError = false;
  String _selectedGameType = 'rapid';
  final List<String> _gameTypes = ['bullet', 'blitz', 'rapid', 'classical'];

  @override
  void initState() {
    super.initState();
    _fetchLeaderboard();
  }

  Future<void> _fetchLeaderboard() async {
    setState(() {
      _isLoading = true;
      _hasError = false;
    });

    try {
      final leaderboard = await ApiService.getLeaderboard(
        gameType: _selectedGameType,
        limit: 100,
      );
      setState(() {
        _leaderboard = leaderboard;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _hasError = true;
      });
    }
  }

  String _getCountryFlag(String countryCode) {
    if (countryCode.isEmpty || countryCode.length != 2) {
      return '🌍';
    }
    try {
      final upperCode = countryCode.toUpperCase();
      final firstLetter = upperCode.codeUnitAt(0);
      final secondLetter = upperCode.codeUnitAt(1);
      if (firstLetter >= 65 && firstLetter <= 90 && secondLetter >= 65 && secondLetter <= 90) {
        return String.fromCharCodes([
          0x1F1E6 + (firstLetter - 65),
          0x1F1E6 + (secondLetter - 65),
        ]);
      }
    } catch (e) {}
    return '🌍';
  }

  @override
  Widget build(BuildContext context) {
    final theme = ChessEarnTheme.themeData;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(gradient: ChessEarnTheme.backgroundGradient),
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(),
              _buildGameTypeSelector(),
              Expanded(
                child: _isLoading
                    ? _buildLoadingState()
                    : _hasError
                        ? _buildErrorState()
                        : _buildLeaderboard(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: Icon(Icons.arrow_back, color: ChessEarnTheme.getColor('text-light')),
            onPressed: () => Navigator.pop(context),
          ),
          Text(
            'Leaderboard',
            style: ChessEarnTheme.themeData.textTheme.headlineLarge?.copyWith(
              color: ChessEarnTheme.getColor('text-light'),
              fontSize: 28,
            ),
          ),
          const SizedBox(width: 48), // Spacer for symmetry
        ],
      ),
    );
  }

  Widget _buildGameTypeSelector() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: _gameTypes.map((gameType) {
            final isSelected = _selectedGameType == gameType;
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: ChoiceChip(
                label: Text(
                  gameType.capitalize(),
                  style: TextStyle(
                    color: isSelected ? ChessEarnTheme.getColor('text-light') : ChessEarnTheme.getColor('text-muted'),
                  ),
                ),
                selected: isSelected,
                onSelected: (selected) {
                  if (selected && !isSelected) {
                    setState(() {
                      _selectedGameType = gameType;
                    });
                    _fetchLeaderboard();
                  }
                },
                selectedColor: ChessEarnTheme.getColor('brand-accent'),
                backgroundColor: ChessEarnTheme.getColor('surface-dark'),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                  side: BorderSide(color: ChessEarnTheme.getColor('border-soft')),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildLoadingState() {
    return ListView.builder(
      itemCount: 10,
      itemBuilder: (context, index) {
        return Shimmer.fromColors(
          baseColor: ChessEarnTheme.getColor('surface-dark'),
          highlightColor: ChessEarnTheme.getColor('surface-card'),
          child: ListTile(
            leading: CircleAvatar(backgroundColor: Colors.white),
            title: Container(height: 16, color: Colors.white),
            subtitle: Container(height: 12, color: Colors.white),
          ),
        );
      },
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            color: ChessEarnTheme.getColor('error'),
            size: 48,
          ),
          const SizedBox(height: 16),
          Text(
            'Failed to load leaderboard',
            style: ChessEarnTheme.themeData.textTheme.bodyLarge?.copyWith(
              color: ChessEarnTheme.getColor('text-light'),
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _fetchLeaderboard,
            style: ElevatedButton.styleFrom(
              backgroundColor: ChessEarnTheme.getColor('brand-accent'),
              foregroundColor: ChessEarnTheme.getColor('text-light'),
            ),
            child: Text('Retry', style: ChessEarnTheme.themeData.textTheme.bodyLarge),
          ),
        ],
      ),
    );
  }

  Widget _buildLeaderboard() {
    return RefreshIndicator(
      onRefresh: _fetchLeaderboard,
      color: ChessEarnTheme.getColor('brand-accent'),
      backgroundColor: ChessEarnTheme.getColor('surface-dark'),
      child: ListView.builder(
        itemCount: _leaderboard.length,
        itemBuilder: (context, index) {
          final player = _leaderboard[index];
          final rank = index + 1;
          final countryFlag = _getCountryFlag(player['country_code'] ?? '');
          final username = player['username'] ?? 'Unknown';
          final rating = player['rating']?.toString() ?? '0';
          final playerId = player['id']?.toString();

          return Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            decoration: BoxDecoration(
              color: ChessEarnTheme.getColor('surface-dark'),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: ChessEarnTheme.getColor('border-soft')),
            ),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: ChessEarnTheme.getColor('brand-accent'),
                child: Text(
                  '$rank',
                  style: TextStyle(color: ChessEarnTheme.getColor('text-light')),
                ),
              ),
              title: Row(
                children: [
                  Text(
                    countryFlag,
                    style: const TextStyle(fontSize: 20),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      username,
                      style: ChessEarnTheme.themeData.textTheme.bodyLarge?.copyWith(
                        color: ChessEarnTheme.getColor('text-light'),
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              subtitle: Text(
                'Rating: $rating',
                style: ChessEarnTheme.themeData.textTheme.bodyMedium?.copyWith(
                  color: ChessEarnTheme.getColor('text-muted'),
                ),
              ),
              onTap: playerId != null && widget.userId != null
                  ? () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ProfileMoreScreen(userId: playerId),
                        ),
                      );
                    }
                  : null,
            ),
          );
        },
      ),
    );
  }
}

extension StringExtension on String {
  String capitalize() {
    if (isEmpty) return this;
    return '${this[0].toUpperCase()}${substring(1)}';
  }
}
