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
        builder: (context) => GameScreen(userId: widget.userId, initialPlayMode: 'online', timeControl: _selectedTimeControl),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Time'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        backgroundColor: ChessEarnTheme.themeColors['brand-dark'],
      ),
      body: Container(
        color: ChessEarnTheme.themeColors['surface-dark'],
        child: Column(
          children: [
            _buildTimeControlSection(
              title: 'Bullet',
              icon: Icons.flash_on,
              options: [
                {'label': '1 min', 'value': '1|0'},
                {'label': '1|1', 'value': '1|1'},
                {'label': '2|1', 'value': '2|1'},
              ],
            ),
            _buildTimeControlSection(
              title: 'Blitz',
              icon: Icons.bolt,
              options: [
                {'label': '3 min', 'value': '3|0'},
                {'label': '3|2', 'value': '3|2'},
                {'label': '5 min', 'value': '5|0'},
              ],
            ),
            _buildTimeControlSection(
              title: 'Rapid',
              icon: Icons.timer,
              options: [
                {'label': '10 min', 'value': '10|0'},
                {'label': '15|10', 'value': '15|10'},
                {'label': '30 min', 'value': '30|0'},
              ],
            ),
            _buildTimeControlSection(
              title: 'Daily (Max time per move)',
              icon: Icons.wb_sunny,
              options: [
                {'label': '1 day', 'value': '1d'},
                {'label': '3 days', 'value': '3d'},
                {'label': '7 days', 'value': '7d'},
              ],
            ),
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: Text(
                'More Time Controls ▼',
                style: TextStyle(color: Colors.grey),
              ),
            ),
            const Spacer(),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: ElevatedButton(
                onPressed: _startGame,
                style: ElevatedButton.styleFrom(
                  backgroundColor: ChessEarnTheme.themeColors['brand-accent'],
                  padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                ),
                child: const Text('Start Game', style: TextStyle(fontSize: 18)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimeControlSection({
    required String title,
    required IconData icon,
    required List<Map<String, String>> options,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: ChessEarnTheme.themeColors['brand-accent']),
              const SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(
                  color: ChessEarnTheme.themeColors['text-light'],
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
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