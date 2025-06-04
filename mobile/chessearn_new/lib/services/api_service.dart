
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  static const String baseUrl = 'https://v2.chessearn.com';
  static String? _csrfToken;
  static String? _accessToken;
  static bool useMockData = true;

  static Future<void> initializeCookieJar() async {
    final prefs = await SharedPreferences.getInstance();
    _accessToken = prefs.getString('access_token');
    _csrfToken = prefs.getString('csrf_access_token');
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
      print('Attempting to register with URL: $baseUrl/auth/register');
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
      ).timeout(const Duration(seconds: 30), onTimeout: () {
        print('Registration request timed out');
        throw Exception('Registration request timed out. Please try again later.');
      });
      print('Registration response: ${response.statusCode} - ${response.body}');
      if (response.headers['set-cookie'] != null) {
        final cookies = response.headers['set-cookie']!.split(',');
        final prefs = await SharedPreferences.getInstance();
        for (var cookie in cookies) {
          if (cookie.contains('access_token_cookie')) {
            _accessToken = cookie.split('=')[1].split(';')[0];
            await prefs.setString('access_token', _accessToken!);
          }
          if (cookie.contains('csrf_access_token')) {
            _csrfToken = cookie.split('=')[1].split(';')[0];
            await prefs.setString('csrf_access_token', _csrfToken!);
          }
        }
      }
      return response;
    } catch (e) {
      print('Registration error: $e');
      throw Exception('Failed to register: $e');
    }
  }

  static Future<Map<String, dynamic>> login({required String identifier, required String password, required dynamic prefs}) async {
    try {
      print('Attempting to login with URL: $baseUrl/auth/login');
      final response = await http.post(
        Uri.parse('$baseUrl/auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'identifier': identifier, 'password': password}),
      ).timeout(const Duration(seconds: 30), onTimeout: () {
        print('Login request timed out');
        throw Exception('Login request timed out. Please try again later.');
      });
      print('Login response: ${response.statusCode} - ${response.body}');
      if (response.headers['set-cookie'] != null) {
        final cookies = response.headers['set-cookie']!.split(',');
        final prefs = await SharedPreferences.getInstance();
        for (var cookie in cookies) {
          if (cookie.contains('access_token_cookie')) {
            _accessToken = cookie.split('=')[1].split(';')[0];
            await prefs.setString('access_token', _accessToken!);
          }
          if (cookie.contains('csrf_access_token')) {
            _csrfToken = cookie.split('=')[1].split(';')[0];
            await prefs.setString('csrf_access_token', _csrfToken!);
          }
        }
      }
      final responseBody = jsonDecode(response.body);
      final userId = responseBody['id']?.toString() ?? '';
      await prefs.setString('userId', userId);
      return {'response': response, 'userId': userId};
    } catch (e) {
      print('Login error: $e');
      throw Exception('Failed to login: $e');
    }
  }

  static Future<void> logout() async {
    try {
      print('Attempting to logout with URL: $baseUrl/auth/logout');
      final cookieHeader = _accessToken != null ? 'access_token_cookie=$_accessToken' : '';
      final response = await http.post(
        Uri.parse('$baseUrl/auth/logout'),
        headers: {
          'X-CSRF-TOKEN': _csrfToken ?? '',
          if (cookieHeader.isNotEmpty) 'Cookie': cookieHeader,
        },
      ).timeout(const Duration(seconds: 30), onTimeout: () {
        print('Logout request timed out');
        throw Exception('Logout request timed out. Please try again later.');
      });
      print('Logout response: ${response.statusCode} - ${response.body}');
      if (response.statusCode != 200) {
        throw Exception('Logout failed: ${response.statusCode} - ${response.body}');
      }
      _accessToken = null;
      _csrfToken = null;
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('access_token');
      await prefs.remove('csrf_access_token');
      await prefs.remove('userId');
    } catch (e) {
      print('Logout error: $e');
      throw Exception('Failed to logout: $e');
    }
  }

  static Future<http.Response> getProfile({required String userId}) async {
    try {
      print('Attempting to get profile with URL: $baseUrl/profile');
      final cookieHeader = _accessToken != null ? 'access_token_cookie=$_accessToken' : '';
      final response = await http.get(
        Uri.parse('$baseUrl/profile'),
        headers: {
          if (cookieHeader.isNotEmpty) 'Cookie': cookieHeader,
        },
      ).timeout(const Duration(seconds: 30), onTimeout: () {
        print('Profile request timed out');
        throw Exception('Profile request timed out. Please try again later.');
      });
      print('Profile response: ${response.statusCode} - ${response.body}');
      return response;
    } catch (e) {
      print('Profile error: $e');
      throw Exception('Failed to get profile: $e');
    }
  }

  static Future<http.Response> uploadProfilePhoto({required String userId, required String filePath}) async {
    try {
      print('Attempting to upload photo with URL: $baseUrl/profile/photo');
      final cookieHeader = _accessToken != null ? 'access_token_cookie=$_accessToken' : '';
      var request = http.MultipartRequest('POST', Uri.parse('$baseUrl/profile/photo'));
      request.files.add(await http.MultipartFile.fromPath('photo', filePath));
      request.headers['X-CSRF-TOKEN'] = _csrfToken ?? '';
      if (cookieHeader.isNotEmpty) request.headers['Cookie'] = cookieHeader;
      final response = await http.Response.fromStream(await request.send()).timeout(const Duration(seconds: 30), onTimeout: () {
        print('Photo upload request timed out');
        throw Exception('Photo upload request timed out. Please try again later.');
      });
      print('Photo upload response: ${response.statusCode} - ${response.body}');
      return response;
    } catch (e) {
      print('Photo upload error: $e');
      throw Exception('Failed to upload photo: $e');
    }
  }

  static Future<void> postGameMove(String move) async {
    try {
      print('Attempting to post game move with URL: $baseUrl/game/move');
      final cookieHeader = _accessToken != null ? 'access_token_cookie=$_accessToken' : '';
      final response = await http.post(
        Uri.parse('$baseUrl/game/move'),
        headers: {
          'Content-Type': 'application/json',
          'X-CSRF-TOKEN': _csrfToken ?? '',
          if (cookieHeader.isNotEmpty) 'Cookie': cookieHeader,
        },
        body: jsonEncode({'move': move}),
      ).timeout(const Duration(seconds: 30), onTimeout: () {
        print('Game move request timed out');
        throw Exception('Game move request timed out. Please try again later.');
      });
      print('Game move response: ${response.statusCode} - ${response.body}');
      if (response.statusCode != 200) {
        throw Exception('Failed to post move: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print('Game move error: $e');
      throw Exception('Failed to post game move: $e');
    }
  }

  static Future<Map<String, dynamic>> getWalletBalance(String userId) async {
    try {
      print('Attempting to get wallet balance with URL: $baseUrl/wallet');
      final cookieHeader = _accessToken != null ? 'access_token_cookie=$_accessToken' : '';
      final response = await http.get(
        Uri.parse('$baseUrl/wallet'),
        headers: {
          if (cookieHeader.isNotEmpty) 'Cookie': cookieHeader,
        },
      ).timeout(const Duration(seconds: 30), onTimeout: () {
        print('Wallet balance request timed out');
        throw Exception('Wallet balance request timed out. Please try again later.');
      });
      print('Wallet balance response: ${response.statusCode} - ${response.body}');
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {
          'country': data['country'] ?? 'KE',
          'wallet_balance': data['balance']?.toDouble() ?? 0.0,
        };
      } else {
        throw Exception('Failed to fetch wallet balance: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print('Wallet balance error: $e');
      return {
        'country': 'KE',
        'wallet_balance': 1000.0,
      };
    }
  }

  static Future<List<Map<String, dynamic>>> searchUsers(String query) async {
    try {
      print('Attempting to search users with URL: $baseUrl/users/search?query=$query');
      final cookieHeader = _accessToken != null ? 'access_token_cookie=$_accessToken' : '';
      final response = await http.get(
        Uri.parse('$baseUrl/users/search?query=$query'),
        headers: {
          if (cookieHeader.isNotEmpty) 'Cookie': cookieHeader,
        },
      ).timeout(const Duration(seconds: 30), onTimeout: () {
        print('Search users request timed out');
        throw Exception('Search users request timed out. Please try again later.');
      });
      print('Search users response: ${response.statusCode} - ${response.body}');
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data is List) {
          return data.cast<Map<String, dynamic>>();
        } else {
          throw Exception('Unexpected response format: ${response.body}');
        }
      } else {
        throw Exception('Failed to search users: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print('Search users error: $e');
      throw Exception('Failed to search users: $e');
    }
  }

  static Future<void> sendFriendRequest(String userId, String friendId) async {
    try {
      print('Attempting to send friend request with URL: $baseUrl/friends/request');
      final cookieHeader = _accessToken != null ? 'access_token_cookie=$_accessToken' : '';
      final response = await http.post(
        Uri.parse('$baseUrl/friends/request'),
        headers: {
          'Content-Type': 'application/json',
          'X-CSRF-TOKEN': _csrfToken ?? '',
          if (cookieHeader.isNotEmpty) 'Cookie': cookieHeader,
        },
        body: jsonEncode({
          'userId': userId,
          'friendId': friendId,
        }),
      ).timeout(const Duration(seconds: 30), onTimeout: () {
        print('Friend request timed out');
        throw Exception('Friend request timed out. Please try again later.');
      });
      print('Friend request response: ${response.statusCode} - ${response.body}');
      if (response.statusCode != 200) {
        throw Exception('Failed to send friend request: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print('Friend request error: $e');
      throw Exception('Failed to send friend request: $e');
    }
  }

  static Future<void> depositFunds(String userId, double amount) async {
    try {
      print('Attempting to deposit funds with URL: $baseUrl/wallet/deposit');
      final cookieHeader = _accessToken != null ? 'access_token_cookie=$_accessToken' : '';
      final response = await http.post(
        Uri.parse('$baseUrl/wallet/deposit'),
        headers: {
          'Content-Type': 'application/json',
          'X-CSRF-TOKEN': _csrfToken ?? '',
          if (cookieHeader.isNotEmpty) 'Cookie': cookieHeader,
        },
        body: jsonEncode({
          'userId': userId,
          'amount': amount,
        }),
      ).timeout(const Duration(seconds: 30), onTimeout: () {
        print('Deposit request timed out');
        throw Exception('Deposit request timed out. Please try again later.');
      });
      print('Deposit response: ${response.statusCode} - ${response.body}');
      if (response.statusCode != 200) {
        throw Exception('Failed to deposit funds: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print('Deposit error: $e');
      throw Exception('Failed to deposit funds: $e');
    }
  }

  static Future<void> withdrawFunds(String userId, double amount) async {
    try {
      print('Attempting to withdraw funds with URL: $baseUrl/wallet/withdraw');
      final cookieHeader = _accessToken != null ? 'access_token_cookie=$_accessToken' : '';
      final response = await http.post(
        Uri.parse('$baseUrl/wallet/withdraw'),
        headers: {
          'Content-Type': 'application/json',
          'X-CSRF-TOKEN': _csrfToken ?? '',
          if (cookieHeader.isNotEmpty) 'Cookie': cookieHeader,
        },
        body: jsonEncode({
          'userId': userId,
          'amount': amount,
        }),
      ).timeout(const Duration(seconds: 30), onTimeout: () {
        print('Withdraw request timed out');
        throw Exception('Withdraw request timed out. Please try again later.');
      });
      print('Withdraw response: ${response.statusCode} - ${response.body}');
      if (response.statusCode != 200) {
        throw Exception('Failed to withdraw funds: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print('Withdraw error: $e');
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
      print('Attempting to get lessons with URL: $baseUrl/lessons/$userId');
      final cookieHeader = _accessToken != null ? 'access_token_cookie=$_accessToken' : '';
      final response = await http.get(
        Uri.parse('$baseUrl/lessons/$userId'),
        headers: {
          if (cookieHeader.isNotEmpty) 'Cookie': cookieHeader,
        },
      ).timeout(const Duration(seconds: 30), onTimeout: () {
        print('Lessons request timed out');
        throw Exception('Lessons request timed out. Please try again later.');
      });
      print('Lessons response: ${response.statusCode} - ${response.body}');
      if (response.statusCode == 200) {
        return jsonDecode(response.body) as List<dynamic>;
      }
      throw Exception('Failed to fetch lessons: ${response.statusCode} - ${response.body}');
    } catch (e) {
      print('Lessons error: $e');
      throw Exception('Failed to fetch lessons: $e');
    }
  }

  static Future<void> updateLessonProgress(String? userId, String lessonId, bool completed) async {
    if (useMockData || userId == null) {
      return;
    }
    try {
      print('Attempting to update lesson progress with URL: $baseUrl/users/$userId/lessons/$lessonId');
      final cookieHeader = _accessToken != null ? 'access_token_cookie=$_accessToken' : '';
      final response = await http.post(
        Uri.parse('$baseUrl/users/$userId/lessons/$lessonId'),
        headers: {
          'Content-Type': 'application/json',
          'X-CSRF-TOKEN': _csrfToken!,
          if (cookieHeader.isNotEmpty) 'Cookie': cookieHeader,
        },
        body: jsonEncode({'completed': completed, 'progress': completed ? 1.0 : 0.0}),
      ).timeout(const Duration(seconds: 30), onTimeout: () {
        print('Lesson progress update timed out');
        throw Exception('Lesson progress update timed out. Please try again later.');
      });
      print('Lesson progress response: ${response.statusCode} - ${response.body}');
      if (response.statusCode != 200) {
        throw Exception('Failed to update lesson progress: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print('Lesson progress update error: $e');
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
      print('Attempting to get user stats with URL: $baseUrl/users/$userId/stats');
      final cookieHeader = _accessToken != null ? 'access_token_cookie=$userId' : '';
      final response = await http.get(
        Uri.parse('$baseUrl/users/$userId/stats'),
        headers: {
          if (cookieHeader.isNotEmpty) 'Cookie': cookieHeader,
        },
      ).timeout(const Duration(seconds: 30), onTimeout: () {
          print('User stats request timed out.');
          throw Exception('User stats request timed out. Please try again later.');
        });
      print('User stats response: ${response.statusCode} - ${response.body}');
      if (response.statusCode == 200) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      }
      throw Exception('Failed to load user stats: ${response.statusCode} - ${response.body}');
    } catch (e) {
      print('User stats error: $e');
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
      print('Attempting to get leaderboard with URL: $baseUrl/leaderboard?game_type=$gameType&limit=$limit');
      final cookieHeader = _accessToken != null ? 'access_token_cookie=$_accessToken' : '';
      final response = await http.get(
        Uri.parse('$baseUrl/leaderboard?game_type=$gameType&limit=$limit'),
        headers: {
          if (cookieHeader.isNotEmpty) 'Cookie': cookieHeader,
        },
      ).timeout(const Duration(seconds: 30), onTimeout: () {
          print('Leaderboard request timed out');
          throw Exception('Leaderboard request timed out. Please try again later.');
        });
      print('Leaderboard response: ${response.statusCode} - ${response.body}');
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data is List) {
          return data.cast<Map<String, dynamic>>();
        } else {
          throw Exception('Unexpected response format: ${response.body}');
        }
      }
      throw Exception('Failed to fetch leaderboard: ${response.statusCode} - ${response.body}');
    } catch (e) {
      print('Leaderboard error: $e');
      throw Exception('Failed to fetch leaderboard: $e');
    }
  }

  static Future<List<Map<String, dynamic>>> getFriends(String? userId) async {
    if (useMockData || userId == null) {
      await Future.delayed(const Duration(seconds: 1));
      print('Friends response: Mock data for user $userId');
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
      print('Attempting to get friends with URL: $baseUrl/friends');
      final cookieHeader = _accessToken != null ? 'access_token_cookie=$_accessToken' : '';
      final response = await http.get(
        Uri.parse('$baseUrl/friends'),
        headers: {
          if (cookieHeader.isNotEmpty) 'Cookie': cookieHeader,
        },
      ).timeout(const Duration(seconds: 30), onTimeout: () {
          print('Friends request timed out');
          throw Exception('Friends request timed out. Please try again later.');
        });
      print('Friends response: ${response.statusCode} - ${response.body}');
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data is List) {
          return data.cast<Map<String, dynamic>>();
        } else {
          throw Exception('Unexpected response format: ${response.body}');
        }
      }
      throw Exception('Failed to fetch friends: ${response.statusCode} - ${response.body}');
    } catch (e) {
      print('Friends error: $e');
      throw Exception('Failed to fetch friends: $e');
    }
  }

  // New getNotifications method
  static Future<List<Map<String, dynamic>>> getNotifications(String? userId) async {
    if (useMockData || userId == null) {
      await Future.delayed(const Duration(seconds: 1));
      print('Notifications response: Mock data for user $userId');
      return [
        {
          'id': 'notif_1',
          'title': 'Game Win',
          'message': 'You won a game against Player123!',
          'time': DateTime.now().subtract(Duration(hours: 1)).toIso8601String(),
          'isRead': false,
        },
        {
          'id': 'notif_2',
          'title': 'Achievement Unlocked',
          'message': 'You earned the "Puzzle Master" badge!',
          'time': DateTime.now().subtract(Duration(days: 1)).toIso8601String(),
          'isRead': false,
        },
        {
          'id': 'notif_3',
          'title': 'Friend Request',
          'message': 'Player456 sent you a friend request.',
          'time': DateTime.now().subtract(Duration(days: 2)).toIso8601String(),
          'isRead': false,
        },
      ];
    }
    try {
      print('Attempting to get notifications with URL: $baseUrl/notifications');
      final cookieHeader = _accessToken != null ? 'access_token_cookie=$_accessToken' : '';
      final response = await http.get(
        Uri.parse('$baseUrl/notifications'),
        headers: {
          if (cookieHeader.isNotEmpty) 'Cookie': cookieHeader,
        },
      ).timeout(const Duration(seconds: 30), onTimeout: () {
          print('Notifications request timed out');
          throw Exception('Notifications request timed out. Please try again later.');
        });
      print('Notifications response: ${response.statusCode} - ${response.body}');
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data is List) {
          return data.cast<Map<String, dynamic>>();
        } else {
          throw Exception('Unexpected response format: ${response.body}');
        }
      }
      throw Exception('Failed to fetch notifications: ${response.statusCode} - ${response.body}');
    } catch (e) {
      print('Notifications error: $e');
      throw Exception('Failed to fetch notifications: $e');
    }
  }

  // Mark notification as read
  static Future<void> markNotificationRead(String? userId, String notificationId) async {
    if (useMockData || userId == null) {
      print('Marked notification $notificationId as read (mock)');
      return;
    }
    try {
      print('Attempting to mark notification read with URL: $baseUrl/notifications/$notificationId/read');
      final cookieHeader = _accessToken != null ? 'access_token_cookie=$_accessToken' : '';
      final response = await http.post(
        Uri.parse('$baseUrl/notifications/$notificationId/read'),
        headers: {
          'Content-Type': 'application/json',
          'X-CSRF-TOKEN': _csrfToken ?? '',
          if (cookieHeader.isNotEmpty) 'Cookie': cookieHeader,
        },
      ).timeout(const Duration(seconds: 30), onTimeout: () {
          print('Mark notification read request timed out');
          throw Exception('Mark notification read request timed out. Please try again later.');
        });
      print('Mark notification read response: ${response.statusCode} - ${response.body}');
      if (response.statusCode != 200) {
        throw Exception('Failed to mark notification read: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print('Mark notification read error: $e');
      throw Exception('Failed to mark notification read: $e');
    }
  }
}
