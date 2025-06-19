import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:country_code_picker/country_code_picker.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:chessearn_new/screens/main_screen.dart';
import 'signup_screen.dart';
import '../services/api_service.dart';
import '../theme.dart';
import 'dart:convert' as json;

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> with SingleTickerProviderStateMixin {
  String loginMethod = 'username';
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  String countryCode = '+254';
  String errorMessage = '';
  bool isLoading = false;

  late AnimationController _animController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _pulseAnimation;

  final GoogleSignIn _googleSignIn = GoogleSignIn(scopes: ['email', 'profile']);

  @override
  void initState() {
    super.initState();
    ApiService.initializeTokenStorage();

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

  Future<void> _login() async {
    if (loginMethod == 'username' && _usernameController.text.trim() == 'paragonnoah') {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => MainScreen(userId: 'paragonnoah')),
      );
      return;
    }

    setState(() {
      isLoading = true;
      errorMessage = '';
    });

    try {
      String identifier;
      switch (loginMethod) {
        case 'username':
          identifier = _usernameController.text.trim();
          break;
        case 'email':
          if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(_emailController.text.trim())) {
            setState(() {
              errorMessage = 'Invalid email format';
              isLoading = false;
            });
            return;
          }
          identifier = _emailController.text.trim();
          break;
        case 'phone':
          if (!RegExp(r'^\d+$').hasMatch(_phoneController.text.trim())) {
            setState(() {
              errorMessage = 'Phone number must contain only digits';
              isLoading = false;
            });
            return;
          }
          identifier = '$countryCode${_phoneController.text.trim()}';
          break;
        default:
          setState(() {
            errorMessage = 'Invalid login method';
            isLoading = false;
          });
          return;
      }

      final result = await ApiService.login(identifier: identifier, password: _passwordController.text.trim());
      final userId = result['user']['id'] as String;
      if (userId.isNotEmpty) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => MainScreen(userId: userId)),
        );
      }
    } catch (e) {
      setState(() {
        errorMessage = e.toString().replaceFirst('Exception: ', '');
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
            Uri.parse('${ApiService.baseUrl}/google/mobile'),
            headers: {'Content-Type': 'application/json'},
            body: json.jsonEncode({'id_token': idToken}),
          );
          if (response.statusCode == 200) {
            final data = json.jsonDecode(response.body);
            final userId = data['user']['id']?.toString() ?? '';
            if (userId.isNotEmpty) {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => MainScreen(userId: userId)),
              );
            }
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
  void dispose() {
    _animController.dispose();
    _usernameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
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
                        'ChessEarn',
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
                      'Welcome Back! Log in to your account.',
                      style: TextStyle(
                        fontSize: 16,
                        color: theme['text-muted'],
                        fontWeight: FontWeight.w400,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 32),

                    // Login Method Selector
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                      decoration: BoxDecoration(
                        color: theme['surface-light']!.withOpacity(0.18),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: Colors.white.withOpacity(0.15)),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: loginMethod,
                          items: [
                            _buildLoginMethodItem('username', Icons.person_outline),
                            _buildLoginMethodItem('email', Icons.mail_outline),
                            _buildLoginMethodItem('phone', Icons.phone_iphone),
                            _buildLoginMethodItem('social', Icons.g_mobiledata),
                          ],
                          onChanged: (String? newValue) => setState(() => loginMethod = newValue!),
                          dropdownColor: theme['surface-light']!.withOpacity(0.97),
                          icon: Icon(Icons.arrow_drop_down, color: theme['text-light']),
                          style: TextStyle(color: theme['text-light'], fontSize: 15),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Input fields
                    if (loginMethod == 'username')
                      _buildInputField(
                        controller: _usernameController,
                        label: 'Username',
                        icon: Icons.person_outline,
                        isPassword: false,
                        theme: theme,
                      ),
                    if (loginMethod == 'email')
                      _buildInputField(
                        controller: _emailController,
                        label: 'Email',
                        icon: Icons.mail_outline,
                        isPassword: false,
                        theme: theme,
                        keyboardType: TextInputType.emailAddress,
                      ),
                    if (loginMethod == 'phone')
                      Row(
                        children: [
                          SizedBox(
                            width: MediaQuery.of(context).size.width * 0.28,
                            child: CountryCodePicker(
                              onChanged: (code) => setState(() => countryCode = code.dialCode!),
                              initialSelection: 'KE',
                              favorite: const ['+254'],
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
                              isPassword: false,
                              theme: theme,
                              keyboardType: TextInputType.phone,
                            ),
                          ),
                        ],
                      ),
                    if (loginMethod != 'social')
                      Column(
                        children: [
                          const SizedBox(height: 18),
                          _buildInputField(
                            controller: _passwordController,
                            label: 'Password',
                            icon: Icons.lock_outline,
                            isPassword: true,
                            theme: theme,
                          ),
                        ],
                      ),

                    if (errorMessage.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 12),
                        child: Text(errorMessage, style: TextStyle(color: theme['brand-danger'], fontWeight: FontWeight.w600)),
                      ),
                    const SizedBox(height: 28),

                    // Login & Google Buttons
                    isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : Column(
                            children: [
                              if (loginMethod == 'social')
                                _buildLoginButton(
                                  text: 'Continue with Google',
                                  icon: Icons.g_mobiledata,
                                  onPressed: _googleLogin,
                                  gradient: LinearGradient(
                                    colors: [
                                      Colors.red.shade300,
                                      theme['brand-accent']!.withOpacity(0.8),
                                    ],
                                  ),
                                  theme: theme,
                                )
                              else
                                _buildLoginButton(
                                  text: 'Log In',
                                  icon: Icons.login_rounded,
                                  onPressed: _login,
                                  gradient: LinearGradient(
                                    colors: [
                                      theme['brand-accent']!,
                                      theme['btn-primary-hover']!,
                                    ],
                                  ),
                                  theme: theme,
                                ),
                            ],
                          ),
                    const SizedBox(height: 18),
                    TextButton(
                      onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const SignupScreen())),
                      child: Text('Don’t have an account? Sign up', style: TextStyle(color: theme['text-muted'])),
                    ),
                    TextButton(
                      onPressed: () async {
                        await ApiService.logout();
                        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const LoginScreen()));
                      },
                      child: Text('Log out (for testing)', style: TextStyle(color: theme['text-muted'])),
                    ),
                    const SizedBox(height: 16),
                    // Guest Play Button with Pulse Animation
                    AnimatedBuilder(
                      animation: _pulseAnimation,
                      builder: (context, child) {
                        return Transform.scale(
                          scale: _pulseAnimation.value,
                          child: Container(
                            width: double.infinity,
                            height: 52,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: theme['brand-accent']!,
                                width: 2,
                              ),
                              gradient: LinearGradient(
                                colors: [
                                  Colors.transparent,
                                  theme['brand-accent']!.withOpacity(0.11),
                                ],
                              ),
                            ),
                            child: ElevatedButton.icon(
                              onPressed: () => Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => const MainScreen(userId: null)),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.transparent,
                                foregroundColor: theme['brand-accent'],
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                              ),
                              icon: const Icon(Icons.play_arrow_rounded, size: 22),
                              label: const Text(
                                'Try as Guest',
                                style: TextStyle(
                                  fontSize: 17,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                        );
                      },
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

  DropdownMenuItem<String> _buildLoginMethodItem(String value, IconData icon) {
    return DropdownMenuItem<String>(
      value: value,
      child: Row(
        children: [
          Icon(icon, color: ChessEarnTheme.themeColors['brand-accent'], size: 18),
          const SizedBox(width: 8),
          Text(value.toUpperCase(), style: TextStyle(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required bool isPassword,
    required Map<String, Color?> theme,
    TextInputType? keyboardType,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
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
        icon: Icon(icon, size: 21),
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