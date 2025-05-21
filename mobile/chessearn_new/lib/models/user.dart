class User {
  final String id;
  final String username;
  final String email;
  final String phone;
  final String accessToken;
  int ranking;
  String? imageUrl;
  int totalGames;
  int wins;
  int losses;
  DateTime joinDate;

  User({
    required this.id,
    required this.username,
    required this.email,
    required this.phone,
    required this.accessToken,
    required this.ranking,
    this.imageUrl,
    required this.totalGames,
    required this.wins,
    required this.losses,
    required this.joinDate,
  });

  // Convert User to JSON for storage/API
  Map<String, dynamic> toJson() => {
        'id': id,
        'username': username,
        'email': email,
        'phone': phone,
        'access_token': accessToken,
        'ranking': ranking,
        'imageUrl': imageUrl,
        'totalGames': totalGames,
        'wins': wins,
        'losses': losses,
        'joinDate': joinDate.toIso8601String(),
      };

  // Create User from JSON
  factory User.fromJson(Map<String, dynamic> json) => User(
        id: json['id'] ?? '',
        username: json['username'],
        email: json['email'],
        phone: json['phone'],
        accessToken: json['access_token'] ?? '',
        ranking: json['ranking'] ?? 0,
        imageUrl: json['imageUrl'],
        totalGames: json['totalGames'] ?? 0,
        wins: json['wins'] ?? 0,
        losses: json['losses'] ?? 0,
        joinDate: DateTime.parse(json['joinDate'] ?? DateTime.now().toIso8601String()),
      );
}