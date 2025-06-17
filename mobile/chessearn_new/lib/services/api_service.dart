import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  static const String baseUrl = 'https://v2.chessearn.com';
  static String? _accessToken;
  static String? _refreshToken;
  static const bool useMockData = true; // Moved to const for consistency
  static const Duration _timeoutDuration = Duration(seconds: 30);

  static Future<void> initializeTokenStorage() async {
    final prefs = await SharedPreferences.getInstance();
    _accessToken = prefs.getString('access_token');
    _refreshToken = prefs.getString('refresh_token');
  }

  static Future<http.Response> register({
    required String firstName,
    required String lastName,
    required String email,
    required String username,
    required String phoneNumber,
    required String password,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/register'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'first_name': firstName,
          'last_name': lastName,
          'email': email,
          'username': username,
          'phone_number': phoneNumber,
          'password': password,
        }),
      ).timeout(_timeoutDuration, onTimeout: () {
        throw Exception('Registration request timed out. Please try again later.');
      });
      if (response.headers['set-cookie'] != null) {
        final cookies = response.headers['set-cookie']!.split(',');
        final prefs = await SharedPreferences.getInstance();
        for (var cookie in cookies) {
          if (cookie.contains('access_token_cookie')) {
            _accessToken = cookie.split('=')[1].split(';')[0];
            if (_accessToken != null) {
              await prefs.setString('access_token', _accessToken!);
            }
          }
          if (cookie.contains('csrf_access_token')) {
            final csrfToken = cookie.split('=')[1].split(';')[0];
            if (csrfToken != null) {
              await prefs.setString('csrf_access_token', csrfToken);
            }
          }
        }
      }
      return response;
    } catch (e) {
      throw Exception('Failed to register: $e');
    }
  }

  static Future<Map<String, dynamic>> login({required String identifier, required String password}) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'identifier': identifier, 'password': password}),
      ).timeout(_timeoutDuration, onTimeout: () {
        throw Exception('Login request timed out. Please try again later.');
      });
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final prefs = await SharedPreferences.getInstance();
        _accessToken = data['access_token'];
        _refreshToken = data['refresh_token'];
        await prefs.setString('access_token', _accessToken!);
        await prefs.setString('refresh_token', _refreshToken!);
        await prefs.setString('userId', data['user']['id']);
        return data;
      } else {
        throw Exception(jsonDecode(response.body)['message'] ?? 'Login failed');
      }
    } catch (e) {
      throw Exception('Failed to login: $e');
    }
  }

  static Future<String> refreshToken() async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/refresh'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_refreshToken',
        },
      ).timeout(_timeoutDuration, onTimeout: () {
        throw Exception('Token refresh request timed out. Please try again later.');
      });
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        _accessToken = data['access_token'];
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('access_token', _accessToken!);
        return _accessToken!;
      } else {
        throw Exception(jsonDecode(response.body)['message'] ?? 'Token refresh failed');
      }
    } catch (e) {
      throw Exception('Failed to refresh token: $e');
    }
  }

  static Future<void> logout() async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/logout'),
        headers: {
          'Authorization': 'Bearer $_accessToken',
        },
      ).timeout(_timeoutDuration, onTimeout: () {
        throw Exception('Logout request timed out. Please try again later.');
      });
      if (response.statusCode != 200) {
        throw Exception('Logout failed: ${response.statusCode} - ${response.body}');
      }
      _accessToken = null;
      _refreshToken = null;
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('access_token');
      await prefs.remove('refresh_token');
      await prefs.remove('userId');
    } catch (e) {
      throw Exception('Failed to logout: $e');
    }
  }

  static Future<http.Response> getProfile({required String userId}) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/profile'),
        headers: {
          'Authorization': 'Bearer $_accessToken',
        },
      ).timeout(_timeoutDuration, onTimeout: () {
        throw Exception('Profile request timed out. Please try again later.');
      });
      return response;
    } catch (e) {
      throw Exception('Failed to get profile: $e');
    }
  }

  static Future<http.Response> uploadProfilePhoto({required String userId, required String filePath}) async {
    try {
      var request = http.MultipartRequest('POST', Uri.parse('$baseUrl/profile/photo'));
      request.files.add(await http.MultipartFile.fromPath('photo', filePath));
      request.headers['Authorization'] = 'Bearer $_accessToken';
      final response = await http.Response.fromStream(await request.send()).timeout(_timeoutDuration, onTimeout: () {
        throw Exception('Photo upload request timed out. Please try again later.');
      });
      return response;
    } catch (e) {
      throw Exception('Failed to upload photo: $e');
    }
  }

  static Future<void> postGameMove(String move) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/game/move'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_accessToken',
        },
        body: jsonEncode({'move': move}),
      ).timeout(_timeoutDuration, onTimeout: () {
        throw Exception('Game move request timed out. Please try again later.');
      });
      if (response.statusCode != 200) {
        throw Exception('Failed to post move: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      throw Exception('Failed to post game move: $e');
    }
  }

  static Future<Map<String, dynamic>> getWalletBalance(String userId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/wallet'),
        headers: {
          'Authorization': 'Bearer $_accessToken',
        },
      ).timeout(_timeoutDuration, onTimeout: () {
        throw Exception('Wallet balance request timed out. Please try again later.');
      });
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {
          'country': data['country'] ?? 'KE',
          'wallet_balance': data['balance']?.toDouble() ?? 0.0,
        };
      }
      throw Exception('Failed to fetch wallet balance: ${response.statusCode} - ${response.body}');
    } catch (e) {
      return {
        'country': 'KE',
        'wallet_balance': 1000.0,
      };
    }
  }

  static Future<List<Map<String, dynamic>>> searchUsers(String query) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/users/search?query=$query'),
        headers: {
          'Authorization': 'Bearer $_accessToken',
        },
      ).timeout(_timeoutDuration, onTimeout: () {
        throw Exception('Search users request timed out. Please try again later.');
      });
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data is List) {
          return data.cast<Map<String, dynamic>>();
        }
        throw Exception('Unexpected response format: ${response.body}');
      }
      throw Exception('Failed to search users: ${response.statusCode} - ${response.body}');
    } catch (e) {
      throw Exception('Failed to search users: $e');
    }
  }

  static Future<void> sendFriendRequest(String userId, String friendId) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/friends/request'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_accessToken',
        },
        body: jsonEncode({
          'userId': userId,
          'friendId': friendId,
        }),
      ).timeout(_timeoutDuration, onTimeout: () {
        throw Exception('Friend request timed out. Please try again later.');
      });
      if (response.statusCode != 200) {
        throw Exception('Failed to send friend request: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      throw Exception('Failed to send friend request: $e');
    }
  }

  static Future<void> depositFunds(String userId, double amount) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/wallet/deposit'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_accessToken',
        },
        body: jsonEncode({
          'userId': userId,
          'amount': amount,
        }),
      ).timeout(_timeoutDuration, onTimeout: () {
        throw Exception('Deposit request timed out. Please try again later.');
      });
      if (response.statusCode != 200) {
        throw Exception('Failed to deposit funds: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      throw Exception('Failed to deposit funds: $e');
    }
  }

  static Future<void> withdrawFunds(String userId, double amount) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/wallet/withdraw'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_accessToken',
        },
        body: jsonEncode({
          'userId': userId,
          'amount': amount,
        }),
      ).timeout(_timeoutDuration, onTimeout: () {
        throw Exception('Withdraw request timed out. Please try again later.');
      });
      if (response.statusCode != 200) {
        throw Exception('Failed to withdraw funds: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      throw Exception('Failed to withdraw funds: $e');
    }
  }

  static Future<List<dynamic>> getLessons(String? userId) async {
    if (useMockData || userId == null) {
      return [
        {
          'id': 'category_1',
          'title': 'Beginner Lessons',
          'icon': '58276',
          'lessons': [
            {
              'id': 'lesson_1',
              'title': 'Chess Basics',
              'description': 'Learn the fundamentals',
              'difficulty': 0,
              'completed': false,
              'progress': 0.0,
              'icon': '58276',
              'tags': ['beginner'],
            },
          ],
        },
      ];
    }
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/lessons/$userId'),
        headers: {
          'Authorization': 'Bearer $_accessToken',
        },
      ).timeout(_timeoutDuration, onTimeout: () {
        throw Exception('Lessons request timed out. Please try again later.');
      });
      if (response.statusCode == 200) {
        return jsonDecode(response.body) as List<dynamic>;
      }
      throw Exception('Failed to fetch lessons: ${response.statusCode} - ${response.body}');
    } catch (e) {
      throw Exception('Failed to fetch lessons: $e');
    }
  }

  static Future<void> updateLessonProgress(String? userId, String lessonId, bool completed) async {
    if (useMockData || userId == null) {
      return;
    }
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/users/$userId/lessons/$lessonId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_accessToken',
        },
        body: jsonEncode({'completed': completed, 'progress': completed ? 1.0 : 0.0}),
      ).timeout(_timeoutDuration, onTimeout: () {
        throw Exception('Lesson progress update timed out. Please try again later.');
      });
      if (response.statusCode != 200) {
        throw Exception('Failed to update lesson progress: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      throw Exception('Failed to update lesson progress: $e');
    }
  }

  static Future<Map<String, dynamic>> getUserStats(String? userId) async {
    if (useMockData || userId == null) {
      return {
        'xp': 100,
        'puzzles_solved': 5,
        'rating': 1200,
        'wins': 10,
        'streak': 7,
      };
    }
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/users/$userId/stats'),
        headers: {
          'Authorization': 'Bearer $_accessToken',
        },
      ).timeout(_timeoutDuration, onTimeout: () {
        throw Exception('User stats request timed out. Please try again later.');
      });
      if (response.statusCode == 200) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      }
      throw Exception('Failed to load user stats: ${response.statusCode} - ${response.body}');
    } catch (e) {
      throw Exception('Failed to load stats: $e');
    }
  }

  static Future<List<Map<String, dynamic>>> getLeaderboard({required String gameType, required int limit}) async {
    if (useMockData) {
      return List.generate(10, (index) => {
        'id': 'user_${index + 1}',
        'username': 'Player${index + 1}',
        'rating': 2000 - (index * 50),
        'country_code': [
          'US', 'KE', 'JP', 'BR', 'AU', 'CA', 'IN', 'FR', 'DE', 'NG',
          'ZA', 'MX', 'CN', 'RU', 'IT', 'ES', 'NL', 'SE', 'CH', 'SG'
        ][index % 20],
      });
    }
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/leaderboard?game_type=$gameType&limit=$limit'),
        headers: {
          'Authorization': 'Bearer $_accessToken',
        },
      ).timeout(_timeoutDuration, onTimeout: () {
        throw Exception('Leaderboard request timed out. Please try again later.');
      });
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data is List) {
          return data.cast<Map<String, dynamic>>();
        }
        throw Exception('Unexpected response format: ${response.body}');
      }
      throw Exception('Failed to fetch leaderboard: ${response.statusCode} - ${response.body}');
    } catch (e) {
      throw Exception('Failed to fetch leaderboard: $e');
    }
  }

  static Future<List<Map<String, dynamic>>> getFriends(String? userId) async {
    if (useMockData || userId == null) {
      await Future.delayed(const Duration(seconds: 1));
      return [
        {
          'id': 'friend_1',
          'username': 'KnightMover',
          'country_code': 'US',
          'status': 'online',
        },
        {
          'id': 'friend_2',
          'username': 'QueenSlayer',
          'country_code': 'KE',
          'status': 'offline',
        },
        {
          'id': 'friend_3',
          'username': 'RookStar',
          'country_code': 'IN',
          'status': 'online',
        },
      ];
    }
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/friends'),
        headers: {
          'Authorization': 'Bearer $_accessToken',
        },
      ).timeout(_timeoutDuration, onTimeout: () {
        throw Exception('Friends request timed out. Please try again later.');
      });
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data is List) {
          return data.cast<Map<String, dynamic>>();
        }
        throw Exception('Unexpected response format: ${response.body}');
      }
      throw Exception('Failed to fetch friends: ${response.statusCode} - ${response.body}');
    } catch (e) {
      throw Exception('Failed to fetch friends: $e');
    }
  }

  static Future<List<Map<String, dynamic>>> getNotifications(String? userId) async {
    if (useMockData || userId == null) {
      await Future.delayed(const Duration(seconds: 1));
      return [
        {
          'id': 'notif_1',
          'title': 'Game Win',
          'message': 'You won a game against Player123!',
          'time': DateTime.now().subtract(const Duration(hours: 1)).toIso8601String(),
          'isRead': false,
        },
        {
          'id': 'notif_2',
          'title': 'Achievement Unlocked',
          'message': 'You earned the "Puzzle Master" badge!',
          'time': DateTime.now().subtract(const Duration(days: 1)).toIso8601String(),
          'isRead': false,
        },
        {
          'id': 'notif_3',
          'title': 'Friend Request',
          'message': 'Player456 sent you a friend request.',
          'time': DateTime.now().subtract(const Duration(days: 2)).toIso8601String(),
          'isRead': false,
        },
      ];
    }
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/notifications'),
        headers: {
          'Authorization': 'Bearer $_accessToken',
        },
      ).timeout(_timeoutDuration, onTimeout: () {
        throw Exception('Notifications request timed out. Please try again later.');
      });
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data is List) {
          return data.cast<Map<String, dynamic>>();
        }
        throw Exception('Unexpected response format: ${response.body}');
      }
      throw Exception('Failed to fetch notifications: ${response.statusCode} - ${response.body}');
    } catch (e) {
      throw Exception('Failed to fetch notifications: $e');
    }
  }

  static Future<void> markNotificationRead(String? userId, String notificationId) async {
    if (useMockData || userId == null) {
      return;
    }
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/notifications/$notificationId/read'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_accessToken',
        },
      ).timeout(_timeoutDuration, onTimeout: () {
        throw Exception('Mark notification read request timed out. Please try again later.');
      });
      if (response.statusCode != 200) {
        throw Exception('Failed to mark notification read: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      throw Exception('Failed to mark notification read: $e');
    }
  }

  static Future<String> createGame({
    required bool isRated,
    required int baseTime,
    required int increment,
    required double betAmount,
  }) async {
    if (useMockData) return 'mock_game_id'; // Mock for testing
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/game/create'),
        headers: {
          'Authorization': 'Bearer $_accessToken',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'is_rated': isRated,
          'base_time': baseTime,
          'increment': increment,
          'bet_amount': betAmount,
        }),
      ).timeout(_timeoutDuration, onTimeout: () {
        throw Exception('Create game request timed out');
      });
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['game_id']?.toString() ?? ''; // Assuming backend returns game_id
      }
      throw Exception('Failed to create game: ${response.statusCode} - ${response.body}');
    } catch (e) {
      throw Exception('Failed to create game: $e');
    }
  }

  static Future<String> joinGame(String gameId) async {
    if (useMockData) return gameId; // Mock return for testing
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/game/join/$gameId'),
        headers: {
          'Authorization': 'Bearer $_accessToken',
          'Content-Type': 'application/json',
        },
      ).timeout(_timeoutDuration, onTimeout: () {
        throw Exception('Join game request timed out');
      });
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['game_id']?.toString() ?? gameId; // Return game_id if provided, otherwise use input
      }
      throw Exception('Failed to join game: ${response.statusCode} - ${response.body}');
    } catch (e) {
      throw Exception('Failed to join game: $e');
    }
  }

  // Placeholder for fetching available games (to be implemented based on backend)
  static Future<List<Map<String, dynamic>>> getAvailableGames() async {
    if (useMockData) {
      return [
        {
          'id': 'game1',
          'white_player_id': 'user1',
          'status': 'pending',
          'bet_amount': 10.0,
          'base_time': 300,
          'increment': 0,
        },
        {
          'id': 'game2',
          'white_player_id': 'user2',
          'status': 'pending',
          'bet_amount': 20.0,
          'base_time': 600,
          'increment': 2,
        },
      ];
    }
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/game/available'),
        headers: {
          'Authorization': 'Bearer $_accessToken',
        },
      ).timeout(_timeoutDuration, onTimeout: () {
        throw Exception('Get available games request timed out');
      });
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data is List) {
          return data.cast<Map<String, dynamic>>();
        }
        throw Exception('Unexpected response format: ${response.body}');
      }
      throw Exception('Failed to fetch available games: ${response.statusCode} - ${response.body}');
    } catch (e) {
      throw Exception('Failed to fetch available games: $e');
    }
  }
}