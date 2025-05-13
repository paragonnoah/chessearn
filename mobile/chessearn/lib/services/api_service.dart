import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  static const String baseUrl = 'https://v2.chessearn.com';
  static String? _csrfToken;
  static String? _accessToken;

  static Future<void> initialize() async {
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

  static initializeCookieJar() {}
}