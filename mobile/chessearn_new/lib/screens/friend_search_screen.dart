import 'package:flutter/material.dart';
import 'package:chessearn_new/services/api_service.dart';
import 'package:chessearn_new/theme.dart';
import 'package:chessearn_new/screens/game_screen.dart'; // Import GameScreen

class FriendSearchScreen extends StatefulWidget {
  final String? userId;

  const FriendSearchScreen({super.key, required this.userId});

  @override
  _FriendSearchScreenState createState() => _FriendSearchScreenState();
}

class _FriendSearchScreenState extends State<FriendSearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<Map<String, dynamic>> searchResults = [];
  bool isLoading = false;
  String? errorMessage;
  Map<String, String> friendRequestStatus = {}; // Track status of friend requests

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
  }

  void _onSearchChanged() {
    if (_searchController.text.isEmpty) {
      setState(() {
        searchResults = [];
        errorMessage = null;
        isLoading = false;
      });
      return;
    }
    _searchUsers();
  }

  Future<void> _searchUsers() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final query = _searchController.text.trim();
      if (query.isEmpty) return;

      final response = await ApiService.searchUsers(query);
      setState(() {
        searchResults = response;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        errorMessage = e.toString().replaceFirst('Exception: ', '');
        searchResults = [];
        isLoading = false;
      });
    }
  }

  Future<void> _sendFriendRequest(String friendId) async {
    if (widget.userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please log in to add friends')),
      );
      return;
    }

    setState(() {
      friendRequestStatus[friendId] = 'Sending...';
    });

    try {
      await ApiService.sendFriendRequest(widget.userId!, friendId);
      setState(() {
        friendRequestStatus[friendId] = 'Friend request sent!';
      });

      // Navigate to GameScreen with the friend as the opponent
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => GameScreen(
            userId: widget.userId,
            initialPlayMode: 'online',
            timeControl: '10|0', // Default time control, adjust as needed
            opponentId: friendId, // Pass friendId as opponentId
          ),
        ),
      );
    } catch (e) {
      setState(() {
        friendRequestStatus[friendId] = e.toString().replaceFirst('Exception: ', '');
      });
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
        child: SafeArea(
          child: Column(
            children: [
              // Header
              Container(
                padding: const EdgeInsets.all(16.0),
                color: ChessEarnTheme.themeColors['brand-dark'],
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Search Friends',
                      style: TextStyle(
                        color: ChessEarnTheme.themeColors['text-light'],
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        shadows: const [
                          Shadow(
                            color: Colors.black45,
                            offset: Offset(2, 2),
                            blurRadius: 4,
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),
              // Search Bar
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Search by username...',
                    hintStyle: TextStyle(color: ChessEarnTheme.themeColors['text-muted']),
                    prefixIcon: Icon(Icons.search, color: ChessEarnTheme.themeColors['brand-accent']),
                    filled: true,
                    fillColor: ChessEarnTheme.themeColors['surface-dark']!.withOpacity(0.5),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  style: TextStyle(color: ChessEarnTheme.themeColors['text-light']),
                ),
              ),
              // Search Results
              Expanded(
                child: isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : errorMessage != null
                        ? Center(
                            child: Text(
                              errorMessage!,
                              style: TextStyle(color: ChessEarnTheme.themeColors['text-light']),
                            ),
                          )
                        : searchResults.isEmpty && _searchController.text.isNotEmpty
                            ? Center(
                                child: Text(
                                  'No users found',
                                  style: TextStyle(color: ChessEarnTheme.themeColors['text-light']),
                                ),
                              )
                            : ListView.builder(
                                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                                itemCount: searchResults.length,
                                itemBuilder: (context, index) {
                                  final user = searchResults[index];
                                  final userId = user['id'] as String;
                                  final username = user['username'] as String;
                                  final status = friendRequestStatus[userId] ?? 'Add Friend';
                                  final isButtonDisabled = status != 'Add Friend';

                                  return Card(
                                    color: ChessEarnTheme.themeColors['surface-dark'],
                                    margin: const EdgeInsets.symmetric(vertical: 8.0),
                                    child: ListTile(
                                      title: Text(
                                        username,
                                        style: TextStyle(color: ChessEarnTheme.themeColors['text-light']),
                                      ),
                                      trailing: ElevatedButton(
                                        onPressed: isButtonDisabled
                                            ? null
                                            : () => _sendFriendRequest(userId),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: ChessEarnTheme.themeColors['brand-accent'],
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                        ),
                                        child: Text(
                                          status,
                                          style: const TextStyle(color: Colors.white),
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }
}