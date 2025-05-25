import 'package:flutter/material.dart';
import 'package:chessearn_new/screens/game_screen.dart';
import 'package:chessearn_new/screens/puzzle_screen.dart';
import 'package:chessearn_new/screens/friend_search_screen.dart';
import 'package:chessearn_new/screens/learn_screen.dart';
import 'package:chessearn_new/screens/watch_screen.dart';
import 'package:chessearn_new/screens/more_screen.dart';
import 'package:chessearn_new/screens/home_screen.dart'; // Import HomeScreen
import 'package:chessearn_new/theme.dart';
import 'time_control_screen.dart';

class MainScreen extends StatefulWidget {
  final String? userId;

  const MainScreen({super.key, required this.userId});

  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  late final List<Widget> _screens;

  @override
  void initState() {
    super.initState();
    _screens = [
      _buildHomeTab(),
      PuzzleScreen(userId: widget.userId),
      LearnScreen(userId: widget.userId),
      WatchScreen(userId: widget.userId),
      MoreScreen(userId: widget.userId),
    ];
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    String tabName = '';
    switch (index) {
      case 0:
        tabName = 'Home';
        break;
      case 1:
        tabName = 'Puzzles';
        break;
      case 2:
        tabName = 'Learn';
        break;
      case 3:
        tabName = 'Watch';
        break;
      case 4:
        tabName = 'More';
        break;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Navigated to $tabName tab')),
    );
  }

  Widget _buildHomeTab() {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle('Recommended Match'),
            _buildMatchCard(
              title: 'New Friend',
              subtitle: 'mohamed-omar-saad (400) vs: 0W/0D/0L',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => GameScreen(userId: widget.userId, initialPlayMode: 'computer'),
                  ),
                );
              },
            ),
            const SizedBox(height: 16),
            _buildSectionTitle('Play Options'),
            _buildOptionCard(
              title: 'Play Online',
              subtitle: '15 | 10 vs Random #6',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => GameScreen(userId: widget.userId, initialPlayMode: 'online'),
                  ),
                );
              },
            ),
            _buildOptionCard(
              title: 'Play vs Computer',
              subtitle: 'Challenge AI with difficulty',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => GameScreen(userId: widget.userId, initialPlayMode: 'computer'),
                  ),
                );
              },
            ),
            const SizedBox(height: 16),
            _buildSectionTitle('Puzzles'),
            _buildOptionCard(
              title: 'Solve Puzzles',
              subtitle: 'Start Your Journey! 0/2',
              onTap: () {
                setState(() {
                  _selectedIndex = 1;
                });
              },
            ),
            const SizedBox(height: 16),
            _buildSectionTitle('Friends'),
            Row(
              children: [
                Expanded(
                  child: _buildFriendCard(
                    name: '4tonni',
                    flag: '🇩🇪',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => FriendSearchScreen(userId: widget.userId),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _buildFriendCard(
                    name: 'masharia47th',
                    flag: '🇰🇪',
                    onTap: () {},
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildSectionTitle('Earn Points'),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                'Win games or solve puzzles to earn points! Current: 0',
                style: TextStyle(color: ChessEarnTheme.themeColors['text-light'], fontSize: 16),
              ),
            ),
            const SizedBox(height: 20),
            Center(
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => TimeControlScreen(userId: widget.userId),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: ChessEarnTheme.themeColors['brand-accent'],
                  padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                ),
                child: const Text('Play', style: TextStyle(fontSize: 18)),
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
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16.0),
              color: ChessEarnTheme.themeColors['brand-dark'],
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'ChessEarn',
                    style: TextStyle(
                      color: ChessEarnTheme.themeColors['text-light'],
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            if (widget.userId == null)
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: GestureDetector(
                  onTap: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => const HomeScreen()),
                    );
                  },
                  child: Text(
                    'Playing as Guest - Sign up to earn rewards!',
                    style: TextStyle(
                      color: ChessEarnTheme.themeColors['brand-accent'],
                      fontSize: 16,
                      decoration: TextDecoration.underline,
                      decorationColor: ChessEarnTheme.themeColors['brand-accent'],
                    ),
                  ),
                ),
              ),
            Expanded(
              child: _screens[_selectedIndex],
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.extension),
            label: 'Puzzles',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.school),
            label: 'Learn',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.tv),
            label: 'Watch',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.more_horiz),
            label: 'More',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: ChessEarnTheme.themeColors['brand-accent'],
        unselectedItemColor: ChessEarnTheme.themeColors['text-muted'],
        backgroundColor: ChessEarnTheme.themeColors['surface-dark'],
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed,
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Text(
        title,
        style: TextStyle(
          color: ChessEarnTheme.themeColors['text-light'],
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildMatchCard({required String title, required String subtitle, required VoidCallback onTap}) {
    return Card(
      color: ChessEarnTheme.themeColors['surface-dark'],
      child: ListTile(
        leading: Image.asset('assets/images/chess_board.png', width: 50, height: 50),
        title: Text(title, style: TextStyle(color: ChessEarnTheme.themeColors['text-light'])),
        subtitle: Text(subtitle, style: TextStyle(color: ChessEarnTheme.themeColors['text-muted'])),
        onTap: onTap,
      ),
    );
  }

  Widget _buildOptionCard({required String title, required String subtitle, required VoidCallback onTap}) {
    return Card(
      color: ChessEarnTheme.themeColors['surface-dark'],
      child: ListTile(
        leading: Image.asset('assets/images/chess_board.png', width: 50, height: 50),
        title: Text(title, style: TextStyle(color: ChessEarnTheme.themeColors['text-light'])),
        subtitle: Text(subtitle, style: TextStyle(color: ChessEarnTheme.themeColors['text-muted'])),
        onTap: () {
          if (title == 'Solve Puzzles') {
            setState(() {
              _selectedIndex = 1;
            });
          } else {
            onTap();
          }
        },
      ),
    );
  }

  Widget _buildFriendCard({required String name, required String flag, required VoidCallback onTap}) {
    return Card(
      color: ChessEarnTheme.themeColors['surface-dark'],
      child: ListTile(
        leading: CircleAvatar(child: Text(flag)),
        title: Text(name, style: TextStyle(color: ChessEarnTheme.themeColors['text-light'])),
        onTap: onTap,
      ),
    );
  }
}