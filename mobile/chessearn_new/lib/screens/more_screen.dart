import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:chessearn_new/screens/profile_screen.dart';
import 'package:chessearn_new/screens/wallet_screen.dart';
import 'package:chessearn_new/services/api_service.dart';
import 'package:chessearn_new/screens/home_screen.dart';
import 'package:chessearn_new/theme.dart';
import 'package:flutter_stripe/flutter_stripe.dart'; // For Stripe payments
import 'package:http/http.dart' as http; // For custom M-Pesa API calls
import 'dart:convert' as json; // Keep only this import

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

  @override
  void initState() {
    super.initState();
  }

  // M-Pesa payment initiation using Safaricom Daraja API
  Future<void> _initMpesa() async {
    try {
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
        throw Exception('Failed to obtain M-Pesa access token: ${tokenResponse.body}');
      }

      final tokenData = json.jsonDecode(tokenResponse.body);
      final accessToken = tokenData['access_token'];

      final timestamp = DateTime.now().toIso8601String().replaceAll(RegExp(r'[^0-9]'), '').substring(0, 14);
      final password = json.base64Encode(utf8.encode('$shortCode$passkey$timestamp'));

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
          'Amount': '1',
          'PartyA': '254712345678',
          'PartyB': shortCode,
          'PhoneNumber': '254712345678',
          'CallBackURL': callbackUrl,
          'AccountReference': 'ChessEarnPayment',
          'TransactionDesc': 'ChessEarn Subscription',
        }),
      );

      if (stkResponse.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('M-Pesa payment initiated! Check your phone.')),
        );
      } else {
        throw Exception('M-Pesa STK Push failed: ${stkResponse.body}');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('M-Pesa payment failed: $e')),
      );
    }
  }

  // Stripe payment with Payment Sheet
  Future<void> _payWithCard() async {
    try {
      final response = await http.post(
        Uri.parse('https://your-backend.com/create-payment-intent'),
        headers: {'Content-Type': 'application/json'},
        body: json.jsonEncode({
          'amount': 1000,
          'currency': 'usd',
        }),
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to create PaymentIntent: ${response.body}');
      }

      final data = json.jsonDecode(response.body);
      final clientSecret = data['clientSecret'];

      await Stripe.instance.initPaymentSheet(
        paymentSheetParameters: SetupPaymentSheetParameters(
          merchantDisplayName: 'ChessEarn',
          paymentIntentClientSecret: clientSecret,
          allowsDelayedPaymentMethods: true,
        ),
      );

      await Stripe.instance.presentPaymentSheet();

      final paymentIntent = await Stripe.instance.retrievePaymentIntent(clientSecret);
      if (paymentIntent.status == 'succeeded') {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Card payment successful!')),
        );
      } else {
        throw Exception('Payment did not succeed: ${paymentIntent.status}');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Card payment failed: $e')),
      );
    }
  }

  // Alternative Stripe payment
  Future<void> _payWithStripe() async {
    try {
      final paymentMethod = await Stripe.instance.createPaymentMethod(
        params: const PaymentMethodParams.card(
          paymentMethodData: PaymentMethodData(),
        ),
      );

      final response = await http.post(
        Uri.parse('https://your-backend.com/confirm-payment'),
        headers: {'Content-Type': 'application/json'},
        body: json.jsonEncode({
          'payment_method_id': paymentMethod.id,
          'amount': 1000,
          'currency': 'usd',
        }),
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to confirm payment: ${response.body}');
      }

      final data = json.jsonDecode(response.body);
      if (data['status'] == 'succeeded') {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Stripe payment successful!')),
        );
      } else {
        throw Exception('Payment did not succeed: ${data['status']}');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Stripe payment failed: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                  onTap: _payWithCard,
                ),
                ListTile(
                  title: Text('M-Pesa', style: TextStyle(color: ChessEarnTheme.themeColors['text-light'])),
                  onTap: _initMpesa,
                ),
                ListTile(
                  title: Text('Stripe', style: TextStyle(color: ChessEarnTheme.themeColors['text-light'])),
                  onTap: _payWithStripe,
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
      ),
    );
  }
}