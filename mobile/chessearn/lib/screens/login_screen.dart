import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:country_code_picker/country_code_picker.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'game_screen.dart';
import 'signup_screen.dart';
import '../services/api_service.dart';
import '../theme.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  String loginMethod = 'username';
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  String countryCode = '+1';
  String errorMessage = '';
  bool isLoading = false;

  final GoogleSignIn _googleSignIn = GoogleSignIn(scopes: ['email', 'profile']);

  Future<void> _login() async {
    setState(() {
      isLoading = true;
      errorMessage = '';
    });

    try {
      String identifier;
      switch (loginMethod) {
        case 'username':
          identifier = _usernameController.text;
          break;
        case 'email':
          if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(_emailController.text)) {
            setState(() {
              errorMessage = 'Invalid email format';
              isLoading = false;
            });
            return;
          }
          identifier = _emailController.text;
          break;
        case 'phone':
          if (!RegExp(r'^\d+$').hasMatch(_phoneController.text)) {
            setState(() {
              errorMessage = 'Phone number must contain only digits';
              isLoading = false;
            });
            return;
          }
          identifier = '$countryCode${_phoneController.text}';
          break;
        default:
          setState(() {
            errorMessage = 'Invalid login method';
            isLoading = false;
          });
          return;
      }

      final result = await ApiService.login(identifier: identifier, password: _passwordController.text, prefs: null);
      final response = result['response'] as http.Response;
      final userId = result['userId'] as String;

      if (response.statusCode == 200) {
        if (userId.isEmpty) {
          setState(() {
            errorMessage = 'Login successful, but user ID not found in response';
            isLoading = false;
          });
          return;
        }
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => GameScreen(userId: userId)),
        );
      } else {
        setState(() {
          errorMessage = 'Login failed: ${response.statusCode} - ${response.body}';
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = 'Network error: $e';
      });
    } finally {
      setState(() => isLoading = false);
    }
  }

  Future<void> _googleLogin() async {
    setState(() {
      isLoading = true;
      errorMessage = '';
    });

    try {
      final account = await _googleSignIn.signIn();
      if (account != null) {
        final authHeaders = await account.authHeaders;
        final idToken = authHeaders['Authorization']?.split(' ')[1];
        if (idToken != null) {
          final response = await http.post(
            Uri.parse('${ApiService.baseUrl}/google/mobile'), // Placeholder endpoint
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({'id_token': idToken}),
          );
          if (response.statusCode == 200) {
            final responseBody = jsonDecode(response.body);
            final userId = responseBody['id']?.toString() ?? ''; // Adjusted to 'id' (hypothetical)
            if (userId.isEmpty) {
              setState(() {
                errorMessage = 'Google login successful, but user ID not found in response';
                isLoading = false;
              });
              return;
            }
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => GameScreen(userId: userId)),
            );
          } else {
            setState(() {
              errorMessage = 'Google login failed: ${response.statusCode} - ${response.body}';
            });
          }
        }
      }
    } catch (e) {
      setState(() {
        errorMessage = 'Google login failed: $e';
      });
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Log In')),
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
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('Log In to ChessEarn', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white)),
                const SizedBox(height: 30),
                DropdownButton<String>(
                  value: loginMethod,
                  items: ['username', 'email', 'phone', 'social'].map((String value) => DropdownMenuItem<String>(
                    value: value,
                    child: Text(value.toUpperCase()),
                  )).toList(),
                  onChanged: (String? newValue) => setState(() => loginMethod = newValue!),
                  dropdownColor: ChessEarnTheme.themeColors['surface-light']!.withOpacity(0.5),
                  style: TextStyle(color: ChessEarnTheme.themeColors['text-light']),
                ),
                const SizedBox(height: 20),
                if (loginMethod == 'username')
                  TextField(
                    controller: _usernameController,
                    decoration: InputDecoration(
                      labelText: 'Username',
                      labelStyle: TextStyle(color: ChessEarnTheme.themeColors['text-muted']),
                      filled: true,
                      fillColor: ChessEarnTheme.themeColors['surface-light']!.withOpacity(0.3),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                    ),
                    style: TextStyle(color: ChessEarnTheme.themeColors['text-light']),
                  ),
                if (loginMethod == 'email')
                  TextField(
                    controller: _emailController,
                    decoration: InputDecoration(
                      labelText: 'Email',
                      labelStyle: TextStyle(color: ChessEarnTheme.themeColors['text-muted']),
                      filled: true,
                      fillColor: ChessEarnTheme.themeColors['surface-light']!.withOpacity(0.3),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                    ),
                    style: TextStyle(color: ChessEarnTheme.themeColors['text-light']),
                  ),
                if (loginMethod == 'phone')
                  Row(
                    children: [
                      Container(
                        width: MediaQuery.of(context).size.width * 0.3,
                        child: CountryCodePicker(
                          onChanged: (code) => setState(() => countryCode = code.dialCode!),
                          initialSelection: 'US',
                          favorite: ['+1'],
                          showCountryOnly: false,
                          showOnlyCountryWhenClosed: false,
                          alignLeft: false,
                        ),
                      ),
                      Expanded(
                        child: TextField(
                          controller: _phoneController,
                          decoration: InputDecoration(
                            labelText: 'Phone Number',
                            labelStyle: TextStyle(color: ChessEarnTheme.themeColors['text-muted']),
                            filled: true,
                            fillColor: ChessEarnTheme.themeColors['surface-light']!.withOpacity(0.3),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                          ),
                          style: TextStyle(color: ChessEarnTheme.themeColors['text-light']),
                        ),
                      ),
                    ],
                  ),
                if (loginMethod != 'social')
                  Column(
                    children: [
                      const SizedBox(height: 20),
                      TextField(
                        controller: _passwordController,
                        decoration: InputDecoration(
                          labelText: 'Password',
                          labelStyle: TextStyle(color: ChessEarnTheme.themeColors['text-muted']),
                          filled: true,
                          fillColor: ChessEarnTheme.themeColors['surface-light']!.withOpacity(0.3),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                        ),
                        obscureText: true,
                        style: TextStyle(color: ChessEarnTheme.themeColors['text-light']),
                      ),
                    ],
                  ),
                if (errorMessage.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 10),
                    child: Text(errorMessage, style: TextStyle(color: ChessEarnTheme.themeColors['brand-danger'])),
                  ),
                const SizedBox(height: 20),
                isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : Column(
                        children: [
                          if (loginMethod == 'social')
                            ElevatedButton(
                              onPressed: _googleLogin,
                              child: const Row(mainAxisSize: MainAxisSize.min, children: [Icon(Icons.g_mobiledata), SizedBox(width: 5), Text('Google', style: TextStyle(fontSize: 18))]),
                            )
                          else
                            ElevatedButton(
                              onPressed: _login,
                              child: const Text('Log In', style: TextStyle(fontSize: 18)),
                            ),
                          TextButton(
                            onPressed: () async {
                              await ApiService.logout();
                              Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const LoginScreen()));
                            },
                            child: Text('Log out (for testing)', style: TextStyle(color: ChessEarnTheme.themeColors['text-muted'])),
                          ),
                        ],
                      ),
                const SizedBox(height: 20),
                TextButton(
                  onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const SignupScreen())),
                  child: Text('Don’t have an account? Sign up', style: TextStyle(color: ChessEarnTheme.themeColors['text-muted'])),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}