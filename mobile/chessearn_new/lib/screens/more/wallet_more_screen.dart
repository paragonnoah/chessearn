import 'package:flutter/material.dart';
import 'package:chessearn_new/services/api_service.dart';
import 'package:chessearn_new/theme.dart';
import 'dart:async';

class WalletScreen extends StatefulWidget {
  final String? userId;

  const WalletScreen({super.key, required this.userId});

  @override
  _WalletScreenState createState() => _WalletScreenState();
}

class _WalletScreenState extends State<WalletScreen> with TickerProviderStateMixin {
  double? walletBalance;
  String? country;
  String? currency;
  double? convertedBalance;
  bool isLoading = true;
  bool isProcessing = false;

  // Static exchange rates (USD to local currency) for demonstration
  final Map<String, Map<String, dynamic>> currencyData = {
    'KE': {'currency': 'KES', 'rate': 129.50}, // Kenya: Kenyan Shilling
    'US': {'currency': 'USD', 'rate': 1.0},   // United States: US Dollar
    'GB': {'currency': 'GBP', 'rate': 0.79},  // United Kingdom: British Pound
    'IN': {'currency': 'INR', 'rate': 84.10}, // India: Indian Rupee
    'NG': {'currency': 'NGN', 'rate': 1670.0},// Nigeria: Nigerian Naira
    // Add more countries as needed
  };

  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;
  late AnimationController _scaleController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeOut),
    );
    _scaleAnimation = Tween<double>(begin: 0.95, end: 1.0).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.easeInOut),
    );
    _fadeController.forward();
    _fetchWalletData();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _scaleController.dispose();
    super.dispose();
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

        final countryData = currencyData[country];
        if (countryData != null) {
          currency = countryData['currency'];
          final rate = countryData['rate'] as double;
          convertedBalance = walletBalance! * rate;
        } else {
          currency = 'USD';
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
      _showErrorSnackBar('Failed to fetch wallet balance: $e');
    }
  }

  Future<void> _depositFunds() async {
    if (isProcessing || widget.userId == null) return;
    setState(() => isProcessing = true);

    _scaleController.forward().then((_) {
      _scaleController.reverse();
    });

    try {
      final amount = await _showAmountDialog('Deposit');
      if (amount == null || amount <= 0) {
        setState(() => isProcessing = false);
        return;
      }

      await ApiService.depositFunds(widget.userId!, amount);
      await _fetchWalletData(); // Refresh balance
      _showSuccessSnackBar('Deposit of $amount $currency successful!');
    } catch (e) {
      _showErrorSnackBar('Deposit failed: $e');
    } finally {
      setState(() => isProcessing = false);
    }
  }

  Future<void> _withdrawFunds() async {
    if (isProcessing || widget.userId == null || (walletBalance ?? 0) <= 0) return;
    setState(() => isProcessing = true);

    _scaleController.forward().then((_) {
      _scaleController.reverse();
    });

    try {
      final amount = await _showAmountDialog('Withdraw');
      if (amount == null || amount <= 0 || amount > (walletBalance ?? 0)) {
        _showErrorSnackBar('Invalid withdrawal amount or insufficient balance');
        setState(() => isProcessing = false);
        return;
      }

      await ApiService.withdrawFunds(widget.userId!, amount);
      await _fetchWalletData(); // Refresh balance
      _showSuccessSnackBar('Withdrawal of $amount $currency successful!');
    } catch (e) {
      _showErrorSnackBar('Withdrawal failed: $e');
    } finally {
      setState(() => isProcessing = false);
    }
  }

  Future<double?> _showAmountDialog(String action) async {
    double amount = 0.0;
    return showDialog<double>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: ChessEarnTheme.themeColors['surface-card'],
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Row(
            children: [
              Icon(Icons.account_balance_wallet, color: ChessEarnTheme.themeColors['brand-accent']),
              const SizedBox(width: 8),
              Text('$action Amount', style: TextStyle(color: ChessEarnTheme.themeColors['text-light'])),
            ],
          ),
          content: TextField(
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              hintText: 'Enter amount in $currency',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onChanged: (value) => amount = double.tryParse(value) ?? 0.0,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Cancel', style: TextStyle(color: ChessEarnTheme.themeColors['text-muted'])),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(amount),
              child: Text(action),
            ),
          ],
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
        child: SafeArea(
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
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
                                Icons.account_balance_wallet,
                                color: ChessEarnTheme.themeColors['brand-accent'],
                                size: 28,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Wallet',
                                    style: TextStyle(
                                      color: ChessEarnTheme.themeColors['text-light'],
                                      fontSize: 28,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    'Manage your earnings • ${_getTimeOfDayGreeting()}',
                                    style: TextStyle(
                                      color: ChessEarnTheme.themeColors['text-light']!.withOpacity(0.8),
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        // Balance Card
                        AnimatedBuilder(
                          animation: _scaleAnimation,
                          builder: (context, child) {
                            return Transform.scale(
                              scale: _scaleAnimation.value,
                              child: Container(
                                padding: const EdgeInsets.all(20),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(color: Colors.white.withOpacity(0.2)),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.1),
                                      blurRadius: 20,
                                      offset: const Offset(0, 10),
                                    ),
                                  ],
                                ),
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
                            );
                          },
                        ),
                        const SizedBox(height: 20),
                        // Action Buttons
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            _buildActionButton('Deposit', Icons.add, Colors.green, _depositFunds),
                            _buildActionButton('Withdraw', Icons.remove, Colors.red, _withdrawFunds),
                          ],
                        ),
                        const SizedBox(height: 20),
                        // Transaction History
                        Text(
                          'Transaction History',
                          style: TextStyle(
                            color: ChessEarnTheme.themeColors['text-light'],
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Expanded(
                          child: ListView(
                            children: [
                              _buildTransactionItem('Deposit', '+20.00', DateTime.now().subtract(Duration(days: 1)), true),
                              _buildTransactionItem('Game Win', '+5.00', DateTime.now().subtract(Duration(days: 2)), true),
                              _buildTransactionItem('Withdrawal', '-10.00', DateTime.now().subtract(Duration(days: 3)), false),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
          ),
        ),
      ),
    );
  }

  Widget _buildActionButton(String title, IconData icon, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: isProcessing ? null : onTap,
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [color.withOpacity(0.2), color.withOpacity(0.1)],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: color.withOpacity(0.3)),
                boxShadow: [
                  BoxShadow(
                    color: color.withOpacity(0.2),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Icon(icon, color: color, size: 24),
                  const SizedBox(height: 8),
                  Text(
                    title,
                    style: TextStyle(
                      color: color,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildTransactionItem(String title, String amount, DateTime date, bool isCredit) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Row(
        children: [
          Icon(
            isCredit ? Icons.arrow_upward : Icons.arrow_downward,
            color: isCredit ? Colors.green : Colors.red,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(color: ChessEarnTheme.themeColors['text-light']),
                ),
                Text(
                  date.toString().split(' ')[0],
                  style: TextStyle(color: ChessEarnTheme.themeColors['text-muted'], fontSize: 12),
                ),
              ],
            ),
          ),
          Text(
            amount,
            style: TextStyle(
              color: isCredit ? Colors.green : Colors.red,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  String _getTimeOfDayGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning';
    if (hour < 17) return 'Good afternoon';
    return 'Good evening';
  }
}