import 'package:flutter/material.dart';
import 'package:chessearn_new/theme.dart';

class SettingsMoreScreen extends StatefulWidget {
  const SettingsMoreScreen({super.key});

  @override
  State<SettingsMoreScreen> createState() => _SettingsMoreScreenState();
}

class _SettingsMoreScreenState extends State<SettingsMoreScreen> with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;
  bool isDarkMode = true;
  bool notificationsEnabled = true;

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
                    'Settings',
                    style: TextStyle(color: ChessEarnTheme.themeColors['text-light']),
                  ),
                ),
                SliverList(
                  delegate: SliverChildListDelegate([
                    Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        children: [
                          _buildSettingItem(
                            'Dark Mode',
                            Icons.brightness_6,
                            Switch(
                              value: isDarkMode,
                              onChanged: (value) {
                                setState(() {
                                  isDarkMode = value;
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text('Theme change coming soon!')),
                                  );
                                });
                              },
                              activeColor: ChessEarnTheme.themeColors['brand-accent'],
                            ),
                          ),
                          _buildSettingItem(
                            'Notifications',
                            Icons.notifications,
                            Switch(
                              value: notificationsEnabled,
                              onChanged: (value) {
                                setState(() {
                                  notificationsEnabled = value;
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text('Notification settings saved!')),
                                  );
                                });
                              },
                              activeColor: ChessEarnTheme.themeColors['brand-accent'],
                            ),
                          ),
                          _buildSettingItem(
                            'Sound Effects',
                            Icons.volume_up,
                            const SizedBox(),
                            onTap: () => ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Sound settings coming soon!')),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ]),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSettingItem(String title, IconData icon, Widget trailing, {VoidCallback? onTap}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Row(
        children: [
          Icon(icon, color: ChessEarnTheme.themeColors['brand-accent']),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              title,
              style: TextStyle(color: ChessEarnTheme.themeColors['text-light']),
            ),
          ),
          trailing,
        ],
      ),
    );
  }
}