import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:country_code_picker/country_code_picker.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'game_screen.dart';
import 'login_screen.dart';
import '../services/api_service.dart';
import '../theme.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _usernameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  String countryCode = '+1';
  String errorMessage = '';
  bool isLoading = false;

  final GoogleSignIn _googleSignIn = GoogleSignIn(scopes: ['email', 'profile']);

  Future<void> _signup() async {
    setState(() {
      isLoading = true;
      errorMessage = '';
    });

    if (_firstNameController.text.isEmpty || _lastNameController.text.isEmpty || _emailController.text.isEmpty ||
        _usernameController.text.isEmpty || _phoneController.text.isEmpty || _passwordController.text.isEmpty) {
      setState(() {
        errorMessage = 'All fields are required';
        isLoading = false;
      });
      return;
    }
    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(_emailController.text)) {
      setState(() {
        errorMessage = 'Invalid email format';
        isLoading = false;
      });
      return;
    }
    if (!RegExp(r'^\d+$').hasMatch(_phoneController.text)) {
      setState(() {
        errorMessage = 'Phone number must contain only digits';
        isLoading = false;
      });
      return;
    }

    try {
      final response = await ApiService.register(
        firstName: _firstNameController.text,
        lastName: _lastNameController.text,
        email: _emailController.text,
        username: _usernameController.text,
        phoneNumber: '$countryCode${_phoneController.text}',
        password: _passwordController.text,
      );
      if (response.statusCode == 201) {
        final responseBody = jsonDecode(response.body);
        final userId = responseBody['id']?.toString() ?? '';
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => GameScreen(userId: userId.isNotEmpty ? userId : null)),
        );
      } else if (response.statusCode == 400) {
        setState(() {
          errorMessage = 'Signup failed: ${response.statusCode} - ${response.body}';
        });
      } else {
        setState(() {
          errorMessage = 'Signup failed: ${response.statusCode} - ${response.body}';
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = 'Network error: $e';
        // Allow guest play on signup failure
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const GameScreen(userId: null)),
        );
      });
    } finally {
      setState(() => isLoading = false);
    }
  }

  Future<void> _googleSignup() async {
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
            Uri.parse('${ApiService.baseUrl}/google/mobile'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({'id_token': idToken}),
          );
          if (response.statusCode == 200) {
            final responseBody = jsonDecode(response.body);
            final userId = responseBody['id']?.toString() ?? '';
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => GameScreen(userId: userId.isNotEmpty ? userId : null)),
            );
          } else {
            setState(() {
              errorMessage = 'Google signup failed: ${response.statusCode} - ${response.body}';
            });
          }
        }
      }
    } catch (e) {
      setState(() {
        errorMessage = 'Google signup failed: $e';
        // Allow guest play on signup failure
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const GameScreen(userId: null)),
        );
      });
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Sign Up')),
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
                const Text('Join ChessEarn', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white)),
                const SizedBox(height: 30),
                TextField(
                  controller: _firstNameController,
                  decoration: InputDecoration(
                    labelText: 'First Name',
                    labelStyle: TextStyle(color: ChessEarnTheme.themeColors['text-muted']),
                    filled: true,
                    fillColor: ChessEarnTheme.themeColors['surface-light']!.withOpacity(0.3),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                  ),
                  style: TextStyle(color: ChessEarnTheme.themeColors['text-light']),
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: _lastNameController,
                  decoration: InputDecoration(
                    labelText: 'Last Name',
                    labelStyle: TextStyle(color: ChessEarnTheme.themeColors['text-muted']),
                    filled: true,
                    fillColor: ChessEarnTheme.themeColors['surface-light']!.withOpacity(0.3),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                  ),
                  style: TextStyle(color: ChessEarnTheme.themeColors['text-light']),
                ),
                const SizedBox(height: 20),
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
                const SizedBox(height: 20),
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
                const SizedBox(height: 20),
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
                          ElevatedButton(
                            onPressed: _signup,
                            child: const Text('Sign Up', style: TextStyle(fontSize: 18)),
                          ),
                          const SizedBox(height: 10),
                          ElevatedButton(
                            onPressed: _googleSignup,
                            child: const Row(mainAxisSize: MainAxisSize.min, children: [Icon(Icons.g_mobiledata), SizedBox(width: 5), Text('Google', style: TextStyle(fontSize: 18))]),
                          ),
                        ],
                      ),
                const SizedBox(height: 20),
                TextButton(
                  onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const LoginScreen())),
                  child: Text('Already have an account? Log in', style: TextStyle(color: ChessEarnTheme.themeColors['text-muted'])),
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
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _usernameController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}