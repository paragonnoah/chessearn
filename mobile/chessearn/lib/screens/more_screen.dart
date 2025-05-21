import 'package:flutter/material.dart';
import 'package:chessearn/screens/profile_screen.dart';
import 'package:chessearn/screens/wallet_screen.dart';
import 'package:chessearn/services/api_service.dart';
import 'package:chessearn/screens/home_screen.dart';
import 'package:chessearn/theme.dart';
import 'package:flutter_stripe/flutter_stripe.dart'; // For Stripe payments
import 'package:http/http.dart' as http; // For custom M-Pesa API calls
import 'dart:convert';

class MoreScreen extends StatefulWidget {
  final String? userId;

  const MoreScreen({super.key, required this.userId});

  @override
  _MoreScreenState createState() => _MoreScreenState();
}

class _MoreScreenState extends State<MoreScreen> {
  Future<void> _logout(BuildContext context) async {
    await ApiService.logout();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const HomeScreen()),
    );
  }

  // Removed redundant Stripe initialization since it's done in main.dart
  @override
  void initState() {
    super.initState();
  }

  // Placeholder for M-Pesa configuration (requires Safaricom Daraja API credentials)
  Future<void> _initMpesa() async {
    // Replace with your Daraja API credentials
    const String consumerKey = 'your_consumer_key';
    const String consumerSecret = 'your_consumer_secret';
    const String shortCode = 'your_shortcode';
    const String passkey = 'your_passkey';
    // Example using http for STK Push
    final url = Uri.parse('https://sandbox.safaricom.co.ke/mpesa/stkpush/v1/processrequest');
    final response = await http.post(
      url,
      headers: {
        'Authorization': 'Bearer your_access_token', // Obtain via OAuth
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'BusinessShortCode': shortCode,
        'Password': '', // Generate using shortCode, passkey, and timestamp
        'Timestamp': DateTime.now().toIso8601String(),
        'TransactionType': 'CustomerPayBillOnline',
        'Amount': '1', // Test amount
        'PartyA': '254712345678', // Phone number
        'PartyB': shortCode,
        'PhoneNumber': '254712345678',
        'CallBackURL': 'your_callback_url',
        'AccountReference': 'ChessEarnPayment',
        'TransactionDesc': 'ChessEarn Subscription',
      }),
    );
    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('M-Pesa payment initiated! Check your phone.')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('M-Pesa payment failed!')),
      );
    }
  }

  // Stripe payment with card
  Future<void> _payWithCard() async {
    try {
      // Fetch PaymentIntent client secret from backend
      final response = await http.post(
        Uri.parse('https://your-backend.com/create-payment-intent'),
        headers: {'Content-Type': 'application/json'},
      );
      final data = jsonDecode(response.body);
      final clientSecret = data['clientSecret'];

      // Initialize the payment sheet
      await Stripe.instance.initPaymentSheet(
        paymentSheetParameters: SetupPaymentSheetParameters(
          merchantDisplayName: 'ChessEarn',
          paymentIntentClientSecret: clientSecret, // Use dynamic secret
        ),
      );
      // Present the payment sheet
      await Stripe.instance.presentPaymentSheet();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Card payment successful!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Card payment failed: $e')),
      );
    }
  }

  // Stripe payment (alternative approach)
  Future<void> _payWithStripe() async {
    try {
      // Create a payment method
      final paymentMethod = await Stripe.instance.createPaymentMethod(
        params: const PaymentMethodParams.card(
          paymentMethodData: PaymentMethodData(),
        ),
      );
      // Requires backend to create PaymentIntent and confirm payment
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Stripe payment initiated! Payment Method ID: ${paymentMethod.id}')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Stripe payment failed: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
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
      child: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          Text(
            'More',
            style: TextStyle(
              color: ChessEarnTheme.themeColors['text-light'],
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
          ListTile(
            leading: const Icon(Icons.bar_chart, color: Colors.white),
            title: Text('Stats', style: TextStyle(color: ChessEarnTheme.themeColors['text-light'])),
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Stats feature coming soon!')),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.person, color: Colors.white),
            title: Text('Profile', style: TextStyle(color: ChessEarnTheme.themeColors['text-light'])),
            onTap: () {
              if (widget.userId != null) {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ProfileScreen(userId: widget.userId!)),
                );
              }
            },
          ),
          ListTile(
            leading: const Icon(Icons.account_balance_wallet, color: Colors.white),
            title: Text('Wallet', style: TextStyle(color: ChessEarnTheme.themeColors['text-light'])),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => WalletScreen(userId: widget.userId)),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.palette, color: Colors.white),
            title: Text('Theme', style: TextStyle(color: ChessEarnTheme.themeColors['text-light'])),
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Theme feature coming soon!')),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.star, color: Colors.white),
            title: Text('Awards', style: TextStyle(color: ChessEarnTheme.themeColors['text-light'])),
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Awards feature coming soon!')),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.people, color: Colors.white),
            title: Text('Friends', style: TextStyle(color: ChessEarnTheme.themeColors['text-light'])),
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Friends feature coming soon!')),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.email, color: Colors.white),
            title: Text('Messages', style: TextStyle(color: ChessEarnTheme.themeColors['text-light'])),
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Messages feature coming soon!')),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.settings, color: Colors.white),
            title: Text('Settings', style: TextStyle(color: ChessEarnTheme.themeColors['text-light'])),
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Settings feature coming soon!')),
              );
            },
          ),
          ExpansionTile(
            leading: const Icon(Icons.payment, color: Colors.white),
            title: Text('Payment', style: TextStyle(color: ChessEarnTheme.themeColors['text-light'])),
            children: [
              ListTile(
                title: Text('Add Card', style: TextStyle(color: ChessEarnTheme.themeColors['text-light'])),
                onTap: _payWithCard, // Initiate card payment
              ),
              ListTile(
                title: Text('M-Pesa', style: TextStyle(color: ChessEarnTheme.themeColors['text-light'])),
                onTap: _initMpesa, // Initiate M-Pesa payment
              ),
              ListTile(
                title: Text('Stripe', style: TextStyle(color: ChessEarnTheme.themeColors['text-light'])),
                onTap: _payWithStripe, // Initiate Stripe payment
              ),
            ],
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: widget.userId != null ? () => _logout(context) : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: ChessEarnTheme.themeColors['brand-accent'],
              padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
            ),
            child: const Text('Logout', style: TextStyle(fontSize: 18)),
          ),
        ],
      ),
    );
  }
}