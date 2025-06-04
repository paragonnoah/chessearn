
import 'package:flutter/material.dart';
import 'package:chessearn_new/screens/more/profile_more_screen.dart';
import 'package:chessearn_new/screens/wallet_screen.dart';
import 'package:chessearn_new/screens/more/messages_more_screen.dart';
import 'package:chessearn_new/screens/more/statistics_more_screen.dart';
import 'package:chessearn_new/screens/more/notifications_more_screen.dart';
import 'package:chessearn_new/screens/more/settings_more_screen.dart';
import 'package:chessearn_new/screens/more/friends_more_screen.dart';
import 'package:chessearn_new/screens/scoreboard_screen.dart'; // Added ScoreboardScreen import
import 'package:chessearn_new/services/api_service.dart';
import 'package:chessearn_new/screens/home_screen.dart';
import 'package:chessearn_new/theme.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:http/http.dart' as http;
import 'dart:convert' as json;

class MoreScreen extends StatefulWidget {
  final String? userId;

  const MoreScreen({super.key, required this.userId});

  @override
  State<MoreScreen> createState() => _MoreScreenState();
}

class _MoreScreenState extends State<MoreScreen> with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _progressController;
  late Animation<double> _fadeAnimation;
  bool _isLoading = false;
  double userProgress = 0.0;
  int userLevel = 0;
  int userXP = 0;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _progressController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeOut),
    );
    _fadeController.forward();
    _progressController.forward();
    _fetchUserStats();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _progressController.dispose();
    super.dispose();
  }

  Future<void> _fetchUserStats() async {
    if (widget.userId == null) return;
    try {
      final stats = await ApiService.getUserStats(widget.userId);
      setState(() {
        userXP = stats['xp'] ?? 0;
        userLevel = (stats['xp'] ~/ 1000); // Derive level from XP
        userProgress = (stats['xp'] % 1000) / 1000; // Progress to next level
      });
    } catch (e) {
      _showErrorSnackBar('Failed to load stats: $e');
    }
  }

  Future<void> _logout(BuildContext context) async {
    _showLoadingDialog(context);
    try {
      await ApiService.logout();
      Navigator.of(context).pop(); // Close loading dialog
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const HomeScreen()),
      );
    } catch (e) {
      Navigator.of(context).pop(); // Close loading dialog
      _showErrorSnackBar('Logout failed: $e');
    }
  }

  Future<void> _initMpesa() async {
    if (_isLoading) return;
    setState(() => _isLoading = true);

    try {
      final phoneNumber = await _showPhoneNumberDialog();
      if (phoneNumber == null || phoneNumber.isEmpty) {
        setState(() => _isLoading = false);
        return;
      }

      // TODO: Replace with actual M-Pesa credentials
      const String consumerKey = 'your_consumer_key';
      const String consumerSecret = 'your_consumer_secret';
      const String shortCode = 'your_shortcode';
      const String passkey = 'your_passkey';
      const String callbackUrl = 'https://your-callback-url.com/callback';

      final auth = json.base64Encode(json.utf8.encode('$consumerKey:$consumerSecret'));
      final tokenResponse = await http.get(
        Uri.parse('https://sandbox.safaricom.co.ke/oauth/v1/generate?grant_type=client_credentials'),
        headers: {'Authorization': 'Basic $auth'},
      );

      if (tokenResponse.statusCode != 200) {
        throw Exception('Failed to obtain M-Pesa access token');
      }

      final tokenData = json.jsonDecode(tokenResponse.body);
      final accessToken = tokenData['access_token'];

      final timestamp = DateTime.now()
          .toIso8601String()
          .replaceAll(RegExp(r'[^0-9]'), '')
          .substring(0, 14);
      final password = json.base64Encode(json.utf8.encode('$shortCode$passkey$timestamp'));

      final stkResponse = await http.post(
        Uri.parse('https://sandbox.safaricom.co.ke/mpesa/stkpush/v1/processrequest'),
        headers: {
          'Authorization': 'Bearer $accessToken',
          'Content-Type': 'application/json',
        },
        body: json.jsonEncode({
          'BusinessShortCode': shortCode,
          'Password': password,
          'Timestamp': timestamp,
          'TransactionType': 'CustomerPayBillOnline',
          'Amount': '10',
          'PartyA': phoneNumber,
          'PartyB': shortCode,
          'PhoneNumber': phoneNumber,
          'CallBackURL': callbackUrl,
          'AccountReference': 'ChessEarn${widget.userId ?? "Guest"}',
          'TransactionDesc': 'ChessEarn Game Credits',
        }),
      );

      if (stkResponse.statusCode == 200) {
        final responseData = json.jsonDecode(stkResponse.body);
        if (responseData['ResponseCode'] == '0') {
          _showSuccessSnackBar('M-Pesa payment initiated! Check your phone for the prompt.');
        } else {
          throw Exception(responseData['errorMessage'] ?? 'STK Push failed');
        }
      } else {
        throw Exception('M-Pesa STK Push failed');
      }
    } catch (e) {
      _showErrorSnackBar('M-Pesa payment failed: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _payWithCard() async {
    if (_isLoading) return;
    setState(() => _isLoading = true);

    try {
      // TODO: Replace with your actual backend URL
      final response = await http.post(
        Uri.parse('https://your-backend.com/create-payment-intent'),
        headers: {'Content-Type': 'application/json'},
        body: json.jsonEncode({
          'amount': 1000,
          'currency': 'usd',
          'metadata': {
            'user_id': widget.userId ?? 'guest',
            'product': 'chess_credits',
          },
        }),
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to create payment intent');
      }

      final data = json.jsonDecode(response.body);
      final clientSecret = data['clientSecret'];

      await Stripe.instance.initPaymentSheet(
        paymentSheetParameters: SetupPaymentSheetParameters(
          merchantDisplayName: 'ChessEarn',
          paymentIntentClientSecret: clientSecret,
          allowsDelayedPaymentMethods: true,
          style: ThemeMode.light,
          appearance: const PaymentSheetAppearance(
            primaryButton: PaymentSheetPrimaryButtonAppearance(
              colors: PaymentSheetPrimaryButtonTheme(
                light: PaymentSheetPrimaryButtonThemeColors(
                  background: Color(0xFF2ECC71),
                ),
              ),
            ),
          ),
        ),
      );

      await Stripe.instance.presentPaymentSheet();

      _showSuccessSnackBar('Payment successful! Credits added to your account.');
    } on StripeException catch (e) {
      if (e.error.code != FailureCode.Canceled) {
        _showErrorSnackBar('Payment failed: ${e.error.message}');
      }
    } catch (e) {
      _showErrorSnackBar('Payment failed: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<String?> _showPhoneNumberDialog() async {
    String phoneNumber = '';
    return showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        final theme = ChessEarnTheme.themeData;
        return AlertDialog(
          backgroundColor: ChessEarnTheme.getColor('surface-card'),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Row(
            children: [
              Icon(Icons.phone, color: ChessEarnTheme.getColor('brand-accent')),
              const SizedBox(width: 8),
              Text('Enter Phone Number', style: theme.textTheme.titleLarge),
            ],
          ),
          content: TextField(
            onChanged: (value) => phoneNumber = value,
            keyboardType: TextInputType.phone,
            decoration: InputDecoration(
              hintText: '254712345678',
              prefixText: '+',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: ChessEarnTheme.getColor('border-soft')),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Cancel', style: theme.textTheme.bodyMedium?.copyWith(color: ChessEarnTheme.getColor('text-muted'))),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(phoneNumber),
              style: ElevatedButton.styleFrom(
                backgroundColor: ChessEarnTheme.getColor('brand-accent'),
                foregroundColor: ChessEarnTheme.getColor('text-light'),
              ),
              child: Text('Proceed', style: theme.textTheme.bodyMedium),
            ),
          ],
        );
      },
    );
  }

  void _showLoadingDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        final theme = ChessEarnTheme.themeData;
        return Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: ChessEarnTheme.getColor('surface-card'),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(
                  color: ChessEarnTheme.getColor('brand-accent'),
                ),
                const SizedBox(height: 16),
                Text('Processing...', style: theme.textTheme.bodyLarge),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.check_circle, color: ChessEarnTheme.getColor('success')),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: ChessEarnTheme.getColor('success'),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.error, color: ChessEarnTheme.getColor('text-light')),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: ChessEarnTheme.getColor('error'),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = ChessEarnTheme.themeData;
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(gradient: ChessEarnTheme.backgroundGradient),
        child: SafeArea(
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: CustomScrollView(
              slivers: [
                // Custom App Bar
                SliverToBoxAdapter(
                  child: Container(
                    padding: const EdgeInsets.all(24),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: ChessEarnTheme.getColor('text-light').withOpacity(0.2),
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 10,
                                offset: const Offset(0, 5),
                              ),
                            ],
                          ),
                          child: Icon(
                            Icons.more_horiz_rounded,
                            color: ChessEarnTheme.getColor('brand-accent'),
                            size: 28,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'More Options',
                                style: theme.textTheme.headlineLarge?.copyWith(
                                  color: ChessEarnTheme.getColor('text-light'),
                                  fontSize: 28,
                                ),
                              ),
                              Text(
                                'Explore More • ${_getTimeOfDayGreeting()}',
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: ChessEarnTheme.getColor('text-light').withOpacity(0.8),
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                        _buildLevelBadge(),
                      ],
                    ),
                  ),
                ),

                // User Info Card (if logged in)
                if (widget.userId != null)
                  SliverToBoxAdapter(
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: ChessEarnTheme.getColor('text-light').withOpacity(0.1),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: ChessEarnTheme.getColor('text-light').withOpacity(0.2)),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              CircleAvatar(
                                radius: 24,
                                backgroundColor: ChessEarnTheme.getColor('brand-accent'),
                                child: Icon(Icons.person, color: ChessEarnTheme.getColor('text-light'), size: 28),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Welcome back!',
                                      style: theme.textTheme.titleMedium?.copyWith(
                                        color: ChessEarnTheme.getColor('text-light'),
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    Text(
                                      'User ID: ${widget.userId}',
                                      style: theme.textTheme.bodyMedium?.copyWith(
                                        color: ChessEarnTheme.getColor('text-muted'),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          // Dynamic Stats
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              _buildStatCard('Level', '$userLevel', Icons.star, Colors.amber),
                              _buildStatCard('XP', _formatNumber(userXP), Icons.stars, Colors.purple),
                              _buildStatCard('Progress', '${(userProgress * 100).toInt()}%', Icons.trending_up, Colors.green),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),

                // Main Menu Items
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate([
                      _buildMenuSection('Account', [
                        _buildMenuItem(Icons.person_rounded, 'Profile', 'View and edit your profile',
                            onTap: widget.userId != null
                                ? () => Navigator.push(context, MaterialPageRoute(builder: (context) => ProfileMoreScreen(userId: widget.userId!)))
                                : null),
                        _buildMenuItem(Icons.account_balance_wallet_rounded, 'Wallet', 'Manage your earnings',
                            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => WalletScreen(userId: widget.userId)))),
                        _buildMenuItem(Icons.bar_chart_rounded, 'Statistics', 'View your game stats',
                            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const StatisticsMoreScreen()))),
                      ]),
                      _buildMenuSection('Social', [
                        _buildMenuItem(Icons.people_rounded, 'Friends', 'Connect with other players',
                            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => FriendsMoreScreen(userId: widget.userId)))),
                        _buildMenuItem(Icons.leaderboard_rounded, 'Leaderboard', 'View top players', // Added Leaderboard item
                            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => ScoreboardScreen(userId: widget.userId)))),
                        _buildMenuItem(Icons.message_rounded, 'Messages', 'Chat with friends',
                            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const MessagesMoreScreen()))),
                        _buildMenuItem(Icons.notifications_rounded, 'Notifications', 'View your notifications',
                            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const NotificationsMoreScreen(userId: '',)))),
                      ]),
                      _buildMenuSection('Payments', [
                        _buildPaymentTile(),
                      ]),
                      _buildMenuSection('App', [
                        _buildMenuItem(Icons.settings_rounded, 'Settings', 'App preferences',
                            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const SettingsMoreScreen()))),
                      ]),
                      const SizedBox(height: 32),
                      // Logout Button
                      if (widget.userId != null)
                        Container(
                          width: double.infinity,
                          height: 56,
                          margin: const EdgeInsets.only(bottom: 24),
                          child: ElevatedButton.icon(
                            onPressed: () => _showLogoutDialog(),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: ChessEarnTheme.getColor('error'),
                              foregroundColor: ChessEarnTheme.getColor('text-light'),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                            ),
                            icon: const Icon(Icons.logout_rounded),
                            label: Text('Logout', style: theme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600)),
                          ),
                        ),
                    ]),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLevelBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Colors.amber, Colors.orange],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.amber.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.star, color: Colors.white, size: 16),
          const SizedBox(width: 4),
          Text(
            'Level $userLevel',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuSection(String title, List<Widget> items) {
    final theme = ChessEarnTheme.themeData;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Text(
            title,
            style: theme.textTheme.titleMedium?.copyWith(
              color: ChessEarnTheme.getColor('text-muted'),
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
            ),
          ),
        ),
        ...items,
        const SizedBox(height: 8),
      ],
    );
  }

  Widget _buildMenuItem(IconData icon, String title, String subtitle, {VoidCallback? onTap}) {
    final theme = ChessEarnTheme.themeData;
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: ChessEarnTheme.getColor('text-light').withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: ChessEarnTheme.getColor('text-light').withOpacity(0.1)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: ChessEarnTheme.getColor('brand-accent').withOpacity(0.2),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: ChessEarnTheme.getColor('brand-accent'), size: 24),
        ),
        title: Text(title, style: theme.textTheme.bodyLarge?.copyWith(color: ChessEarnTheme.getColor('text-light'), fontWeight: FontWeight.w500)),
        subtitle: Text(subtitle, style: theme.textTheme.bodySmall?.copyWith(color: ChessEarnTheme.getColor('text-muted'))),
        trailing: Icon(Icons.arrow_forward_ios_rounded, color: ChessEarnTheme.getColor('text-muted'), size: 16),
        onTap: onTap,
      ),
    );
  }

  Widget _buildPaymentTile() {
    final theme = ChessEarnTheme.themeData;
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: ChessEarnTheme.getColor('text-light').withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: ChessEarnTheme.getColor('text-light').withOpacity(0.1)),
      ),
      child: ExpansionTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: ChessEarnTheme.getColor('brand-accent').withOpacity(0.2),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(Icons.payment_rounded, color: ChessEarnTheme.getColor('brand-accent'), size: 24),
        ),
        title: Text('Payment Methods', style: theme.textTheme.bodyLarge?.copyWith(color: ChessEarnTheme.getColor('text-light'), fontWeight: FontWeight.w500)),
        subtitle: Text('Add credits to your account', style: theme.textTheme.bodySmall?.copyWith(color: ChessEarnTheme.getColor('text-muted'))),
        iconColor: ChessEarnTheme.getColor('text-muted'),
        collapsedIconColor: ChessEarnTheme.getColor('text-muted'),
        children: [
          _buildPaymentOption(Icons.credit_card_rounded, 'Credit/Debit Card', 'Secure payment via Stripe', _payWithCard),
          _buildPaymentOption(Icons.phone_android_rounded, 'M-Pesa', 'Pay with mobile money', _initMpesa),
        ],
      ),
    );
  }

  Widget _buildPaymentOption(IconData icon, String title, String subtitle, VoidCallback onTap) {
    final theme = ChessEarnTheme.themeData;
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        leading: Icon(icon, color: ChessEarnTheme.getColor('brand-accent'), size: 20),
        title: Text(title, style: theme.textTheme.bodyMedium?.copyWith(color: ChessEarnTheme.getColor('text-light'))),
        subtitle: Text(subtitle, style: theme.textTheme.bodySmall?.copyWith(color: ChessEarnTheme.getColor('text-muted'))),
        trailing: _isLoading
            ? SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: ChessEarnTheme.getColor('brand-accent')))
            : Icon(Icons.arrow_forward_ios_rounded, color: ChessEarnTheme.getColor('text-muted'), size: 12),
        onTap: _isLoading ? null : onTap,
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    final theme = ChessEarnTheme.themeData;
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.2)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(height: 4),
            Text(
              value,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: color,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              title,
              style: theme.textTheme.bodySmall?.copyWith(
                color: ChessEarnTheme.getColor('text-light').withOpacity(0.7),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showLogoutDialog() {
    final theme = ChessEarnTheme.themeData;
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: ChessEarnTheme.getColor('surface-card'),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Row(
            children: [
              Icon(Icons.logout_rounded, color: ChessEarnTheme.getColor('error')),
              const SizedBox(width: 8),
              Text('Logout', style: theme.textTheme.titleLarge?.copyWith(color: ChessEarnTheme.getColor('text-light'))),
            ],
          ),
          content: Text(
            'Are you sure you want to logout?',
            style: theme.textTheme.bodyLarge?.copyWith(color: ChessEarnTheme.getColor('text-light')),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Cancel', style: theme.textTheme.bodyMedium?.copyWith(color: ChessEarnTheme.getColor('text-muted'))),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                _logout(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: ChessEarnTheme.getColor('error'),
                foregroundColor: ChessEarnTheme.getColor('text-light'),
              ),
              child: Text('Logout', style: theme.textTheme.bodyMedium),
            ),
          ],
        );
      },
    );
  }

  String _getTimeOfDayGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning';
    if (hour < 17) return 'Good afternoon';
    return 'Good evening';
  }

  String _formatNumber(int number) {
    if (number >= 1000) {
      return '${(number / 1000).toStringAsFixed(1)}k';
    }
    return number.toString();
  }
}
