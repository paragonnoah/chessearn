import 'package:flutter/material.dart';
import 'package:chessearn_new/theme.dart';

class NotificationsMoreScreen extends StatefulWidget {
  const NotificationsMoreScreen({super.key});

  @override
  State<NotificationsMoreScreen> createState() => _NotificationsMoreScreenState();
}

class _NotificationsMoreScreenState extends State<NotificationsMoreScreen> with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  final List<Map<String, dynamic>> notifications = [
    {'title': 'Game Win', 'message': 'You won a game against Player123!', 'time': DateTime.now().subtract(Duration(hours: 1))},
    {'title': 'Achievement Unlocked', 'message': 'You earned the "Puzzle Master" badge!', 'time': DateTime.now().subtract(Duration(days: 1))},
    {'title': 'Friend Request', 'message': 'Player456 sent you a friend request.', 'time': DateTime.now().subtract(Duration(days: 2))},
  ];

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
                    'Notifications',
                    style: TextStyle(color: ChessEarnTheme.themeColors['text-light']),
                  ),
                ),
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final notification = notifications[index];
                      return _buildNotificationItem(
                        notification['title'],
                        notification['message'],
                        notification['time'],
                      );
                    },
                    childCount: notifications.length,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNotificationItem(String title, String message, DateTime time) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Row(
        children: [
          Icon(Icons.notifications, color: ChessEarnTheme.themeColors['brand-accent']),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(color: ChessEarnTheme.themeColors['text-light']),
                ),
                Text(
                  message,
                  style: TextStyle(color: ChessEarnTheme.themeColors['text-muted'], fontSize: 12),
                ),
                Text(
                  time.toString().split(' ')[0],
                  style: TextStyle(color: ChessEarnTheme.themeColors['text-muted'], fontSize: 10),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}