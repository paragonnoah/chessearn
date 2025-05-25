import 'package:flutter/material.dart';
import 'package:chessearn_new/screens/game_screen.dart';
import 'package:chessearn_new/theme.dart';

class TimeControlScreen extends StatefulWidget {
  final String? userId;

  const TimeControlScreen({super.key, required this.userId});

  @override
  _TimeControlScreenState createState() => _TimeControlScreenState();
}

class _TimeControlScreenState extends State<TimeControlScreen> {
  String _selectedTimeControl = '15|10'; // Default to 15|10

  void _startGame() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => GameScreen(
          userId: widget.userId,
          initialPlayMode: 'online', // Default to online mode
          timeControl: _selectedTimeControl,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ChessEarnTheme.themeColors['background-dark'],
      appBar: AppBar(
        backgroundColor: ChessEarnTheme.themeColors['brand-dark'],
        title: Text(
          'New Game',
          style: TextStyle(
            color: ChessEarnTheme.themeColors['text-light'],
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: ChessEarnTheme.themeColors['text-light']),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Chess piece icon (placeholder)
            Center(
              child: Icon(
                Icons.handshake, // Replace with a chess piece asset if available
                size: 60,
                color: ChessEarnTheme.themeColors['text-light'],
              ),
            ),
            const SizedBox(height: 20),
            // Time control selection
            Card(
              color: ChessEarnTheme.themeColors['surface-dark'],
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.timer,
                          color: ChessEarnTheme.themeColors['brand-accent'],
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          _selectedTimeControl.replaceAll('|', ' | '),
                          style: TextStyle(
                            color: ChessEarnTheme.themeColors['text-light'],
                            fontSize: 18,
                          ),
                        ),
                      ],
                    ),
                    IconButton(
                      icon: Icon(
                        Icons.arrow_drop_down,
                        color: ChessEarnTheme.themeColors['text-muted'],
                      ),
                      onPressed: () => _showTimeControlDialog(context),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            // Start Game button
            ElevatedButton(
              onPressed: _startGame,
              style: ElevatedButton.styleFrom(
                backgroundColor: ChessEarnTheme.themeColors['brand-accent'],
                padding: const EdgeInsets.symmetric(vertical: 15),
              ),
              child: Text(
                'Start Game',
                style: TextStyle(
                  color: ChessEarnTheme.themeColors['text-light'],
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 20),
            // Game mode options
            _buildOptionCard(
              icon: Icons.emoji_events,
              title: 'Tournaments',
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Tournaments feature coming soon!')),
                );
              },
            ),
            _buildOptionCard(
              icon: Icons.handshake,
              title: 'Play a Friend',
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Play a Friend feature coming soon!')),
                );
              },
            ),
            _buildOptionCard(
              icon: Icons.computer,
              title: 'Play a Bot',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => GameScreen(
                      userId: widget.userId,
                      initialPlayMode: 'computer',
                      timeControl: _selectedTimeControl,
                    ),
                  ),
                );
              },
            ),
            _buildOptionCard(
              icon: Icons.person,
              title: 'Play Coach',
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Play Coach feature coming soon!')),
                );
              },
            ),
            ExpansionTile(
              title: Text(
                'More',
                style: TextStyle(
                  color: ChessEarnTheme.themeColors['text-light'],
                  fontSize: 18,
                ),
              ),
              collapsedBackgroundColor: ChessEarnTheme.themeColors['surface-dark'],
              backgroundColor: ChessEarnTheme.themeColors['surface-dark'],
              children: [
                _buildOptionCard(
                  icon: Icons.settings,
                  title: 'Custom Game',
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Custom Game feature coming soon!')),
                    );
                  },
                ),
                _buildOptionCard(
                  icon: Icons.group,
                  title: 'Play in Person',
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Play in Person feature coming soon!')),
                    );
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOptionCard({required IconData icon, required String title, required VoidCallback onTap}) {
    return Card(
      color: ChessEarnTheme.themeColors['surface-dark'],
      child: ListTile(
        leading: Icon(
          icon,
          color: ChessEarnTheme.themeColors['brand-accent'],
          size: 30,
        ),
        title: Text(
          title,
          style: TextStyle(
            color: ChessEarnTheme.themeColors['text-light'],
            fontSize: 18,
          ),
        ),
        onTap: onTap,
      ),
    );
  }

  void _showTimeControlDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Select Time Control', style: TextStyle(color: ChessEarnTheme.themeColors['text-light'])),
          backgroundColor: ChessEarnTheme.themeColors['surface-dark'],
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildTimeControlSection(
                  title: 'Bullet',
                  options: [
                    {'label': '1 min', 'value': '1|0'},
                    {'label': '1|1', 'value': '1|1'},
                    {'label': '2|1', 'value': '2|1'},
                  ],
                ),
                _buildTimeControlSection(
                  title: 'Blitz',
                  options: [
                    {'label': '3 min', 'value': '3|0'},
                    {'label': '3|2', 'value': '3|2'},
                    {'label': '5 min', 'value': '5|0'},
                  ],
                ),
                _buildTimeControlSection(
                  title: 'Rapid',
                  options: [
                    {'label': '10 min', 'value': '10|0'},
                    {'label': '15|10', 'value': '15|10'},
                    {'label': '30 min', 'value': '30|0'},
                  ],
                ),
                _buildTimeControlSection(
                  title: 'Daily',
                  options: [
                    {'label': '1 day', 'value': '1d'},
                    {'label': '3 days', 'value': '3d'},
                    {'label': '7 days', 'value': '7d'},
                  ],
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Close', style: TextStyle(color: ChessEarnTheme.themeColors['brand-accent'])),
            ),
          ],
        );
      },
    );
  }

  Widget _buildTimeControlSection({
    required String title,
    required List<Map<String, String>> options,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              color: ChessEarnTheme.themeColors['text-light'],
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8.0,
            runSpacing: 8.0,
            children: options.map((option) {
              return ElevatedButton(
                onPressed: () {
                  setState(() {
                    _selectedTimeControl = option['value']!;
                  });
                  Navigator.pop(context); // Close the dialog after selection
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: _selectedTimeControl == option['value']
                      ? ChessEarnTheme.themeColors['brand-accent']
                      : ChessEarnTheme.themeColors['surface-dark'],
                  foregroundColor: _selectedTimeControl == option['value']
                      ? Colors.white
                      : ChessEarnTheme.themeColors['text-light'],
                  side: BorderSide(color: ChessEarnTheme.themeColors['text-light']!),
                ),
                child: Text(option['label']!),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}