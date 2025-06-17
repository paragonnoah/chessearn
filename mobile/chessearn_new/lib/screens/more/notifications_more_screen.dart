import 'package:flutter/material.dart';
import 'package:chessearn_new/services/api_service.dart';
import 'package:chessearn_new/theme.dart';

class NotificationsMoreScreen extends StatefulWidget {
  final String? userId;
  const NotificationsMoreScreen({super.key, required this.userId});

  @override
  State<NotificationsMoreScreen> createState() => _NotificationsMoreScreenState();
}

class _NotificationsMoreScreenState extends State<NotificationsMoreScreen> with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;
  List<Map<String, dynamic>> _notifications = [];
  bool _isLoading = true;

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
    _fetchNotifications();
    _fadeController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  Future<void> _fetchNotifications() async {
    setState(() => _isLoading = true);
    try {
      final notifications = await ApiService.getNotifications(widget.userId);
      setState(() {
        _notifications = notifications;
        _isLoading = false;
      });
    } catch (e) {
      print('Failed to fetch notifications: $e');
      setState(() {
        _notifications = [];
        _isLoading = false;
      });
    }
  }

  Future<void> _markAsRead(String notificationId) async {
    try {
      await ApiService.markNotificationRead(widget.userId, notificationId);
      setState(() {
        _notifications = _notifications.map((n) {
          if (n['id'] == notificationId) {
            return {...n, 'isRead': true};
          }
          return n;
        }).toList();
      });
    } catch (e) {
      print('Failed to mark notification as read: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ChessEarnTheme.getColor('brand-dark'),
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: CustomScrollView(
            slivers: [
              SliverAppBar(
                backgroundColor: Colors.transparent,
                elevation: 0,
                leading: IconButton(
                  icon: Icon(Icons.arrow_back, color: ChessEarnTheme.getColor('text-light')),
                  onPressed: () => Navigator.pop(context),
                ),
                title: Text(
                  'Notifications',
                  style: ChessEarnTheme.themeData.textTheme.headlineSmall?.copyWith(
                    color: ChessEarnTheme.getColor('text-light'),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              if (_isLoading)
                SliverToBoxAdapter(
                  child: Container(
                    height: MediaQuery.of(context).size.height - 100,
                    alignment: Alignment.center,
                    child: CircularProgressIndicator(
                      color: ChessEarnTheme.getColor('brand-accent'),
                    ),
                  ),
                )
              else if (_notifications.isEmpty)
                SliverToBoxAdapter(
                  child: Container(
                    height: MediaQuery.of(context).size.height - 100,
                    alignment: Alignment.center,
                    child: Text(
                      'No notifications yet',
                      style: ChessEarnTheme.themeData.textTheme.bodyLarge?.copyWith(
                        color: ChessEarnTheme.getColor('text-muted'),
                      ),
                    ),
                  ),
                )
              else
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final notification = _notifications[index];
                      return _buildNotificationItem(
                        notification['title'],
                        notification['message'],
                        DateTime.parse(notification['time']),
                        notification['id'],
                        notification['isRead'] ?? true,
                      );
                    },
                    childCount: _notifications.length,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNotificationItem(String title, String message, DateTime time, String id, bool isRead) {
    return GestureDetector(
      onTap: () => _markAsRead(id),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: ChessEarnTheme.getColor('surface-dark'),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white.withOpacity(0.1)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: ChessEarnTheme.getColor('brand-accent').withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.notifications,
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
                    title,
                    style: ChessEarnTheme.themeData.textTheme.titleMedium?.copyWith(
                      color: ChessEarnTheme.getColor('text-light'),
                      fontWeight: isRead ? FontWeight.normal : FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    message,
                    style: ChessEarnTheme.themeData.textTheme.bodyMedium?.copyWith(
                      color: ChessEarnTheme.getColor('text-muted'),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _formatTime(time),
                    style: ChessEarnTheme.themeData.textTheme.bodySmall?.copyWith(
                      color: ChessEarnTheme.getColor('text-muted'),
                      fontSize: 10,
                    ),
                  ),
                ],
              ),
            ),
            if (!isRead)
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: ChessEarnTheme.getColor('brand-accent'),
                  shape: BoxShape.circle,
                ),
              ),
          ],
        ),
      ),
    );
  }

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final difference = now.difference(time);
    if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }
}