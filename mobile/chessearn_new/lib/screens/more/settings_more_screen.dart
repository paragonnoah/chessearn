import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:chessearn_new/theme.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:local_auth/local_auth.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;

// Model for user settings
class UserSettings {
  final bool darkMode;
  final bool notifications;
  final bool soundEffects;
  final bool vibration;
  final bool autoBackup;
  final bool biometric;
  final String language;
  final double animationSpeed;
  final String difficulty;

  UserSettings({
    required this.darkMode,
    required this.notifications,
    required this.soundEffects,
    required this.vibration,
    required this.autoBackup,
    required this.biometric,
    required this.language,
    required this.animationSpeed,
    required this.difficulty,
  });

  Map<String, dynamic> toJson() => {
        'darkMode': darkMode,
        'notifications': notifications,
        'soundEffects': soundEffects,
        'vibration': vibration,
        'autoBackup': autoBackup,
        'biometric': biometric,
        'language': language,
        'animationSpeed': animationSpeed,
        'difficulty': difficulty,
      };

  factory UserSettings.fromJson(Map<String, dynamic> json) => UserSettings(
        darkMode: json['darkMode'] ?? true,
        notifications: json['notifications'] ?? true,
        soundEffects: json['soundEffects'] ?? true,
        vibration: json['vibration'] ?? true,
        autoBackup: json['autoBackup'] ?? false,
        biometric: json['biometric'] ?? false,
        language: json['language'] ?? 'English',
        animationSpeed: json['animationSpeed']?.toDouble() ?? 0.5,
        difficulty: json['difficulty'] ?? 'Intermediate',
      );
}

// API service for settings-related backend operations
class SettingsApiService {
  static const String baseUrl = 'https://v2.chessearn.com'; // Updated to match your API domain
  
  // Save user settings to backend
  static Future<bool> saveUserSettings(String userId, UserSettings settings) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/users/$userId/settings'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer YOUR_JWT_TOKEN', // Replace with actual token from your app
        },
        body: jsonEncode(settings.toJson()),
      );
      return response.statusCode == 200;
    } catch (e) {
      print('Error saving settings: $e');
      return false;
    }
  }

  // Load user settings from backend
  static Future<UserSettings?> loadUserSettings(String userId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/users/$userId/settings'),
        headers: {
          'Authorization': 'Bearer YOUR_JWT_TOKEN', // Replace with actual token
        },
      );
      if (response.statusCode == 200) {
        return UserSettings.fromJson(jsonDecode(response.body));
      }
    } catch (e) {
      print('Error loading settings: $e');
    }
    return null;
  }

  // Export game data
  static Future<Map<String, dynamic>?> exportGameData(String userId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/users/$userId/export'),
        headers: {
          'Authorization': 'Bearer YOUR_JWT_TOKEN',
        },
      );
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
    } catch (e) {
      print('Error exporting data: $e');
    }
    return null;
  }

  // Reset user statistics
  static Future<bool> resetUserStatistics(String userId) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/users/$userId/statistics'),
        headers: {
          'Authorization': 'Bearer YOUR_JWT_TOKEN',
        },
      );
      return response.statusCode == 200;
    } catch (e) {
      print('Error resetting statistics: $e');
      return false;
    }
  }

  // Cloud backup
  static Future<bool> performCloudBackup(String userId) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/users/$userId/backup'),
        headers: {
          'Authorization': 'Bearer YOUR_JWT_TOKEN',
        },
      );
      return response.statusCode == 200;
    } catch (e) {
      print('Error performing backup: $e');
      return false;
    }
  }
}

class SettingsMoreScreen extends StatefulWidget {
  const SettingsMoreScreen({super.key});

  @override
  State<SettingsMoreScreen> createState() => _SettingsMoreScreenState();
}

