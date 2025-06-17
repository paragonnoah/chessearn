import 'package:flutter/material.dart';
import 'package:confetti/confetti.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:chessearn_new/screens/game_screen.dart';
import 'package:chessearn_new/screens/puzzle_screen.dart';
import 'package:chessearn_new/screens/friend_search_screen.dart';
import 'package:chessearn_new/screens/learn_screen.dart';
import 'package:chessearn_new/screens/watch_screen.dart';
import 'package:chessearn_new/screens/more_screen.dart';
import 'package:chessearn_new/screens/wallet_screen.dart';
import 'package:chessearn_new/screens/home_screen.dart';
import 'package:chessearn_new/screens/more/notifications_more_screen.dart';
import 'package:chessearn_new/services/api_service.dart';
import 'package:chessearn_new/theme.dart';
import 'time_control_screen.dart';
import 'package:chessearn_new/screens/open_game_screen.dart';
import 'package:chessearn_new/screens/join_game_screen.dart';

class MainScreen extends StatefulWidget {
  final String? userId;
  const MainScreen({super.key, required this.userId});
  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> with SingleTickerProviderStateMixin {
  int _selectedIndex = 0;
  late final List<Widget> _screens;
  late AnimationController _animationController;
  late ConfettiController _confettiController;
  double _walletBalance = 0.0;
  int _playStreak = 0;
  List<Map<String, dynamic>> _friends = [];
  bool _isLoadingFriends = true;
  bool _isLoadingBalance = true;
  bool _hasNotifications = false; // Dynamic notification state

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    )..forward();
    _confettiController = ConfettiController(duration: const Duration(seconds: 3));
    _screens = [
      _buildHomeTab(),
      PuzzleScreen(userId: widget.userId),
      LearnScreen(userId: widget.userId),
      WatchScreen(userId: widget.userId),
      MoreScreen(userId: widget.userId),
    ];
    _fetchWalletBalance();
    _fetchFriends();
    _fetchNotifications();
    _loadPlayStreak();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _confettiController.dispose();
    super.dispose();
  }

  Future<void> _fetchWalletBalance() async {
    if (widget.userId == null) {
      setState(() {
        _isLoadingBalance = false;
      });
      return;
    }
    try {
      final walletData = await ApiService.getWalletBalance(widget.userId!);
      setState(() {
        _walletBalance = walletData['wallet_balance'] ?? 0.0;
        _isLoadingBalance = false;
      });
    } catch (e) {
      print('Failed to fetch wallet balance: $e');
      setState(() {
        _isLoadingBalance = false;
      });
    }
  }

  Future<void> _fetchFriends() async {
    if (widget.userId == null) {
      setState(() {
        _isLoadingFriends = false;
      });
      return;
    }
    setState(() => _isLoadingFriends = true);
    try {
      final friends = await ApiService.getFriends(widget.userId);
      setState(() {
        _friends = friends;
        _isLoadingFriends = false;
      });
    } catch (e) {
      print('Failed to fetch friends: $e');
      setState(() {
        _friends = [];
        _isLoadingFriends = false;
      });
    }
  }

  Future<void> _fetchNotifications() async {
    if (widget.userId == null) {
      setState(() {
        _hasNotifications = false;
      });
      return;
    }
    try {
      final notifications = await ApiService.getNotifications(widget.userId);
      setState(() {
        _hasNotifications = notifications.any((n) => !(n['isRead'] ?? true));
      });
    } catch (e) {
      print('Failed to fetch notifications: $e');
      setState(() {
        _hasNotifications = false;
      });
    }
  }

  Future<void> _loadPlayStreak() async {
    final prefs = await SharedPreferences.getInstance();
    final lastPlayDate = prefs.getString('last_play_date');
    final currentDate = DateTime.now().toIso8601String().split('T')[0];
    int streak = prefs.getInt('play_streak') ?? 0;

    if (lastPlayDate == null) {
      streak = 1;
    } else {
      final lastDate = DateTime.parse(lastPlayDate);
      final difference = DateTime.now().difference(lastDate).inDays;
      if (difference == 1) {
        streak++;
      } else if (difference > 1) {
        streak = 1;
      }
    }

    await prefs.setString('last_play_date', currentDate);
    await prefs.setInt('play_streak', streak);
    setState(() {
      _playStreak = streak;
    });

    if (streak % 5 == 0) {
      _confettiController.play();
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    String tabName = ['Home', 'Puzzles', 'Learn', 'Watch', 'More'][index];
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Navigated to $tabName tab'),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        duration: const Duration(milliseconds: 1500),
      ),
    );
  }

  void _showQuickActions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return Container(
          decoration: BoxDecoration(
            color: ChessEarnTheme.getColor('surface-card'),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(25)),
          ),
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: ChessEarnTheme.getColor('text-muted'),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Quick Actions',
                style: ChessEarnTheme.themeData.textTheme.headlineSmall?.copyWith(
                  color: ChessEarnTheme.getColor('text-light'),
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              _buildQuickActionTile(
                icon: Icons.person_add,
                title: 'Challenge Friend',
                subtitle: 'Invite a friend to play',
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => FriendSearchScreen(userId: widget.userId),
                    ),
                  );
                },
              ),
              _buildQuickActionTile(
                icon: Icons.flash_on,
                title: 'Quick Match',
                subtitle: 'Find an opponent instantly',
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => GameScreen(
                        userId: widget.userId,
                        initialPlayMode: 'online',
                        gameId: 'quick_match_id', // Placeholder gameId
                      ),
                    ),
                  );
                },
              ),
              _buildQuickActionTile(
                icon: Icons.emoji_events,
                title: 'Join Tournament',
                subtitle: 'Compete with others',
                onTap: () {
                  Navigator.pop(context);
                  // Add tournament navigation
                },
              ),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }

  Widget _buildQuickActionTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: ChessEarnTheme.getColor('brand-accent').withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: ChessEarnTheme.getColor('brand-accent'), size: 24),
        ),
        title: Text(
          title,
          style: ChessEarnTheme.themeData.textTheme.titleMedium?.copyWith(
            color: ChessEarnTheme.getColor('text-light'),
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: ChessEarnTheme.themeData.textTheme.bodyMedium?.copyWith(
            color: ChessEarnTheme.getColor('text-muted'),
          ),
        ),
        trailing: Icon(
          Icons.arrow_forward_ios,
          color: ChessEarnTheme.getColor('text-muted'),
          size: 16,
        ),
        onTap: onTap,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  Widget _buildHomeTab() {
    return Stack(
      children: [
        CustomScrollView(
          slivers: [
            SliverAppBar(
              pinned: true,
              expandedHeight: 280,
              backgroundColor: ChessEarnTheme.getColor('brand-dark'),
              flexibleSpace: FlexibleSpaceBar(
                background: Stack(
                  fit: StackFit.expand,
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            ChessEarnTheme.getColor('brand-dark'),
                            ChessEarnTheme.getColor('brand-accent').withOpacity(0.8),
                          ],
                        ),
                      ),
                    ),
                    SafeArea(
                      child: Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'ChessEarn',
                                      style: ChessEarnTheme.themeData.textTheme.headlineLarge?.copyWith(
                                        color: ChessEarnTheme.getColor('text-light'),
                                        fontSize: 36,
                                        fontWeight: FontWeight.bold,
                                        letterSpacing: -1,
                                      ),
                                    ),
                                    Text(
                                      'Play • Learn • Earn',
                                      style: ChessEarnTheme.themeData.textTheme.bodyLarge?.copyWith(
                                        color: ChessEarnTheme.getColor('text-light').withOpacity(0.8),
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                                GestureDetector(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => NotificationsMoreScreen(userId: widget.userId),
                                      ),
                                    ).then((_) => _fetchNotifications()); // Refresh notifications
                                  },
                                  child: Stack(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(12),
                                        decoration: BoxDecoration(
                                          color: Colors.white.withOpacity(0.1),
                                          borderRadius: BorderRadius.circular(12),
                                          border: Border.all(
                                            color: Colors.white.withOpacity(0.2),
                                            width: 1,
                                          ),
                                        ),
                                        child: Icon(
                                          Icons.notifications_outlined,
                                          color: ChessEarnTheme.getColor('text-light'),
                                          size: 24,
                                        ),
                                      ),
                                      if (_hasNotifications)
                                        Positioned(
                                          top: 8,
                                          right: 8,
                                          child: Container(
                                            width: 8,
                                            height: 8,
                                            decoration: const BoxDecoration(
                                              color: Colors.red,
                                              shape: BoxShape.circle,
                                            ),
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            if (widget.userId == null)
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                decoration: BoxDecoration(
                                  color: Colors.orange.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(color: Colors.orange.withOpacity(0.3)),
                                ),
                                child: GestureDetector(
                                  onTap: () {
                                    Navigator.pushReplacement(
                                      context,
                                      MaterialPageRoute(builder: (context) => const HomeScreen()),
                                    );
                                  },
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(Icons.person_outline, color: Colors.orange, size: 16),
                                      const SizedBox(width: 4),
                                      Text(
                                        'Playing as Guest - Sign up to earn!',
                                        style: ChessEarnTheme.themeData.textTheme.bodySmall?.copyWith(
                                          color: Colors.orange,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            const Spacer(),
                            Hero(
                              tag: 'wallet_balance',
                              child: GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => WalletScreen(userId: widget.userId),
                                    ),
                                  );
                                },
                                child: Container(
                                  padding: const EdgeInsets.all(20),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.15),
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(color: Colors.white.withOpacity(0.2), width: 1),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.1),
                                        blurRadius: 20,
                                        offset: const Offset(0, 10),
                                      ),
                                    ],
                                  ),
                                  child: Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(12),
                                        decoration: BoxDecoration(
                                          color: Colors.white.withOpacity(0.2),
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        child: Icon(
                                          Icons.account_balance_wallet_outlined,
                                          color: ChessEarnTheme.getColor('text-light'),
                                          size: 24,
                                        ),
                                      ),
                                      const SizedBox(width: 16),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              'Wallet Balance',
                                              style: ChessEarnTheme.themeData.textTheme.bodyMedium?.copyWith(
                                                color: ChessEarnTheme.getColor('text-light').withOpacity(0.8),
                                              ),
                                            ),
                                            _isLoadingBalance
                                                ? SizedBox(
                                                    width: 20,
                                                    height: 20,
                                                    child: CircularProgressIndicator(
                                                      strokeWidth: 2,
                                                      color: ChessEarnTheme.getColor('text-light'),
                                                    ),
                                                  )
                                                : Text(
                                                    '${_walletBalance.toStringAsFixed(2)} Credits',
                                                    style: ChessEarnTheme.themeData.textTheme.titleLarge?.copyWith(
                                                      color: ChessEarnTheme.getColor('text-light'),
                                                      fontWeight: FontWeight.bold,
                                                    ),
                                                  ),
                                          ],
                                        ),
                                      ),
                                      Icon(
                                        Icons.arrow_forward_ios,
                                        // ignore: deprecated_member_use
                                        color: ChessEarnTheme.getColor('text-light').withOpacity(0.6),
                                        size: 16,
                                      ),
                                    ],
                                  ),
                                ),
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
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildStatsRow(),
                    const SizedBox(height: 24),
                    _buildGameActionsGrid(),
                    const SizedBox(height: 24),
                    _buildSectionTitle('Live Games'),
                    _buildLiveGamePreview(),
                    const SizedBox(height: 24),
                    _buildSectionTitle('Daily Challenge'),
                    _buildDailyPuzzleCard(),
                    const SizedBox(height: 24),
                    _buildSectionTitle('Friends Online'),
                    _buildFriendsList(),
                    const SizedBox(height: 100),
                  ],
                ),
              ),
            ),
          ],
        ),
        Align(
          alignment: Alignment.topCenter,
          child: ConfettiWidget(
            confettiController: _confettiController,
            blastDirectionality: BlastDirectionality.explosive,
            emissionFrequency: 0.05,
            numberOfParticles: 30,
            maxBlastForce: 100,
            minBlastForce: 80,
            colors: const [Colors.amber, Colors.orange, Colors.red, Colors.pink],
          ),
        ),
      ],
    );
  }

  Widget _buildStatsRow() {
    return Row(
      children: [
        Expanded(child: _buildStatCard('Play Streak', '$_playStreak Days', Icons.local_fire_department, Colors.orange)),
        const SizedBox(width: 12),
        Expanded(child: _buildStatCard('Rating', '1,245', Icons.trending_up, Colors.green)),
        const SizedBox(width: 12),
        Expanded(child: _buildStatCard('Games', '127', Icons.sports_esports, Colors.blue)),
      ],
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return SlideTransition(
      position: Tween<Offset>(begin: const Offset(0, 0.5), end: Offset.zero).animate(
        CurvedAnimation(parent: _animationController, curve: Curves.easeOutBack),
      ),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: ChessEarnTheme.getColor('surface-dark'),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 8),
            Text(
              value,
              style: ChessEarnTheme.themeData.textTheme.titleMedium?.copyWith(
                color: ChessEarnTheme.getColor('text-light'),
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              title,
              style: ChessEarnTheme.themeData.textTheme.bodySmall?.copyWith(
                color: ChessEarnTheme.getColor('text-muted'),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGameActionsGrid() {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 1.2,
      children: [
        _buildActionCard(
          'Open Game',
          'Create a new game',
          Icons.add_circle_outline,
          ChessEarnTheme.getColor('brand-accent'),
          () => Navigator.push(context, MaterialPageRoute(builder: (context) => OpenGamesScreen(userId: widget.userId))),
        ),
        _buildActionCard(
          'Join Game',
          'Join an existing game',
          Icons.group_add,
          Colors.purple,
          () => Navigator.push(context, MaterialPageRoute(builder: (context) => JoinGameScreen(userId: widget.userId))),
        ),
        _buildActionCard(
          'Quick Play',
          'Start a game now',
          Icons.play_circle_filled,
          ChessEarnTheme.getColor('brand-accent'),
          () => Navigator.push(context, MaterialPageRoute(builder: (context) => TimeControlScreen(userId: widget.userId))),
        ),
        _buildActionCard(
          'Puzzles',
          'Solve challenges',
          Icons.extension,
          Colors.purple,
          () => setState(() => _selectedIndex = 1),
        ),
        _buildActionCard(
          'Learn',
          'Improve skills',
          Icons.school,
          Colors.green,
          () => setState(() => _selectedIndex = 2),
        ),
        _buildActionCard(
          'Watch',
          'Live games',
          Icons.tv,
          Colors.red,
          () => setState(() => _selectedIndex = 3),
        ),
      ],
    );
  }

  Widget _buildActionCard(String title, String subtitle, IconData icon, Color color, VoidCallback onTap) {
    return FadeTransition(
      opacity: _animationController,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: ChessEarnTheme.getColor('surface-dark'),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: color.withOpacity(0.2), width: 1),
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 28),
              ),
              const SizedBox(height: 12),
              Text(
                title,
                style: ChessEarnTheme.themeData.textTheme.titleMedium?.copyWith(
                  color: ChessEarnTheme.getColor('text-light'),
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                subtitle,
                style: ChessEarnTheme.themeData.textTheme.bodySmall?.copyWith(
                  color: ChessEarnTheme.getColor('text-muted'),
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 20,
            decoration: BoxDecoration(
              color: ChessEarnTheme.getColor('brand-accent'),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 12),
          Text(
            title,
            style: ChessEarnTheme.themeData.textTheme.headlineSmall?.copyWith(
              color: ChessEarnTheme.getColor('text-light'),
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLiveGamePreview() {
    return FadeTransition(
      opacity: _animationController,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: ChessEarnTheme.getColor('surface-dark'),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 15,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.circle, color: Colors.red, size: 12),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Magnus vs Hikaru',
                    style: ChessEarnTheme.themeData.textTheme.titleMedium?.copyWith(
                      color: ChessEarnTheme.getColor('text-light'),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Blitz • 3+2 • Move 12 • 1.2k watching',
                    style: ChessEarnTheme.themeData.textTheme.bodyMedium?.copyWith(
                      color: ChessEarnTheme.getColor('text-muted'),
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: ChessEarnTheme.getColor('brand-accent').withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.play_arrow,
                color: ChessEarnTheme.getColor('brand-accent'),
                size: 20,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDailyPuzzleCard() {
    return FadeTransition(
      opacity: _animationController,
      child: GestureDetector(
        onTap: () {
          setState(() {
            _selectedIndex = 1;
          });
        },
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                ChessEarnTheme.getColor('brand-accent'),
                ChessEarnTheme.getColor('brand-accent').withOpacity(0.7),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: ChessEarnTheme.getColor('brand-accent').withOpacity(0.3),
                blurRadius: 15,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(Icons.extension, color: Colors.white, size: 32),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Daily Puzzle',
                      style: ChessEarnTheme.themeData.textTheme.titleLarge?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Solve today\'s challenge and earn rewards!',
                      style: ChessEarnTheme.themeData.textTheme.bodyMedium?.copyWith(
                        color: Colors.white.withOpacity(0.9),
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.arrow_forward,
                color: Colors.white,
                size: 24,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFriendsList() {
    if (_isLoadingFriends) {
      return Container(
        height: 120,
        alignment: Alignment.center,
        child: CircularProgressIndicator(
          color: ChessEarnTheme.getColor('brand-accent'),
        ),
      );
    }

    if (_friends.isEmpty) {
      return GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => FriendSearchScreen(userId: widget.userId)),
          );
        },
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: ChessEarnTheme.getColor('surface-dark'),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: ChessEarnTheme.getColor('brand-accent').withOpacity(0.3),
              width: 1,
            ),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: ChessEarnTheme.getColor('brand-accent').withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.person_add,
                  color: ChessEarnTheme.getColor('brand-accent'),
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Add Friends',
                      style: ChessEarnTheme.themeData.textTheme.titleMedium?.copyWith(
                        color: ChessEarnTheme.getColor('text-light'),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'Connect with other players and challenge them!',
                      style: ChessEarnTheme.themeData.textTheme.bodyMedium?.copyWith(
                        color: ChessEarnTheme.getColor('text-muted'),
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                color: ChessEarnTheme.getColor('text-muted'),
                size: 16,
              ),
            ],
          ),
        ),
      );
    }

    return SizedBox(
      height: 120,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _friends.length,
        itemBuilder: (context, index) {
          final friend = _friends[index];
          final countryFlag = _getCountryFlag(friend['country_code'] ?? '');
          final isOnline = friend['status'] == 'online';

          return Padding(
            padding: const EdgeInsets.only(right: 12.0),
            child: GestureDetector(
              onTap: widget.userId == null
                  ? null
                  : () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => GameScreen(
                            userId: widget.userId,
                            initialPlayMode: 'online',
                            timeControl: '10|0',
                            opponentId: friend['id'],
                            gameId: 'friend_challenge_id_${friend['id']}', // Placeholder gameId
                          ),
                        ),
                      );
                    },
              child: FadeTransition(
                opacity: _animationController,
                child: Container(
                  width: 90,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: ChessEarnTheme.getColor('surface-dark'),
                    borderRadius: BorderRadius.circular(16),
                    border: isOnline
                        ? Border.all(color: Colors.green.withOpacity(0.3), width: 2)
                        : null,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Stack(
                        children: [
                          Container(
                            width: 50,
                            height: 50,
                            decoration: BoxDecoration(
                              // ignore: deprecated_member_use
                              color: ChessEarnTheme.getColor('brand-accent').withOpacity(0.1),
                              shape: BoxShape.circle,
                            ),
                            child: Center(
                              child: Text(
                                countryFlag,
                                style: const TextStyle(fontSize: 24),
                              ),
                            ),
                          ),
                          if (isOnline)
                            Positioned(
                              bottom: 2,
                              right: 2,
                              child: Container(
                                width: 14,
                                height: 14,
                                decoration: BoxDecoration(
                                  color: Colors.green,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: ChessEarnTheme.getColor('surface-dark'),
                                    width: 2,
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        friend['username'] ?? 'Unknown',
                        style: ChessEarnTheme.themeData.textTheme.bodySmall?.copyWith(
                          color: ChessEarnTheme.getColor('text-light'),
                          fontWeight: FontWeight.w500,
                        ),
                        textAlign: TextAlign.center,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (isOnline)
                        Text(
                          'Online',
                          style: ChessEarnTheme.themeData.textTheme.bodySmall?.copyWith(
                            color: Colors.green,
                            fontSize: 10,
                          ),
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

  String _getCountryFlag(String countryCode) {
    if (countryCode.isEmpty || countryCode.length != 2) return '🌍';
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
    return Scaffold(
      body: _screens[_selectedIndex],
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: ChessEarnTheme.getColor('surface-dark'),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 20,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: BottomNavigationBar(
              items: const <BottomNavigationBarItem>[
                BottomNavigationBarItem(
                  icon: Icon(Icons.home_outlined),
                  activeIcon: Icon(Icons.home),
                  label: 'Home',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.extension_outlined),
                  activeIcon: Icon(Icons.extension),
                  label: 'Puzzles',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.school_outlined),
                  activeIcon: Icon(Icons.school),
                  label: 'Learn',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.tv_outlined),
                  activeIcon: Icon(Icons.tv),
                  label: 'Watch',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.more_horiz_outlined),
                  activeIcon: Icon(Icons.more_horiz),
                  label: 'More',
                ),
              ],
              currentIndex: _selectedIndex,
              selectedItemColor: ChessEarnTheme.getColor('brand-accent'),
              unselectedItemColor: ChessEarnTheme.getColor('text-muted'),
              backgroundColor: Colors.transparent,
              onTap: _onItemTapped,
              type: BottomNavigationBarType.fixed,
              selectedLabelStyle: ChessEarnTheme.themeData.textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
              unselectedLabelStyle: ChessEarnTheme.themeData.textTheme.bodySmall,
              elevation: 0,
              selectedFontSize: 12,
              unselectedFontSize: 12,
            ),
          ),
        ),
      ),
      floatingActionButton: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: ChessEarnTheme.getColor('brand-accent').withOpacity(0.3),
              blurRadius: 15,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: FloatingActionButton(
          onPressed: _showQuickActions,
          backgroundColor: ChessEarnTheme.getColor('brand-accent'),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              gradient: LinearGradient(
                colors: [
                  ChessEarnTheme.getColor('brand-accent'),
                  // ignore: deprecated_member_use
                  ChessEarnTheme.getColor('brand-accent').withOpacity(0.8),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Icon(
              Icons.add,
              color: ChessEarnTheme.getColor('text-light'),
              size: 28,
            ),
          ),
        ),
      ),
    );
  }
}