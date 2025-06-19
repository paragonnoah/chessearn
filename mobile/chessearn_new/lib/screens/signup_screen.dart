import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:country_code_picker/country_code_picker.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:chessearn_new/screens/main_screen.dart';
import 'login_screen.dart';
import '../services/api_service.dart';
import '../theme.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> with SingleTickerProviderStateMixin {
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _usernameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  String countryCode = '+1';
  String errorMessage = '';
  bool isLoading = false;

  late AnimationController _animController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _pulseAnimation;

  final GoogleSignIn _googleSignIn = GoogleSignIn(scopes: ['email', 'profile']);

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      duration: const Duration(milliseconds: 1300),
      vsync: this,
    )..forward();

    _fadeAnimation = CurvedAnimation(
      parent: _animController,
      curve: Curves.easeOut,
    );

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.09).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeInOut),
    );
    _animController.repeat(reverse: true);
  }

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
    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(_emailController.text.trim())) {
      setState(() {
        errorMessage = 'Invalid email format';
        isLoading = false;
      });
      return;
    }
    if (!RegExp(r'^\d+$').hasMatch(_phoneController.text.trim())) {
      setState(() {
        errorMessage = 'Phone number must contain only digits';
        isLoading = false;
      });
      return;
    }

    try {
      final response = await ApiService.register(
        firstName: _firstNameController.text.trim(),
        lastName: _lastNameController.text.trim(),
        email: _emailController.text.trim(),
        username: _usernameController.text.trim(),
        phoneNumber: '$countryCode${_phoneController.text.trim()}',
        password: _passwordController.text.trim(),
      );
      if (response.statusCode == 200) {
        final responseBody = jsonDecode(response.body);
        if (responseBody['message'] == 'User created') {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const MainScreen(userId: null)),
          );
        } else {
          setState(() {
            errorMessage = 'Unexpected response: ${response.body}';
          });
        }
      } else if (response.statusCode == 400) {
        setState(() {
          errorMessage = 'Signup failed: ${jsonDecode(response.body)['message'] ?? response.body}';
        });
      } else {
        setState(() {
          errorMessage = 'Signup failed: ${response.statusCode} - ${response.body}';
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
              MaterialPageRoute(builder: (context) => MainScreen(userId: userId.isNotEmpty ? userId : null)),
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
      });
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _usernameController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = ChessEarnTheme.themeColors;
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              theme['brand-gradient-start']!,
              theme['brand-gradient-end']!,
              theme['brand-dark']!,
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            stops: const [0.0, 0.6, 1.0],
          ),
        ),
        child: SafeArea(
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    AnimatedBuilder(
                      animation: _pulseAnimation,
                      builder: (context, child) {
                        return Transform.scale(
                          scale: _pulseAnimation.value,
                          child: Container(
                            padding: const EdgeInsets.all(18),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: theme['brand-accent']!.withOpacity(0.3),
                                  blurRadius: 30,
                                  spreadRadius: 10,
                                ),
                              ],
                            ),
                            child: Icon(
                              Icons.sports_esports_rounded,
                              size: 60,
                              color: theme['brand-accent'],
                            ),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 18),
                    ShaderMask(
                      shaderCallback: (bounds) => LinearGradient(
                        colors: [
                          theme['text-light']!,
                          theme['brand-accent']!,
                        ],
                      ).createShader(bounds),
                      child: const Text(
                        'Join ChessEarn',
                        style: TextStyle(
                          fontSize: 36,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          letterSpacing: 2,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Sign up and start playing to earn!',
                      style: TextStyle(
                        fontSize: 16,
                        color: theme['text-muted'],
                        fontWeight: FontWeight.w400,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 32),
                    _buildInputField(
                      controller: _firstNameController,
                      label: 'First Name',
                      icon: Icons.person_outline,
                      theme: theme,
                    ),
                    _buildInputField(
                      controller: _lastNameController,
                      label: 'Last Name',
                      icon: Icons.person_outline,
                      theme: theme,
                    ),
                    _buildInputField(
                      controller: _emailController,
                      label: 'Email',
                      icon: Icons.mail_outline,
                      theme: theme,
                      keyboardType: TextInputType.emailAddress,
                    ),
                    _buildInputField(
                      controller: _usernameController,
                      label: 'Username',
                      icon: Icons.alternate_email,
                      theme: theme,
                    ),
                    Row(
                      children: [
                        SizedBox(
                          width: MediaQuery.of(context).size.width * 0.28,
                          child: CountryCodePicker(
                            onChanged: (code) => setState(() => countryCode = code.dialCode!),
                            initialSelection: 'US',
                            favorite: const ['+1'],
                            showCountryOnly: false,
                            showOnlyCountryWhenClosed: false,
                            alignLeft: false,
                            dialogBackgroundColor: theme['surface-card'],
                            textStyle: TextStyle(color: theme['text-light']),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _buildInputField(
                            controller: _phoneController,
                            label: 'Phone Number',
                            icon: Icons.phone,
                            theme: theme,
                            keyboardType: TextInputType.phone,
                          ),
                        ),
                      ],
                    ),
                    _buildInputField(
                      controller: _passwordController,
                      label: 'Password',
                      icon: Icons.lock_outline,
                      theme: theme,
                      isPassword: true,
                    ),
                    if (errorMessage.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 12),
                        child: Text(errorMessage, style: TextStyle(color: theme['brand-danger'], fontWeight: FontWeight.w600)),
                      ),
                    const SizedBox(height: 28),
                    isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : Column(
                            children: [
                              _buildLoginButton(
                                text: 'Sign Up',
                                icon: Icons.person_add_rounded,
                                onPressed: _signup,
                                gradient: LinearGradient(
                                  colors: [
                                    theme['brand-accent']!,
                                    theme['btn-primary-hover']!,
                                  ],
                                ),
                                theme: theme,
                              ),
                              const SizedBox(height: 12),
                              _buildLoginButton(
                                text: 'Continue with Google',
                                icon: Icons.g_mobiledata,
                                onPressed: _googleSignup,
                                gradient: LinearGradient(
                                  colors: [
                                    Colors.red.shade300,
                                    theme['brand-accent']!.withOpacity(0.8),
                                  ],
                                ),
                                theme: theme,
                              ),
                            ],
                          ),
                    const SizedBox(height: 18),
                    TextButton(
                      onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const LoginScreen())),
                      child: Text('Already have an account? Log in', style: TextStyle(color: theme['text-muted'])),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required Map<String, Color?> theme,
    TextInputType? keyboardType,
    bool isPassword = false,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: TextField(
        controller: controller,
        obscureText: isPassword,
        keyboardType: keyboardType,
        style: TextStyle(color: theme['text-light']),
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, color: theme['brand-accent']),
          labelStyle: TextStyle(color: theme['text-muted']),
          filled: true,
          fillColor: theme['surface-light']!.withOpacity(0.25),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }

  Widget _buildLoginButton({
    required String text,
    required IconData icon,
    required VoidCallback onPressed,
    required LinearGradient gradient,
    required Map<String, Color?> theme,
  }) {
    return Container(
      width: double.infinity,
      height: 54,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: gradient,
        boxShadow: [
          BoxShadow(
            color: theme['brand-accent']!.withOpacity(0.18),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ElevatedButton.icon(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          foregroundColor: Colors.white,
          elevation: 0,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        icon: Icon(icon, size: 22),
        label: Text(
          text,
          style: const TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w600,
            letterSpacing: 1.0,
          ),
        ),
      ),
    );
  }
}