class _SettingsMoreScreenState extends State<SettingsMoreScreen> with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _pulseController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _pulseAnimation;
  
  // Settings states
  bool isDarkMode = true;
  bool notificationsEnabled = true;
  bool soundEffectsEnabled = true;
  bool vibrationEnabled = true;
  bool autoBackupEnabled = false;
  bool biometricEnabled = false;
  String selectedLanguage = 'English';
  double boardAnimationSpeed = 0.5;
  String difficultyLevel = 'Intermediate';

  // Services
  final LocalAuthentication _localAuth = LocalAuthentication();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _loadSettings();
  }

  void _initializeAnimations() {
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);
    
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeOut),
    );
    _pulseAnimation = Tween<double>(begin: 0.3, end: 1.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
    
    _fadeController.forward();
  }

  Future<void> _loadSettings() async {
    setState(() => _isLoading = true);
    
    // Load from SharedPreferences (local storage)
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      isDarkMode = prefs.getBool('dark_mode') ?? true;
      notificationsEnabled = prefs.getBool('notifications') ?? true;
      soundEffectsEnabled = prefs.getBool('sound_effects') ?? true;
      vibrationEnabled = prefs.getBool('vibration') ?? true;
      autoBackupEnabled = prefs.getBool('auto_backup') ?? false;
      biometricEnabled = prefs.getBool('biometric') ?? false;
      selectedLanguage = prefs.getString('language') ?? 'English';
      boardAnimationSpeed = prefs.getDouble('animation_speed') ?? 0.5;
      difficultyLevel = prefs.getString('difficulty') ?? 'Intermediate';
      _isLoading = false;
    });

    // Optionally load from backend (uncomment and replace 'user_id' with actual ID)
    // final backendSettings = await SettingsApiService.loadUserSettings('user_id');
    // if (backendSettings != null) {
    //   setState(() {
    //     isDarkMode = backendSettings.darkMode;
    //     notificationsEnabled = backendSettings.notifications;
    //     soundEffectsEnabled = backendSettings.soundEffects;
    //     vibrationEnabled = backendSettings.vibration;
    //     autoBackupEnabled = backendSettings.autoBackup;
    //     biometricEnabled = backendSettings.biometric;
    //     selectedLanguage = backendSettings.language;
    //     boardAnimationSpeed = backendSettings.animationSpeed;
    //     difficultyLevel = backendSettings.difficulty;
    //   });
    // }
  }

  Future<void> _saveSettings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('dark_mode', isDarkMode);
    await prefs.setBool('notifications', notificationsEnabled);
    await prefs.setBool('sound_effects', soundEffectsEnabled);
    await prefs.setBool('vibration', vibrationEnabled);
    await prefs.setBool('auto_backup', autoBackupEnabled);
    await prefs.setBool('biometric', biometricEnabled);
    await prefs.setString('language', selectedLanguage);
    await prefs.setDouble('animation_speed', boardAnimationSpeed);
    await prefs.setString('difficulty', difficultyLevel);

    // Save to backend (uncomment and replace 'user_id' with actual ID)
    final settings = UserSettings(
      darkMode: isDarkMode,
      notifications: notificationsEnabled,
      soundEffects: soundEffectsEnabled,
      vibration: vibrationEnabled,
      autoBackup: autoBackupEnabled,
      biometric: biometricEnabled,
      language: selectedLanguage,
      animationSpeed: boardAnimationSpeed,
      difficulty: difficultyLevel,
    );
    
    // await SettingsApiService.saveUserSettings('user_id', settings);
  }

  Future<void> _setupBiometric() async {
    try {
      // Check if biometric authentication is available
      final canCheckBiometrics = await _localAuth.canCheckBiometrics;
      final isDeviceSupported = await _localAuth.isDeviceSupported();
      if (!canCheckBiometrics || !isDeviceSupported) {
        _showMessage('Biometric authentication not available on this device');
        return;
      }

      // Authenticate using biometrics
      final isAuthenticated = await _localAuth.authenticate(
        localizedReason: 'Enable biometric login for ChessEarn',
        options: const AuthenticationOptions(
          biometricOnly: true,
          stickyAuth: true,
        ),
      );

      if (isAuthenticated) {
        setState(() => biometricEnabled = true);
        await _saveSettings();
        _showMessage('Biometric login enabled successfully!');
      } else {
        _showMessage('Biometric authentication failed');
      }
    } catch (e) {
      _showMessage('Failed to set up biometric authentication: $e');
    }
  }

  Future<void> _performBackup() async {
    setState(() => _isLoading = true);
    
    try {
      // Simulate backup process
      await Future.delayed(const Duration(seconds: 2));
      
      // In real implementation (uncomment and replace 'user_id' with actual ID):
      // final success = await SettingsApiService.performCloudBackup('user_id');
      // if (success) {
        _showMessage('Backup completed successfully!');
      // } else {
      //   _showMessage('Backup failed. Please try again.');
      // }
    } catch (e) {
      _showMessage('Backup failed: ${e.toString()}');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _exportGameData() async {
    setState(() => _isLoading = true);

    try {
      // In real implementation, get data from API (uncomment and replace 'user_id'):
      // final gameData = await SettingsApiService.exportGameData('user_id');
      
      // Mock data for demonstration
      final gameData = {
        'totalGames': 150,
        'wins': 85,
        'losses': 45,
        'draws': 20,
        'rating': 1650,
        'achievements': ['First Win', 'Chess Master', 'Speed Demon'],
        'gameHistory': [], // Would contain actual game data
      };

      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/chessearn_export_${DateTime.now().millisecondsSinceEpoch}.json');
      await file.writeAsString(jsonEncode(gameData));

      _showMessage('Game data exported to: ${file.path}');
    } catch (e) {
      _showMessage('Export failed: ${e.toString()}');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _resetStatistics() async {
    final confirmed = await _showConfirmationDialog(
      'Reset Statistics',
      'Are you sure you want to reset all your game statistics? This action cannot be undone.',
    );

    if (confirmed) {
      setState(() => _isLoading = true);
      
      try {
        // In real implementation (uncomment and replace 'user_id'):
        // final success = await SettingsApiService.resetUserStatistics('user_id');
        
        await Future.delayed(const Duration(seconds: 1)); // Simulate API call
        _showMessage('Statistics reset successfully!');
      } catch (e) {
        _showMessage('Failed to reset statistics');
      } finally {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<bool> _showConfirmationDialog(String title, String content) async {
    return await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: ChessEarnTheme.themeColors['brand-gradient-start'],
          title: Text(title, style: TextStyle(color: ChessEarnTheme.themeColors['text-light'])),
          content: Text(content, style: TextStyle(color: ChessEarnTheme.themeColors['text-light'])),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text('Cancel', style: TextStyle(color: ChessEarnTheme.themeColors['text-light'])),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: ElevatedButton.styleFrom(backgroundColor: ChessEarnTheme.themeColors['brand-accent']),
              child: const Text('Confirm', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    ) ?? false;
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: ChessEarnTheme.themeColors['brand-accent'],
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _openTutorial() {
    // Navigate to tutorial screen
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const TutorialScreen(),
      ),
    );
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _pulseController.dispose();
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
            child: Stack(
              children: [
                CustomScrollView(
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
                        style: TextStyle(
                          color: ChessEarnTheme.themeColors['text-light'],
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    SliverList(
                      delegate: SliverChildListDelegate([
                        Padding(
                          padding: const EdgeInsets.all(20.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildSectionHeader('Appearance'),
                              _buildSettingItem(
                                'Dark Mode',
                                Icons.brightness_6,
                                Switch(
                                  value: isDarkMode,
                                  onChanged: (value) async {
                                    setState(() => isDarkMode = value);
                                    await _saveSettings();
                                    _showMessage('Theme preference saved!');
                                  },
                                  activeColor: ChessEarnTheme.themeColors['brand-accent'],
                                ),
                              ),
                              _buildSliderSettingItem(
                                'Board Animation Speed',
                                Icons.speed,
                                boardAnimationSpeed,
                                (value) async {
                                  setState(() => boardAnimationSpeed = value);
                                  await _saveSettings();
                                  if (vibrationEnabled) HapticFeedback.selectionClick();
                                },
                              ),
                              
                              const SizedBox(height: 24),
                              _buildSectionHeader('Game Settings'),
                              _buildDropdownSettingItem(
                                'Difficulty Level',
                                Icons.psychology,
                                difficultyLevel,
                                ['Beginner', 'Intermediate', 'Advanced', 'Expert'],
                                (value) async {
                                  setState(() => difficultyLevel = value!);
                                  await _saveSettings();
                                  _showMessage('Difficulty level updated!');
                                },
                              ),
                              _buildSettingItem(
                                'Sound Effects',
                                Icons.volume_up,
                                Switch(
                                  value: soundEffectsEnabled,
                                  onChanged: (value) async {
                                    setState(() => soundEffectsEnabled = value);
                                    await _saveSettings();
                                    _showMessage('Sound settings saved!');
                                  },
                                  activeColor: ChessEarnTheme.themeColors['brand-accent'],
                                ),
                              ),
                              _buildSettingItem(
                                'Haptic Feedback',
                                Icons.vibration,
                                Switch(
                                  value: vibrationEnabled,
                                  onChanged: (value) async {
                                    setState(() => vibrationEnabled = value);
                                    await _saveSettings();
                                    if (value) HapticFeedback.mediumImpact();
                                    _showMessage('Haptic feedback ${value ? 'enabled' : 'disabled'}!');
                                  },
                                  activeColor: ChessEarnTheme.themeColors['brand-accent'],
                                ),
                              ),

                              const SizedBox(height: 24),
                              _buildSectionHeader('Notifications'),
                              _buildSettingItem(
                                'Push Notifications',
                                Icons.notifications,
                                Switch(
                                  value: notificationsEnabled,
                                  onChanged: (value) async {
                                    setState(() => notificationsEnabled = value);
                                    await _saveSettings();
                                    _showMessage('Notification settings saved!');
                                  },
                                  activeColor: ChessEarnTheme.themeColors['brand-accent'],
                                ),
                              ),

                              const SizedBox(height: 24),
                              _buildSectionHeader('Account & Security'),
                              _buildSettingItem(
                                'Biometric Login',
                                Icons.fingerprint,
                                Switch(
                                  value: biometricEnabled,
                                  onChanged: (value) async {
                                    if (value) {
                                      await _setupBiometric();
                                    } else {
                                      setState(() => biometricEnabled = false);
                                      await _saveSettings();
                                      _showMessage('Biometric login disabled');
                                    }
                                  },
                                  activeColor: ChessEarnTheme.themeColors['brand-accent'],
                                ),
                              ),
                              _buildSettingItem(
                                'Auto Backup',
                                Icons.cloud_sync,
                                Switch(
                                  value: autoBackupEnabled,
                                  onChanged: (value) async {
                                    setState(() => autoBackupEnabled = value);
                                    await _saveSettings();
                                    if (value) {
                                      await _performBackup();
                                    }
                                    _showMessage('Auto backup ${value ? 'enabled' : 'disabled'}!');
                                  },
                                  activeColor: ChessEarnTheme.themeColors['brand-accent'],
                                ),
                              ),

                              const SizedBox(height: 24),
                              _buildSectionHeader('Advanced'),
                              _buildDropdownSettingItem(
                                'Language',
                                Icons.language,
                                selectedLanguage,
                                ['English', 'Spanish', 'French', 'German', 'Chinese', 'Japanese'],
                                (value) async {
                                  setState(() => selectedLanguage = value!);
                                  await _saveSettings();
                                  _showMessage('Language preference saved!');
                                },
                              ),
                              _buildSettingItem(
                                'Export Game Data',
                                Icons.download,
                                Icon(Icons.arrow_forward_ios, 
                                     color: ChessEarnTheme.themeColors['text-light']?.withOpacity(0.6),
                                     size: 16),
                                onTap: _exportGameData,
                              ),
                              _buildSettingItem(
                                'Reset Statistics',
                                Icons.refresh,
                                Icon(Icons.arrow_forward_ios, 
                                     color: ChessEarnTheme.themeColors['text-light']?.withOpacity(0.6),
                                     size: 16),
                                onTap: _resetStatistics,
                              ),
                              _buildSettingItem(
                                'Tutorial',
                                Icons.school,
                                Icon(Icons.arrow_forward_ios, 
                                     color: ChessEarnTheme.themeColors['text-light']?.withOpacity(0.6),
                                     size: 16),
                                onTap: _openTutorial,
                              ),

                              const SizedBox(height: 32),
                              _buildVersionInfo(),
                            ],
                          ),
                        ),
                      ]),
                    ),
                  ],
                ),
                
                // Loading overlay
                if (_isLoading)
                  Container(
                    color: Colors.black.withOpacity(0.5),
                    child: Center(
                      child: Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: ChessEarnTheme.themeColors['brand-gradient-start'],
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation<Color>(
                                ChessEarnTheme.themeColors['brand-accent']!,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'Processing...',
                              style: TextStyle(
                                color: ChessEarnTheme.themeColors['text-light'],
                              ),
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
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: TextStyle(
          color: ChessEarnTheme.themeColors['text-light'],
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildSettingItem(String title, IconData icon, Widget trailing, {VoidCallback? onTap}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.05),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.white.withOpacity(0.1)),
            ),
            child: Row(
              children: [
                Icon(icon, color: ChessEarnTheme.themeColors['brand-accent'], size: 24),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      color: ChessEarnTheme.themeColors['text-light'],
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                trailing,
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSliderSettingItem(String title, IconData icon, double value, ValueChanged<double> onChanged) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: ChessEarnTheme.themeColors['brand-accent'], size: 24),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    color: ChessEarnTheme.themeColors['text-light'],
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: ChessEarnTheme.themeColors['brand-accent'],
              inactiveTrackColor: Colors.white.withOpacity(0.2),
              thumbColor: ChessEarnTheme.themeColors['brand-accent'],
            ),
            child: Slider(
              value: value,
              onChanged: onChanged,
              min: 0.1,
              max: 1.0,
              divisions: 9,
              label: '${(value * 100).round()}%',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDropdownSettingItem(String title, IconData icon, String value, List<String> options, ValueChanged<String?> onChanged) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Row(
        children: [
          Icon(icon, color: ChessEarnTheme.themeColors['brand-accent'], size: 24),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                color: ChessEarnTheme.themeColors['text-light'],
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: value,
                onChanged: onChanged,
                dropdownColor: ChessEarnTheme.themeColors['brand-gradient-start'],
                style: TextStyle(color: ChessEarnTheme.themeColors['text-light']),
                icon: Icon(Icons.arrow_drop_down, color: ChessEarnTheme.themeColors['text-light']),
                items: options.map((String option) {
                  return DropdownMenuItem<String>(
                    value: option,
                    child: Text(option),
                  );
                }).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVersionInfo() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.03),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Column(
        children: [
          Text(
            'ChessEarn v2.1.0',
            style: TextStyle(
              color: ChessEarnTheme.themeColors['text-light']?.withOpacity(0.8),
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Made with ♟️ and Flutter',
            style: TextStyle(
              color: ChessEarnTheme.themeColors['text-light']?.withOpacity(0.6),
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}

// Placeholder TutorialScreen (you can expand this later)
class TutorialScreen extends StatelessWidget {
  const TutorialScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Tutorial')),
      body: const Center(
        child: Text('Tutorial content goes here'),
      ),
    );
  }
}