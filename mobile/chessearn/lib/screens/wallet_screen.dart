import 'package:flutter/material.dart';
import 'package:chessearn/services/api_service.dart';
import 'package:chessearn/theme.dart';

class WalletScreen extends StatefulWidget {
  final String? userId;

  const WalletScreen({super.key, required this.userId});

  @override
  _WalletScreenState createState() => _WalletScreenState();
}

class _WalletScreenState extends State<WalletScreen> {
  double? walletBalance;
  String? country;
  String? currency;
  double? convertedBalance;
  bool isLoading = true;

  // Static exchange rates (USD to local currency) for demonstration
  final Map<String, Map<String, dynamic>> currencyData = {
    'KE': {'currency': 'KES', 'rate': 129.50}, // Kenya: Kenyan Shilling
    'US': {'currency': 'USD', 'rate': 1.0},   // United States: US Dollar
    'GB': {'currency': 'GBP', 'rate': 0.79},  // United Kingdom: British Pound
    'IN': {'currency': 'INR', 'rate': 84.10}, // India: Indian Rupee
    'NG': {'currency': 'NGN', 'rate': 1670.0},// Nigeria: Nigerian Naira
    // Add more countries as needed
  };

  @override
  void initState() {
    super.initState();
    _fetchWalletData();
  }

  Future<void> _fetchWalletData() async {
    if (widget.userId == null) {
      setState(() {
        isLoading = false;
        walletBalance = 0.0;
        country = 'Unknown';
        currency = 'USD';
        convertedBalance = 0.0;
      });
      return;
    }

    try {
      final data = await ApiService.getWalletBalance(widget.userId!);
      setState(() {
        country = data['country'] ?? 'Unknown';
        walletBalance = data['wallet_balance']?.toDouble() ?? 0.0;

        // Determine currency and convert balance
        final countryData = currencyData[country];
        if (countryData != null) {
          currency = countryData['currency'];
          final rate = countryData['rate'] as double;
          convertedBalance = walletBalance! * rate;
        } else {
          currency = 'USD'; // Fallback to USD
          convertedBalance = walletBalance;
        }
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
        walletBalance = 0.0;
        country = 'Unknown';
        currency = 'USD';
        convertedBalance = 0.0;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to fetch wallet balance: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Wallet'),
        backgroundColor: ChessEarnTheme.themeColors['brand-dark'],
        foregroundColor: ChessEarnTheme.themeColors['text-light'],
      ),
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
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Your Wallet',
                      style: TextStyle(
                        color: ChessEarnTheme.themeColors['text-light'],
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Card(
                      color: ChessEarnTheme.themeColors['surface-dark'],
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Balance',
                              style: TextStyle(
                                color: ChessEarnTheme.themeColors['text-muted'],
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              '${convertedBalance?.toStringAsFixed(2)} $currency',
                              style: TextStyle(
                                color: ChessEarnTheme.themeColors['text-light'],
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Country: $country',
                              style: TextStyle(
                                color: ChessEarnTheme.themeColors['text-muted'],
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}