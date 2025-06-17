import 'package:flutter/material.dart';
import 'package:chessearn_new/theme.dart';

class LearnScreen extends StatefulWidget {
  final String? userId;
  const LearnScreen({super.key, required this.userId});

  @override
  State<LearnScreen> createState() => _LearnScreenState();
}

class _LearnScreenState extends State<LearnScreen> with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  int selectedCategoryIndex = 0;
  
  final List<LearningCategory> categories = [
    LearningCategory(
      title: "Getting Started",
      icon: Icons.play_circle_outline,
      color: Colors.green,
      lessons: [
        Lesson("Chess Board Setup", "Learn how to set up the chess board", Icons.grid_3x3, 0),
        Lesson("Piece Introduction", "Meet all the chess pieces", Icons.casino, 0),
        Lesson("Basic Rules", "Understand fundamental chess rules", Icons.rule, 0),
        Lesson("How Pieces Move", "Learn how each piece moves", Icons.open_with, 0),
      ]
    ),
    LearningCategory(
      title: "Basic Tactics",
      icon: Icons.psychology,
      color: Colors.blue,
      lessons: [
        Lesson("Forks", "Attack two pieces at once", Icons.call_split, 1),
        Lesson("Pins", "Restrict piece movement", Icons.push_pin, 1),
        Lesson("Skewers", "Force valuable piece to move", Icons.arrow_forward, 1),
        Lesson("Discovered Attacks", "Reveal hidden attacks", Icons.visibility, 2),
      ]
    ),
    LearningCategory(
      title: "Strategy",
      icon: Icons.trending_up,
      color: Colors.purple,
      lessons: [
        Lesson("Opening Principles", "Start your games strong", Icons.flight_takeoff, 1),
        Lesson("Center Control", "Dominate the center", Icons.center_focus_strong, 1),
        Lesson("King Safety", "Keep your king protected", Icons.security, 2),
        Lesson("Endgame Basics", "Finish games effectively", Icons.flag, 2),
      ]
    ),
    LearningCategory(
      title: "Advanced",
      icon: Icons.military_tech,
      color: Colors.red,
      lessons: [
        Lesson("Complex Tactics", "Master advanced combinations", Icons.auto_awesome, 3),
        Lesson("Positional Play", "Understand piece coordination", Icons.account_tree, 3),
        Lesson("Opening Theory", "Study opening variations", Icons.library_books, 3),
        Lesson("Endgame Mastery", "Perfect your endgames", Icons.emoji_events, 3),
      ]
    ),
  ];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
      child: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: Column(
            children: [
              _buildHeader(),
              _buildProgressSection(),
              _buildCategoryTabs(),
              Expanded(child: _buildLessonsList()),
              _buildQuickActions(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.school,
              color: ChessEarnTheme.themeColors['text-light'],
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Chess Academy',
                  style: TextStyle(
                    color: ChessEarnTheme.themeColors['text-light'],
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Master the royal game',
                  style: TextStyle(
                    color: ChessEarnTheme.themeColors['text-light']!.withOpacity(0.8),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.amber.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.amber.withOpacity(0.5)),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.star, color: Colors.amber, size: 16),
                SizedBox(width: 4),
                Text(
                  'Level 3',
                  style: TextStyle(
                    color: Colors.amber,
                    fontSize: 12,
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

  Widget _buildProgressSection() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Overall Progress',
                style: TextStyle(
                  color: ChessEarnTheme.themeColors['text-light'],
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Text(
                '68%',
                style: TextStyle(
                  color: Colors.green,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          LinearProgressIndicator(
            value: 0.68,
            backgroundColor: Colors.white.withOpacity(0.2),
            valueColor: const AlwaysStoppedAnimation<Color>(Colors.green),
            borderRadius: BorderRadius.circular(4),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _buildStatCard("Lessons", "24/35", Icons.book),
              const SizedBox(width: 12),
              _buildStatCard("Streak", "7 days", Icons.local_fire_department),
              const SizedBox(width: 12),
              _buildStatCard("XP", "1,240", Icons.stars),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Icon(icon, color: Colors.white70, size: 20),
            const SizedBox(height: 4),
            Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              title,
              style: TextStyle(
                color: Colors.white.withOpacity(0.7),
                fontSize: 11,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryTabs() {
    return Container(
      height: 60,
      margin: const EdgeInsets.symmetric(vertical: 10),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final isSelected = index == selectedCategoryIndex;
          return GestureDetector(
            onTap: () {
              setState(() {
                selectedCategoryIndex = index;
              });
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              margin: const EdgeInsets.only(right: 12),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: isSelected 
                    ? Colors.white.withOpacity(0.2)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isSelected 
                      ? Colors.white.withOpacity(0.5)
                      : Colors.transparent,
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    categories[index].icon,
                    color: isSelected 
                        ? Colors.white 
                        : Colors.white.withOpacity(0.6),
                    size: 20,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    categories[index].title,
                    style: TextStyle(
                      color: isSelected 
                          ? Colors.white 
                          : Colors.white.withOpacity(0.6),
                      fontSize: 12,
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildLessonsList() {
    final selectedCategory = categories[selectedCategoryIndex];
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
      ),
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: selectedCategory.lessons.length,
        itemBuilder: (context, index) {
          final lesson = selectedCategory.lessons[index];
          return _buildLessonCard(lesson, index);
        },
      ),
    );
  }

  Widget _buildLessonCard(Lesson lesson, int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: ListTile(
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: _getDifficultyColor(lesson.difficulty).withOpacity(0.2),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            lesson.icon,
            color: _getDifficultyColor(lesson.difficulty),
            size: 20,
          ),
        ),
        title: Text(
          lesson.title,
          style: TextStyle(
            color: ChessEarnTheme.themeColors['text-light'],
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              lesson.description,
              style: TextStyle(
                color: ChessEarnTheme.themeColors['text-light']!.withOpacity(0.7),
                fontSize: 13,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: _getDifficultyColor(lesson.difficulty).withOpacity(0.2),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    _getDifficultyText(lesson.difficulty),
                    style: TextStyle(
                      color: _getDifficultyColor(lesson.difficulty),
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Icon(
                  Icons.timer,
                  color: Colors.white.withOpacity(0.5),
                  size: 12,
                ),
                const SizedBox(width: 2),
                Text(
                  '${5 + lesson.difficulty * 3}min',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.5),
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ],
        ),
        trailing: Icon(
          Icons.arrow_forward_ios,
          color: ChessEarnTheme.themeColors['text-light']!.withOpacity(0.5),
          size: 16,
        ),
        onTap: () {
          _showLessonDialog(lesson);
        },
      ),
    );
  }

  Widget _buildQuickActions() {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          Expanded(
            child: _buildActionButton(
              "Daily Puzzle",
              Icons.extension,
              Colors.orange,
              () => _showComingSoonDialog("Daily Puzzle"),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildActionButton(
              "Practice",
              Icons.fitness_center,
              Colors.blue,
              () => _showComingSoonDialog("Practice Mode"),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildActionButton(
              "Analysis",
              Icons.analytics,
              Colors.green,
              () => _showComingSoonDialog("Game Analysis"),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(String title, IconData icon, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.2),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 8),
            Text(
              title,
              style: TextStyle(
                color: color,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getDifficultyColor(int difficulty) {
    switch (difficulty) {
      case 0: return Colors.green;
      case 1: return Colors.yellow;
      case 2: return Colors.orange;
      case 3: return Colors.red;
      default: return Colors.grey;
    }
  }

  String _getDifficultyText(int difficulty) {
    switch (difficulty) {
      case 0: return 'Beginner';
      case 1: return 'Easy';
      case 2: return 'Medium';
      case 3: return 'Hard';
      default: return 'Unknown';
    }
  }

  void _showLessonDialog(Lesson lesson) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF2C2C2C),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Row(
            children: [
              Icon(lesson.icon, color: _getDifficultyColor(lesson.difficulty)),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  lesson.title,
                  style: const TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                lesson.description,
                style: TextStyle(color: Colors.white.withOpacity(0.8)),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.blue.withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.info_outline, color: Colors.blue, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'This lesson will help you understand ${lesson.title.toLowerCase()} and improve your chess skills.',
                        style: const TextStyle(color: Colors.blue, fontSize: 12),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'Later',
                style: TextStyle(color: Colors.white.withOpacity(0.6)),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                _showComingSoonDialog("Lesson: ${lesson.title}");
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: _getDifficultyColor(lesson.difficulty),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: const Text('Start Lesson'),
            ),
          ],
        );
      },
    );
  }

  void _showComingSoonDialog(String feature) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF2C2C2C),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Row(
            children: [
              Icon(Icons.construction, color: Colors.amber),
              SizedBox(width: 12),
              Text('Coming Soon!', style: TextStyle(color: Colors.white)),
            ],
          ),
          content: Text(
            '$feature is currently under development. Stay tuned for updates!',
            style: TextStyle(color: Colors.white.withOpacity(0.8)),
          ),
          actions: [
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.amber,
                foregroundColor: Colors.black,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: const Text('Got it!'),
            ),
          ],
        );
      },
    );
  }
}

class LearningCategory {
  final String title;
  final IconData icon;
  final Color color;
  final List<Lesson> lessons;

  LearningCategory({
    required this.title,
    required this.icon,
    required this.color,
    required this.lessons,
  });
}

class Lesson {
  final String title;
  final String description;
  final IconData icon;
  final int difficulty; // 0-3 (Beginner to Hard)

  Lesson(this.title, this.description, this.icon, this.difficulty);
}