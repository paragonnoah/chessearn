import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:chessearn/services/api_service.dart';
import 'package:chessearn/theme.dart';

class ProfileScreen extends StatefulWidget {
  final String? userId;

  const ProfileScreen({super.key, required this.userId});

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String errorMessage = '';
  bool isLoading = true;
  Map<String, dynamic>? userData;
  String? photoUrl;
  final ImagePicker _picker = ImagePicker(); // Instantiate ImagePicker

  @override
  void initState() {
    super.initState();
    if (widget.userId != null) {
      _fetchProfile();
    } else {
      setState(() {
        errorMessage = 'User ID not found. Please log in.';
        isLoading = false;
      });
    }
  }

  Future<void> _fetchProfile() async {
    setState(() {
      isLoading = true;
      errorMessage = '';
    });

    try {
      final response = await ApiService.getProfile(userId: widget.userId!);
      if (response.statusCode == 200) {
        setState(() {
          userData = jsonDecode(response.body);
          photoUrl = userData?['photo_url'];
          isLoading = false;
        });
      } else {
        setState(() {
          errorMessage = 'Failed to load profile: ${response.statusCode} - ${response.body}';
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = 'Network error: $e';
        isLoading = false;
      });
    }
  }

  Future<void> _uploadPhoto() async {
    if (widget.userId == null) {
      setState(() {
        errorMessage = 'Please log in to upload a photo.';
      });
      return;
    }

    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile == null) return;

    setState(() => isLoading = true);
    try {
      final response = await ApiService.uploadProfilePhoto(
        userId: widget.userId!,
        filePath: pickedFile.path,
      );
      if (response.statusCode == 200) {
        await _fetchProfile(); // Refresh profile to update photo_url
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Photo uploaded successfully')),
        );
      } else {
        setState(() {
          errorMessage = 'Failed to upload photo: ${response.statusCode} - ${response.body}';
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = 'Upload error: $e';
      });
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
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
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: isLoading
              ? const Center(child: CircularProgressIndicator(color: Colors.white))
              : userData == null
                  ? Center(child: Text(errorMessage, style: TextStyle(color: ChessEarnTheme.themeColors['brand-danger'], fontSize: 16)))
                  : SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Center(
                            child: Column(
                              children: [
                                CircleAvatar(
                                  radius: 50,
                                  backgroundImage: photoUrl != null ? NetworkImage(photoUrl!) : null,
                                  child: photoUrl == null ? const Icon(Icons.person, size: 50) : null,
                                ),
                                const SizedBox(height: 10),
                                ElevatedButton(
                                  onPressed: widget.userId != null ? () => _uploadPhoto() : null, // Wrap in lambda to match VoidCallback
                                  child: const Text('Upload Photo'),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 20),
                          Text(
                            'User Profile',
                            style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: ChessEarnTheme.themeColors['text-light']),
                          ),
                          const SizedBox(height: 20),
                          _buildProfileField('ID', userData!['id']),
                          _buildProfileField('First Name', userData!['first_name']),
                          _buildProfileField('Last Name', userData!['last_name']),
                          _buildProfileField('Email', userData!['email']),
                          _buildProfileField('Username', userData!['username']),
                          _buildProfileField('Phone Number', userData!['phone_number']),
                          _buildProfileField('Role', userData!['role']),
                          _buildProfileField('Ranking', userData!['ranking'].toString()),
                          _buildProfileField('Wallet Balance', userData!['wallet_balance'].toString()),
                          _buildProfileField('Active', userData!['is_active'].toString()),
                          _buildProfileField('Verified', userData!['is_verified'].toString()),
                          if (errorMessage.isNotEmpty)
                            Text(errorMessage, style: TextStyle(color: ChessEarnTheme.themeColors['brand-danger'])),
                          const SizedBox(height: 20),
                          ElevatedButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text('Back to Game'),
                          ),
                        ],
                      ),
                    ),
        ),
      ),
    );
  }

  Widget _buildProfileField(String label, dynamic value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(fontSize: 16, color: ChessEarnTheme.themeColors['text-muted']),
          ),
          Text(
            value.toString(),
            style: TextStyle(fontSize: 16, color: ChessEarnTheme.themeColors['text-light']),
          ),
        ],
      ),
    );
  }
}