import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:chessearn_new/screens/profile_screen.dart';
import 'package:chessearn_new/screens/wallet_screen.dart';
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
  late Animation<double> _fadeAnimation;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeOut),
    );
    _fadeController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
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

  // Enhanced M-Pesa implementation
  Future<void> _initMpesa() async {
    if (_isLoading) return;
    setState(() => _isLoading = true);
    
    try {
      // Show phone number input dialog
      final phoneNumber = await _showPhoneNumberDialog();
      if (phoneNumber == null || phoneNumber.isEmpty) {
        setState(() => _isLoading = false);
        return;
      }

      const String consumerKey = 'your_consumer_key';
      const String consumerSecret = 'your_consumer_secret';
      const String shortCode = 'your_shortcode';
      const String passkey = 'your_passkey';
      const String callbackUrl = 'https://your-callback-url.com/callback';

      // Get access token
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

      // Generate timestamp and password
      final timestamp = DateTime.now()
          .toIso8601String()
          .replaceAll(RegExp(r'[^0-9]'), '')
          .substring(0, 14);
      final password = json.base64Encode(utf8.encode('$shortCode$passkey$timestamp'));

      // Initiate STK Push
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
          'Amount': '10', // $0.10 for testing
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
      _showErrorSnackBar('M-Pesa payment failed: ${e.toString()}');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  // Enhanced Stripe Payment Sheet implementation
  Future<void> _payWithCard() async {
    if (_isLoading) return;
    setState(() => _isLoading = true);
    
    try {
      // Create payment intent on your backend
      final response = await http.post(
        Uri.parse('https://your-backend.com/create-payment-intent'),
        headers: {'Content-Type': 'application/json'},
        body: json.jsonEncode({
          'amount': 1000, // $10.00 in cents
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

      // Initialize payment sheet
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

      // Present payment sheet
      await Stripe.instance.presentPaymentSheet();
      
      _showSuccessSnackBar('Payment successful! Credits added to your account.');
    } on StripeException catch (e) {
      if (e.error.code != FailureCode.Canceled) {
        _showErrorSnackBar('Payment failed: ${e.error.message}');
      }
    } catch (e) {
      _showErrorSnackBar('Payment failed: ${e.toString()}');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  // Alternative Stripe payment method
  Future<void> _payWithStripe() async {
    if (_isLoading) return;
    setState(() => _isLoading = true);
    
    try {
      // This would typically open a custom card input form
      _showErrorSnackBar('Use "Add Card" option for secure payments');
    } catch (e) {
      _showErrorSnackBar('Stripe payment failed: ${e.toString()}');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<String?> _showPhoneNumberDialog() async {
    String phoneNumber = '';
    return showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: ChessEarnTheme.themeColors['surface-card'],
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Row(
            children: [
              Icon(Icons.phone, color: ChessEarnTheme.themeColors['brand-accent']),
              const SizedBox(width: 8),
              Text('Enter Phone Number', style: ChessEarnTheme.titleStyle),
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
                borderSide: BorderSide(color: ChessEarnTheme.themeColors['border-soft']!),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Cancel', style: TextStyle(color: ChessEarnTheme.themeColors['text-muted'])),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(phoneNumber),
              child: const Text('Proceed'),
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
        return Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: ChessEarnTheme.themeColors['surface-card'],
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(
                  color: ChessEarnTheme.themeColors['brand-accent'],
                ),
                const SizedBox(height: 16),
                Text('Processing...', style: ChessEarnTheme.bodyStyle),
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
            Icon(Icons.check_circle, color: ChessEarnTheme.themeColors['success']),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: ChessEarnTheme.themeColors['success'],
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
            Icon(Icons.error, color: ChessEarnTheme.themeColors['text-light']),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: ChessEarnTheme.themeColors['error'],
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
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
                            color: Colors.white.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            Icons.more_horiz_rounded,
                            color: ChessEarnTheme.themeColors['brand-accent'],
                            size: 28,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Text(
                          'More Options',
                          style: ChessEarnTheme.headlineStyle.copyWith(fontSize: 28),
                        ),
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
                        color: Colors.white.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.white.withOpacity(0.2)),
                      ),
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 24,
                            backgroundColor: ChessEarnTheme.themeColors['brand-accent'],
                            child: Icon(Icons.person, color: Colors.white, size: 28),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Welcome back!',
                                  style: TextStyle(
                                    color: ChessEarnTheme.themeColors['text-light'],
                                    fontSize: 18,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                Text(
                                  'User ID: ${widget.userId}',
                                  style: TextStyle(
                                    color: ChessEarnTheme.themeColors['text-muted'],
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
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
                          onTap: widget.userId != null ? () => Navigator.push(context, MaterialPageRoute(builder: (context) => ProfileScreen(userId: widget.userId!))) : null),
                        _buildMenuItem(Icons.account_balance_wallet_rounded, 'Wallet', 'Manage your earnings',
                          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => WalletScreen(userId: widget.userId)))),
                        _buildMenuItem(Icons.bar_chart_rounded, 'Statistics', 'View your game stats', 
                          onTap: () => _showComingSoonSnackBar('Stats')),
                      ]),

                      _buildMenuSection('Social', [
                        _buildMenuItem(Icons.people_rounded, 'Friends', 'Connect with other players',
                          onTap: () => _showComingSoonSnackBar('Friends')),
                        _buildMenuItem(Icons.message_rounded, 'Messages', 'Chat with friends',
                          onTap: () => _showComingSoonSnackBar('Messages')),
                        _buildMenuItem(Icons.emoji_events_rounded, 'Awards', 'View your achievements',
                          onTap: () => _showComingSoonSnackBar('Awards')),
                      ]),

                      _buildMenuSection('Payments', [
                        _buildPaymentTile(),
                      ]),

                      _buildMenuSection('App', [
                        _buildMenuItem(Icons.palette_rounded, 'Theme', 'Customize app appearance',
                          onTap: () => _showComingSoonSnackBar('Theme')),
                        _buildMenuItem(Icons.settings_rounded, 'Settings', 'App preferences',
                          onTap: () => _showComingSoonSnackBar('Settings')),
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
                              backgroundColor: ChessEarnTheme.themeColors['error'],
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                            ),
                            icon: const Icon(Icons.logout_rounded),
                            label: const Text('Logout', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
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

  Widget _buildMenuSection(String title, List<Widget> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Text(
            title,
            style: TextStyle(
              color: ChessEarnTheme.themeColors['text-muted'],
              fontSize: 16,
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
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: ChessEarnTheme.themeColors['brand-accent']!.withOpacity(0.2),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: ChessEarnTheme.themeColors['brand-accent'], size: 24),
        ),
        title: Text(title, style: TextStyle(color: ChessEarnTheme.themeColors['text-light'], fontWeight: FontWeight.w500)),
        subtitle: Text(subtitle, style: TextStyle(color: ChessEarnTheme.themeColors['text-muted'], fontSize: 12)),
        trailing: Icon(Icons.arrow_forward_ios_rounded, color: ChessEarnTheme.themeColors['text-muted'], size: 16),
        onTap: onTap,
      ),
    );
  }

  Widget _buildPaymentTile() {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: ExpansionTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: ChessEarnTheme.themeColors['brand-accent']!.withOpacity(0.2),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(Icons.payment_rounded, color: ChessEarnTheme.themeColors['brand-accent'], size: 24),
        ),
        title: Text('Payment Methods', style: TextStyle(color: ChessEarnTheme.themeColors['text-light'], fontWeight: FontWeight.w500)),
        subtitle: Text('Add credits to your account', style: TextStyle(color: ChessEarnTheme.themeColors['text-muted'], fontSize: 12)),
        iconColor: ChessEarnTheme.themeColors['text-muted'],
        collapsedIconColor: ChessEarnTheme.themeColors['text-muted'],
        children: [
          _buildPaymentOption(Icons.credit_card_rounded, 'Credit/Debit Card', 'Secure payment via Stripe', _payWithCard),
          _buildPaymentOption(Icons.phone_android_rounded, 'M-Pesa', 'Pay with mobile money', _initMpesa),
        ],
      ),
    );
  }

  Widget _buildPaymentOption(IconData icon, String title, String subtitle, VoidCallback onTap) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        leading: Icon(icon, color: ChessEarnTheme.themeColors['brand-accent'], size: 20),
        title: Text(title, style: TextStyle(color: ChessEarnTheme.themeColors['text-light'], fontSize: 14)),
        subtitle: Text(subtitle, style: TextStyle(color: ChessEarnTheme.themeColors['text-muted'], fontSize: 11)),
        trailing: _isLoading 
          ? SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: ChessEarnTheme.themeColors['brand-accent']))
          : Icon(Icons.arrow_forward_ios_rounded, color: ChessEarnTheme.themeColors['text-muted'], size: 12),
        onTap: _isLoading ? null : onTap,
      ),
    );
  }

  void _showComingSoonSnackBar(String feature) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$feature feature coming soon!'),
        backgroundColor: ChessEarnTheme.themeColors['info'],
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: ChessEarnTheme.themeColors['surface-card'],
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Row(
            children: [
              Icon(Icons.logout_rounded, color: ChessEarnTheme.themeColors['error']),
              const SizedBox(width: 8),
              Text('Logout', style: TextStyle(color: ChessEarnTheme.themeColors['text-dark'])),
            ],
          ),
          content: Text(
            'Are you sure you want to logout?',
            style: TextStyle(color: ChessEarnTheme.themeColors['text-dark']),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Cancel', style: TextStyle(color: ChessEarnTheme.themeColors['text-muted'])),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                _logout(context);
              },
              style: ElevatedButton.styleFrom(backgroundColor: ChessEarnTheme.themeColors['error']),
              child: const Text('Logout'),
            ),
          ],
        );
      },
    );
  }
}