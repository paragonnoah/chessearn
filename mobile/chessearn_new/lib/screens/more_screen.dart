import 'package:flutter/material.dart';
import 'package:chessearn_new/screens/profile_screen.dart';
import 'package:chessearn_new/screens/wallet_screen.dart';
import 'package:chessearn_new/services/api_service.dart';
import 'package:chessearn_new/screens/home_screen.dart';
import 'package:chessearn_new/theme.dart';
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

  @override
  void initState() {
    super.initState();
  }

  // M-Pesa payment initiation using Safaricom Daraja API
  Future<void> _initMpesa() async {
    try {
      // Replace with your actual Daraja API credentials
      const String consumerKey = 'your_consumer_key';
      const String consumerSecret = 'your_consumer_secret';
      const String shortCode = 'your_shortcode';
      const String passkey = 'your_passkey';
      const String callbackUrl = 'https://your-callback-url.com/callback';

      // Step 1: Obtain access token from Safaricom OAuth
      final auth = base64Encode(utf8.encode('$consumerKey:$consumerSecret'));
      final tokenResponse = await http.get(
        Uri.parse('https://sandbox.safaricom.co.ke/oauth/v1/generate?grant_type=client_credentials'),
        headers: {'Authorization': 'Basic $auth'},
      );

      if (tokenResponse.statusCode != 200) {
        throw Exception('Failed to obtain M-Pesa access token: ${tokenResponse.body}');
      }

      final tokenData = jsonDecode(tokenResponse.body);
      final accessToken = tokenData['access_token'];

      // Step 2: Generate timestamp and password for STK Push
      final timestamp = DateTime.now().toIso8601String().replaceAll(RegExp(r'[^0-9]'), '').substring(0, 14);
      final password = base64Encode(utf8.encode('$shortCode$passkey$timestamp'));

      // Step 3: Initiate STK Push
      final stkResponse = await http.post(
        Uri.parse('https://sandbox.safaricom.co.ke/mpesa/stkpush/v1/processrequest'),
        headers: {
          'Authorization': 'Bearer $accessToken',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'BusinessShortCode': shortCode,
          'Password': password,
          'Timestamp': timestamp,
          'TransactionType': 'CustomerPayBillOnline',
          'Amount': '1', // Test amount
          'PartyA': '254712345678', // Replace with user's phone number
          'PartyB': shortCode,
          'PhoneNumber': '254712345678', // Replace with user's phone number
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

  // Stripe payment with Payment Sheet (recommended approach)
  Future<void> _payWithCard() async {
    try {
      // Step 1: Fetch PaymentIntent client secret from your backend
      final response = await http.post(
        Uri.parse('https://your-backend.com/create-payment-intent'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'amount': 1000, // Amount in cents (e.g., $10.00)
          'currency': 'usd', // Adjust as needed
        }),
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to create PaymentIntent: ${response.body}');
      }

      final data = jsonDecode(response.body);
      final clientSecret = data['clientSecret'];

      // Step 2: Initialize the Payment Sheet
      await Stripe.instance.initPaymentSheet(
        paymentSheetParameters: SetupPaymentSheetParameters(
          merchantDisplayName: 'ChessEarn',
          paymentIntentClientSecret: clientSecret,
          allowsDelayedPaymentMethods: true,
          // Add customer ID if you have one (requires Stripe Customer setup)
          // customerId: 'customer_id',
        ),
      );

      // Step 3: Present the Payment Sheet
      await Stripe.instance.presentPaymentSheet();

      // Step 4: Confirm payment (optional, if backend doesn't auto-confirm)
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

  // Alternative Stripe payment using manual Payment Method creation
  Future<void> _payWithStripe() async {
    try {
      // Step 1: Create a payment method
      final paymentMethod = await Stripe.instance.createPaymentMethod(
        params: const PaymentMethodParams.card(
          paymentMethodData: PaymentMethodData(),
        ),
      );

      // Step 2: Send the payment method ID to your backend to create and confirm a PaymentIntent
      final response = await http.post(
        Uri.parse('https://your-backend.com/confirm-payment'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'payment_method_id': paymentMethod.id,
          'amount': 1000, // Amount in cents
          'currency': 'usd', // Adjust as needed
        }),
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to confirm payment: ${response.body}');
      }

      final data = jsonDecode(response.body);
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