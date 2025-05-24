import 'package:flutter/material.dart';
import 'package:chessearn_new/theme.dart';
import 'package:url_launcher/url_launcher.dart';

class WatchScreen extends StatelessWidget {
  final String? userId;

  WatchScreen({super.key, required this.userId});

  // Dynamic tutorial list with daily rotation
  List<Map<String, String>> _getDailyTutorials() {
    final now = DateTime.now();
    final dayOfWeek = now.weekday; // 1 = Monday, 7 = Sunday
    return [
      {
        'title': 'Chess Openings for Beginners - Italian Game',
        'url': 'https://www.youtube.com/watch?v=OCSbzArwB10',
        'dayHighlight': dayOfWeek == 2 ? 'Today\'s Focus!' : '', // Tuesday
      },
      {
        'title': 'Chess Strategy: How to Win More Games',
        'url': 'https://www.youtube.com/watch?v=6IegDENuxU4',
        'dayHighlight': dayOfWeek == 3 ? 'Today\'s Focus!' : '', // Wednesday
      },
      {
        'title': 'Tactics Training - Chess Puzzles Explained',
        'url': 'https://www.youtube.com/watch?v=1WEyUZ1SpHY',
        'dayHighlight': dayOfWeek == 4 ? 'Today\'s Focus!' : '', // Thursday
      },
      {
        'title': 'Mastering Endgames: Basic Techniques',
        'url': 'https://www.youtube.com/watch?v=Ib8XaRKCAfo',
        'dayHighlight': dayOfWeek == 5 ? 'Today\'s Focus!' : '', // Friday
      },
    ];
  }

  // ChessEarn Streamers with handles
  List<Map<String, String>> _getStreamers() {
    return [
      {
        'name': 'ChessEarn Pro',
        'handle': '@ChessEarnPro',
        'url': 'https://x.com/ChessEarnPro',
      },
      {
        'name': 'EarnMaster',
        'handle': '@EarnMaster',
        'url': 'https://x.com/EarnMaster',
      },
      {
        'name': 'TacticWizard',
        'handle': '@TacticWizard',
        'url': 'https://x.com/TacticWizard',
      },
    ];
  }

  // Dynamic schedule based on current day
  List<Map<String, String>> _getDailySchedule() {
    final now = DateTime.now();
    final dayName = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'][now.weekday - 1];
    final dayDate = '${now.day} ${['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'][now.month - 1]}';

    return [
      {
        'time': '19:00 - 21:00',
        'event': 'ChessEarn Blitz Battle',
        'highlight': now.weekday == 6 ? 'Live Now!' : '', // Saturday
      },
      {
        'time': '22:00 - 00:00',
        'event': 'Earned Tactics Challenge',
        'highlight': now.weekday == 7 ? 'Live Now!' : '', // Sunday
      },
    ];
  }

  Future<void> _launchURL(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  @override
  Widget build(BuildContext context) {
    final tutorials = _getDailyTutorials();
    final streamers = _getStreamers();
    final schedule = _getDailySchedule();
    final now = DateTime.now();
    final dayName = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'][now.weekday - 1];
    final dayDate = '${now.day} ${['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'][now.month - 1]}';

    return Container(
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
      child: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Watch with ChessEarn',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  shadows: [
                    Shadow(
                      color: Colors.black45,
                      offset: Offset(2, 2),
                      blurRadius: 4,
                    ),
                  ],
                ),
              ),
              GestureDetector(
                onTap: () => _launchURL('https://x.com/ChessEarnApp'),
                child: const Text(
                  '@ChessEarnApp',
                  style: TextStyle(
                    color: Colors.lightBlueAccent,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          // Featured Challenge Banner
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Colors.purple, Colors.blue],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(15),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black26,
                  offset: Offset(0, 4),
                  blurRadius: 8,
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Expanded(
                  child: Text(
                    'Join the ChessEarn Weekly Challenge!\nEarn Rewards Today!',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Challenge coming soon!')),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text('Play Now'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          // Tutorials Section
          const Text(
            'Daily Tutorials',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),
          ...tutorials.map((tutorial) => Card(
                elevation: 4,
                color: ChessEarnTheme.themeColors['surface-light']!.withOpacity(0.5),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                child: ListTile(
                  leading: const Icon(Icons.play_circle_filled, color: Colors.orange),
                  title: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          tutorial['title']!,
                          style: TextStyle(color: ChessEarnTheme.themeColors['text-light']),
                        ),
                      ),
                      if (tutorial['dayHighlight']!.isNotEmpty)
                        Text(
                          tutorial['dayHighlight']!,
                          style: const TextStyle(color: Colors.yellow, fontWeight: FontWeight.bold),
                        ),
                    ],
                  ),
                  onTap: () => _launchURL(tutorial['url']!),
                ),
              )),
          const SizedBox(height: 20),
          // Streamers Section with Handles
          const Text(
            'ChessEarn Streamers',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),
          ...streamers.map((streamer) => Card(
                elevation: 4,
                color: ChessEarnTheme.themeColors['surface-light']!.withOpacity(0.5),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                child: ListTile(
                  leading: const Icon(Icons.live_tv, color: Colors.redAccent),
                  title: Text(
                    streamer['name']!,
                    style: TextStyle(color: ChessEarnTheme.themeColors['text-light']),
                  ),
                  subtitle: GestureDetector(
                    onTap: () => _launchURL(streamer['url']!),
                    child: Text(
                      streamer['handle']!,
                      style: const TextStyle(color: Colors.lightBlueAccent),
                    ),
                  ),
                  trailing: const Icon(Icons.arrow_forward_ios, color: Colors.white, size: 16),
                ),
              )),
          const SizedBox(height: 20),
          // News Section
          const Text(
            'ChessEarn Updates',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),
          Container(
            height: 150,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Colors.blueAccent, Colors.cyan],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(15),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black26,
                  offset: Offset(0, 4),
                  blurRadius: 8,
                ),
              ],
            ),
            child: Center(
              child: Text(
                'New Rewards Unlocked This Week!\nJoin the Earn Leaderboard!',
                style: TextStyle(color: ChessEarnTheme.themeColors['text-light'], fontSize: 16),
                textAlign: TextAlign.center,
              ),
            ),
          ),
          const SizedBox(height: 20),
          // Schedule Section
          const Text(
            'ChessEarn Live Schedule',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: ChessEarnTheme.themeColors['surface-light']!.withOpacity(0.3),
              borderRadius: BorderRadius.circular(15),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black26,
                  offset: Offset(0, 4),
                  blurRadius: 8,
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$dayName $dayDate',
                  style: const TextStyle(color: Colors.white, fontSize: 16),
                ),
                const SizedBox(height: 10),
                ...schedule.map((event) => Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      height: 60,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: event['highlight']!.isNotEmpty
                              ? [Colors.orange, Colors.deepOrange]
                              : [Colors.grey, Colors.grey],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Center(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.event, color: Colors.white),
                            const SizedBox(width: 10),
                            Text(
                              '${event['time']} - ${event['event']}',
                              style: const TextStyle(color: Colors.white),
                            ),
                            if (event['highlight']!.isNotEmpty)
                              const Text(
                                ' Live Now!',
                                style: TextStyle(color: Colors.yellow, fontWeight: FontWeight.bold),
                              ),
                          ],
                        ),
                      ),
                    )),
              ],
            ),
          ),
        ],
      ),
    );
  }
}