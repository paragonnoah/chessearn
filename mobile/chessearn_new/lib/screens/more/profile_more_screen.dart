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
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  
  // Mock user data - in real app this would come from API/database
  final Map<String, dynamic> _userData = {
    'username': 'ChessMaster2024',
    'displayName': 'Magnus Carlsen Jr.',
    'country': 'Norway',
    'countryCode': 'NO',
    'joinDate': 'January 2022',
    'lastOnline': '2 hours ago',
    'isOnline': false,
    'profilePicture': null, // In real app, this would be an image URL
    'rating': {
      'rapid': 1847,
      'blitz': 1632,
      'bullet': 1543,
      'classical': 1923,
    },
    'stats': {
      'totalGames': 2847,
      'wins': 1623,
      'losses': 891,
      'draws': 333,
      'winRate': 57.0,
    },
    'achievements': [
      {'title': 'First Win', 'icon': Icons.emoji_events, 'earned': true},
      {'title': '100 Games', 'icon': Icons.games, 'earned': true},
      {'title': 'Rating 1500+', 'icon': Icons.trending_up, 'earned': true},
      {'title': '1000 Games', 'icon': Icons.military_tech, 'earned': false},
    ],
    'recentActivity': [
      {'type': 'win', 'opponent': 'Bobby_Fischer_Fan', 'rating': '+12', 'time': '2h ago'},
      {'type': 'loss', 'opponent': 'QueensGambit99', 'rating': '-8', 'time': '5h ago'},
      {'type': 'win', 'opponent': 'PawnStorm', 'rating': '+15', 'time': '1d ago'},
    ],
  };

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeOut),
    );
    
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _slideController, curve: Curves.easeOutBack));
    
    _fadeController.forward();
    _slideController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  void _editProfile() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Edit Profile feature coming soon!'),
        backgroundColor: ChessEarnTheme.themeColors['brand-accent'],
      ),
    );
  }

  String _getCountryFlag(String countryCode) {
    // Simple country code to flag emoji mapping
    final flags = {
      'NO': '🇳🇴', 'US': '🇺🇸', 'GB': '🇬🇧', 'DE': '🇩🇪', 'FR': '🇫🇷',
      'ES': '🇪🇸', 'IT': '🇮🇹', 'RU': '🇷🇺', 'IN': '🇮🇳', 'CN': '🇨🇳',
    };
    return flags[countryCode] ?? '🌍';
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
            child: SlideTransition(
              position: _slideAnimation,
              child: CustomScrollView(
                slivers: [
                  // App Bar
                  SliverAppBar(
                    backgroundColor: Colors.transparent,
                    elevation: 0,
                    pinned: true,
                    expandedHeight: 80,
                    leading: IconButton(
                      icon: Icon(Icons.arrow_back, color: ChessEarnTheme.themeColors['text-light']),
                      onPressed: () => Navigator.pop(context),
                    ),
                    title: Text(
                      'Player Profile',
                      style: TextStyle(
                        color: ChessEarnTheme.themeColors['text-light'],
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    actions: [
                      IconButton(
                        icon: Icon(Icons.share, color: ChessEarnTheme.themeColors['text-light']),
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Share profile feature coming soon!')),
                          );
                        },
                      ),
                    ],
                  ),
                  
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        children: [
                          // Profile Header Card
                          _buildProfileHeader(),
                          const SizedBox(height: 24),
                          
                          // Rating Cards
                          _buildRatingSection(),
                          const SizedBox(height: 24),
                          
                          // Statistics
                          _buildStatsSection(),
                          const SizedBox(height: 24),
                          
                          // Achievements
                          _buildAchievementsSection(),
                          const SizedBox(height: 24),
                          
                          // Recent Activity
                          _buildRecentActivitySection(),
                          const SizedBox(height: 24),
                        ],
                      ),
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

  Widget _buildProfileHeader() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.2)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          // Profile Picture and Online Status
          Stack(
            children: [
              CircleAvatar(
                radius: 50,
                backgroundColor: ChessEarnTheme.themeColors['brand-accent'],
                child: _userData['profilePicture'] != null
                    ? ClipOval(child: Image.network(_userData['profilePicture'], fit: BoxFit.cover))
                    : Icon(
                        Icons.person,
                        color: ChessEarnTheme.themeColors['text-light'],
                        size: 50,
                      ),
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: _userData['isOnline'] ? Colors.green : Colors.grey,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          // Username and Display Name
          Text(
            _userData['displayName'],
            style: TextStyle(
              color: ChessEarnTheme.themeColors['text-light'],
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '@${_userData['username']}',
            style: TextStyle(
              color: ChessEarnTheme.themeColors['text-muted'],
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 12),
          
          // Country and Join Date Row
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                _getCountryFlag(_userData['countryCode']),
                style: const TextStyle(fontSize: 20),
              ),
              const SizedBox(width: 8),
              Text(
                _userData['country'],
                style: TextStyle(
                  color: ChessEarnTheme.themeColors['text-light'],
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(width: 16),
              Icon(Icons.calendar_today, 
                color: ChessEarnTheme.themeColors['text-muted'], size: 16),
              const SizedBox(width: 4),
              Text(
                'Joined ${_userData['joinDate']}',
                style: TextStyle(
                  color: ChessEarnTheme.themeColors['text-muted'],
                  fontSize: 14,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          
          Text(
            'Last seen: ${_userData['lastOnline']}',
            style: TextStyle(
              color: ChessEarnTheme.themeColors['text-muted'],
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 20),
          
          // Edit Profile Button
          ElevatedButton.icon(
            onPressed: _editProfile,
            icon: const Icon(Icons.edit, size: 18),
            label: const Text('Edit Profile'),
            style: ElevatedButton.styleFrom(
              backgroundColor: ChessEarnTheme.themeColors['brand-accent'],
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRatingSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Ratings',
          style: TextStyle(
            color: ChessEarnTheme.themeColors['text-light'],
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 2.5,
          children: _userData['rating'].entries.map<Widget>((entry) {
            return _buildRatingCard(entry.key, entry.value);
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildRatingCard(String gameType, int rating) {
    Color ratingColor = rating >= 1800 ? Colors.green : 
                       rating >= 1500 ? Colors.orange : 
                       rating >= 1200 ? Colors.blue : Colors.grey;
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            gameType.toUpperCase(),
            style: TextStyle(
              color: ChessEarnTheme.themeColors['text-muted'],
              fontSize: 12,
              fontWeight: FontWeight.w600,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            rating.toString(),
            style: TextStyle(
              color: ratingColor,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsSection() {
    final stats = _userData['stats'];
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Game Statistics',
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
              _buildStatItem('Games', stats['totalGames'].toString(), Icons.games),
              _buildStatItem('Wins', stats['wins'].toString(), Icons.emoji_events),
              _buildStatItem('Losses', stats['losses'].toString(), Icons.close),
              _buildStatItem('Draws', stats['draws'].toString(), Icons.remove),
            ],
          ),
          const SizedBox(height: 16),
          Center(
            child: Column(
              children: [
                Text(
                  'Win Rate',
                  style: TextStyle(
                    color: ChessEarnTheme.themeColors['text-muted'],
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${stats['winRate']}%',
                  style: TextStyle(
                    color: ChessEarnTheme.themeColors['brand-accent'],
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
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

  Widget _buildAchievementsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Achievements',
          style: TextStyle(
            color: ChessEarnTheme.themeColors['text-light'],
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 3,
          children: _userData['achievements'].map<Widget>((achievement) {
            return _buildAchievementCard(achievement);
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildAchievementCard(Map<String, dynamic> achievement) {
    bool earned = achievement['earned'];
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: earned ? Colors.amber.withOpacity(0.2) : Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: earned ? Colors.amber.withOpacity(0.5) : Colors.white.withOpacity(0.1),
        ),
      ),
      child: Row(
        children: [
          Icon(
            achievement['icon'],
            color: earned ? Colors.amber : ChessEarnTheme.themeColors['text-muted'],
            size: 20,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              achievement['title'],
              style: TextStyle(
                color: earned ? Colors.amber : ChessEarnTheme.themeColors['text-muted'],
                fontSize: 12,
                fontWeight: earned ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentActivitySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Recent Games',
          style: TextStyle(
            color: ChessEarnTheme.themeColors['text-light'],
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.1),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white.withOpacity(0.2)),
          ),
          child: ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _userData['recentActivity'].length,
            separatorBuilder: (context, index) => Divider(
              color: Colors.white.withOpacity(0.1),
              height: 1,
            ),
            itemBuilder: (context, index) {
              final activity = _userData['recentActivity'][index];
              return _buildActivityItem(activity);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildActivityItem(Map<String, dynamic> activity) {
    Color resultColor = activity['type'] == 'win' ? Colors.green : 
                       activity['type'] == 'loss' ? Colors.red : Colors.grey;
    IconData resultIcon = activity['type'] == 'win' ? Icons.keyboard_arrow_up : 
                         activity['type'] == 'loss' ? Icons.keyboard_arrow_down : Icons.remove;
                         
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: resultColor.withOpacity(0.2),
        child: Icon(resultIcon, color: resultColor, size: 20),
      ),
      title: Text(
        'vs ${activity['opponent']}',
        style: TextStyle(
          color: ChessEarnTheme.themeColors['text-light'],
          fontWeight: FontWeight.w500,
        ),
      ),
      subtitle: Text(
        activity['time'],
        style: TextStyle(
          color: ChessEarnTheme.themeColors['text-muted'],
          fontSize: 12,
        ),
      ),
      trailing: Text(
        activity['rating'],
        style: TextStyle(
          color: resultColor,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}