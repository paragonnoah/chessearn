import 'package:flutter/material.dart';
import 'package:chessearn_new/services/api_service.dart';
import 'package:chessearn_new/theme.dart';

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

  void _onDeposit(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: ChessEarnTheme.themeColors['surface-dark'],
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 26, horizontal: 18),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Deposit', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: ChessEarnTheme.themeColors['text-light'])),
              const SizedBox(height: 16),
              ListTile(
                leading: Icon(Icons.phone_iphone, color: ChessEarnTheme.themeColors['brand-accent']),
                title: const Text('Deposit via M-Pesa'),
                subtitle: const Text('Use your registered M-Pesa number.'),
                onTap: () {
                  Navigator.pop(context);
                  // TODO: Implement your M-Pesa deposit logic here
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('M-Pesa deposit coming soon!')),
                  );
                },
              ),
              ListTile(
                leading: Icon(Icons.credit_card, color: ChessEarnTheme.themeColors['brand-accent']),
                title: const Text('Deposit via Credit/Debit Card'),
                subtitle: const Text('Use your linked card.'),
                onTap: () {
                  Navigator.pop(context);
                  // TODO: Implement your Credit Card deposit logic here
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Card deposit coming soon!')),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _onWithdraw(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: ChessEarnTheme.themeColors['surface-dark'],
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 26, horizontal: 18),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Withdraw', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: ChessEarnTheme.themeColors['text-light'])),
              const SizedBox(height: 16),
              ListTile(
                leading: Icon(Icons.phone_iphone, color: ChessEarnTheme.themeColors['brand-accent']),
                title: const Text('Withdraw to M-Pesa'),
                subtitle: const Text('Funds will be sent to your registered M-Pesa number.'),
                onTap: () {
                  Navigator.pop(context);
                  // TODO: Implement your withdraw logic here
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Withdraw coming soon!')),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
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
                            const SizedBox(height: 16),
                            Row(
                              children: [
                                Expanded(
                                  child: ElevatedButton.icon(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: ChessEarnTheme.themeColors['brand-accent'],
                                      foregroundColor: ChessEarnTheme.themeColors['text-light'],
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(16),
                                      ),
                                      padding: const EdgeInsets.symmetric(vertical: 14),
                                    ),
                                    icon: const Icon(Icons.add_circle_outline),
                                    label: const Text("Deposit"),
                                    onPressed: () => _onDeposit(context),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: ElevatedButton.icon(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: ChessEarnTheme.themeColors['brand-dark'],
                                      foregroundColor: ChessEarnTheme.themeColors['text-light'],
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(16),
                                      ),
                                      padding: const EdgeInsets.symmetric(vertical: 14),
                                    ),
                                    icon: const Icon(Icons.call_made_rounded),
                                    label: const Text("Withdraw"),
                                    onPressed: () => _onWithdraw(context),
                                  ),
                                ),
                              ],
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