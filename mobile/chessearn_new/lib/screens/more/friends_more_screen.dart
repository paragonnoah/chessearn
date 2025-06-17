import 'package:flutter/material.dart';
import 'package:chessearn_new/services/api_service.dart';
import 'package:chessearn_new/theme.dart';
import 'package:chessearn_new/screens/game_screen.dart';

class FriendsMoreScreen extends StatefulWidget {
  final String? userId;

  const FriendsMoreScreen({super.key, required this.userId});

  @override
  _FriendsMoreScreenState createState() => _FriendsMoreScreenState();
}

class _FriendsMoreScreenState extends State<FriendsMoreScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<Map<String, dynamic>> searchResults = [];
  List<Map<String, dynamic>> connectedFriends = []; // List of connected friends
  int onlineFriendsCount = 0; // Number of online friends
  bool isLoading = false;
  bool isLoadingFriends = false;
  String? errorMessage;
  String? friendsErrorMessage;
  Map<String, String> friendRequestStatus = {};

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
    _fetchConnectedFriends(); // Fetch connected friends on init
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

  Future<void> _fetchConnectedFriends() async {
    setState(() {
      isLoadingFriends = true;
      friendsErrorMessage = null;
    });

    try {
      // Mock data for now - replace with real API call
      // Example: final response = await ApiService.getConnectedFriends(widget.userId!);
      final mockResponse = [
        {'id': 'friend1', 'username': 'Alice', 'online': true},
        {'id': 'friend2', 'username': 'Bob', 'online': false},
        {'id': 'friend3', 'username': 'Charlie', 'online': true},
      ];

      setState(() {
        connectedFriends = mockResponse;
        onlineFriendsCount = mockResponse.where((friend) => friend['online'] == true).length;
        isLoadingFriends = false;
      });
    } catch (e) {
      setState(() {
        friendsErrorMessage = e.toString().replaceFirst('Exception: ', '');
        connectedFriends = [];
        onlineFriendsCount = 0;
        isLoadingFriends = false;
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

      // Create a game and navigate to GameScreen
      String gameId = await ApiService.createGame(
        isRated: true, // Default to rated
        baseTime: 10, // Default time control base
        increment: 0, // Default increment
        betAmount: 0.0, // Default bet amount
      );

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => GameScreen(
            userId: widget.userId,
            initialPlayMode: 'online',
            timeControl: '10|0',
            opponentId: friendId,
            gameId: gameId, // Added required gameId
          ),
        ),
      );
    } catch (e) {
      setState(() {
        friendRequestStatus[friendId] = e.toString().replaceFirst('Exception: ', '');
      });
    }
  }

  Future<void> _startGameWithFriend(String friendId) async {
    try {
      // Create a game with the friend as the opponent
      String gameId = await ApiService.createGame(
        isRated: true, // Default to rated
        baseTime: 10, // Default time control base
        increment: 0, // Default increment
        betAmount: 0.0, // Default bet amount
      );

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => GameScreen(
            userId: widget.userId,
            initialPlayMode: 'online',
            timeControl: '10|0',
            opponentId: friendId,
            gameId: gameId, // Added required gameId
          ),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to start game: $e')),
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
        child: SafeArea(
          child: CustomScrollView(
            slivers: [
              // Header
              SliverAppBar(
                backgroundColor: ChessEarnTheme.themeColors['brand-dark'],
                pinned: true,
                title: Text(
                  'Friends',
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
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                  onPressed: () => Navigator.pop(context),
                ),
              ),

              // Online Friends Count
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Container(
                    padding: const EdgeInsets.all(16.0),
                    decoration: BoxDecoration(
                      color: ChessEarnTheme.themeColors['surface-dark']!.withOpacity(0.5),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.white.withOpacity(0.2)),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.online_prediction,
                          color: ChessEarnTheme.themeColors['brand-accent'],
                          size: 24,
                        ),
                        const SizedBox(width: 12),
                        Text(
                          '$onlineFriendsCount friend${onlineFriendsCount == 1 ? '' : 's'} online',
                          style: TextStyle(
                            color: ChessEarnTheme.themeColors['text-light'],
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // Connected Friends List
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Text(
                    'Your Friends',
                    style: TextStyle(
                      color: ChessEarnTheme.themeColors['text-light'],
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                sliver: isLoadingFriends
                    ? const SliverToBoxAdapter(child: Center(child: CircularProgressIndicator()))
                    : friendsErrorMessage != null
                        ? SliverToBoxAdapter(
                            child: Center(
                              child: Text(
                                friendsErrorMessage!,
                                style: TextStyle(color: ChessEarnTheme.themeColors['text-light']),
                              ),
                            ),
                          )
                        : connectedFriends.isEmpty
                            ? SliverToBoxAdapter(
                                child: Center(
                                  child: Text(
                                    'No friends yet. Search to add some!',
                                    style: TextStyle(color: ChessEarnTheme.themeColors['text-light']),
                                  ),
                                ),
                              )
                            : SliverList(
                                delegate: SliverChildBuilderDelegate(
                                  (context, index) {
                                    final friend = connectedFriends[index];
                                    final username = friend['username'] as String;
                                    final isOnline = friend['online'] as bool;
                                    final friendId = friend['id'] as String;

                                    return Card(
                                      color: ChessEarnTheme.themeColors['surface-dark'],
                                      margin: const EdgeInsets.symmetric(vertical: 4.0),
                                      child: ListTile(
                                        leading: CircleAvatar(
                                          backgroundColor: isOnline
                                              ? Colors.green
                                              : ChessEarnTheme.themeColors['text-muted'],
                                          child: Text(
                                            username[0],
                                            style: TextStyle(
                                              color: ChessEarnTheme.themeColors['text-light'],
                                            ),
                                          ),
                                        ),
                                        title: Text(
                                          username,
                                          style: TextStyle(
                                            color: ChessEarnTheme.themeColors['text-light'],
                                          ),
                                        ),
                                        subtitle: Text(
                                          isOnline ? 'Online' : 'Offline',
                                          style: TextStyle(
                                            color: isOnline
                                                ? Colors.green
                                                : ChessEarnTheme.themeColors['text-muted'],
                                          ),
                                        ),
                                        trailing: ElevatedButton(
                                          onPressed: () => _startGameWithFriend(friendId),
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: ChessEarnTheme.themeColors['brand-accent'],
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(8),
                                            ),
                                          ),
                                          child: const Text(
                                            'Play',
                                            style: TextStyle(color: Colors.white),
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                  childCount: connectedFriends.length,
                                ),
                              ),
              ),

              // Search Bar
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Search for new friends...',
                      hintStyle: TextStyle(color: ChessEarnTheme.themeColors['text-muted']),
                      prefixIcon: Icon(
                        Icons.search,
                        color: ChessEarnTheme.themeColors['brand-accent'],
                      ),
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
              ),

              // Search Results
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                sliver: isLoading
                    ? const SliverToBoxAdapter(child: Center(child: CircularProgressIndicator()))
                    : errorMessage != null
                        ? SliverToBoxAdapter(
                            child: Center(
                              child: Text(
                                errorMessage!,
                                style: TextStyle(color: ChessEarnTheme.themeColors['text-light']),
                              ),
                            ),
                          )
                        : searchResults.isEmpty && _searchController.text.isNotEmpty
                            ? SliverToBoxAdapter(
                                child: Center(
                                  child: Text(
                                    'No users found',
                                    style: TextStyle(color: ChessEarnTheme.themeColors['text-light']),
                                  ),
                                ),
                              )
                            : SliverList(
                                delegate: SliverChildBuilderDelegate(
                                  (context, index) {
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
                                          style: TextStyle(
                                            color: ChessEarnTheme.themeColors['text-light'],
                                          ),
                                        ),
                                        trailing: ElevatedButton(
                                          onPressed: isButtonDisabled
                                              ? null
                                              : () => _sendFriendRequest(userId),
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor:
                                                ChessEarnTheme.themeColors['brand-accent'],
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
                                  childCount: searchResults.length,
                                ),
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