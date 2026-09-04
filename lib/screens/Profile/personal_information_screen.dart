import 'package:flutter/material.dart';

import 'package:baby_shop_hub/core/mysql_service.dart';
import 'package:baby_shop_hub/core/user_session.dart';
import 'package:baby_shop_hub/utilities/models/user.dart';
import 'edit_profile_screen.dart';

class PersonalInformationScreen extends StatefulWidget {
  const PersonalInformationScreen({super.key});

  @override
  State<PersonalInformationScreen> createState() =>
      _PersonalInformationScreenState();
}

class _PersonalInformationScreenState extends State<PersonalInformationScreen> {
  final MySQLService _mysqlService = MySQLService();
  final UserSession _session = UserSession.instance;

  User? _user;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  Future<void> _loadUser() async {
    final userId = _session.userId;

    if (userId == null) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
      return;
    }

    try {
      final user = await _mysqlService.getUserById(userId);

      if (!mounted) return;

      setState(() {
        _user = user;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Unable to load profile: ${e.toString()}')),
      );
    }
  }

  Future<void> _openEditProfile() async {
    if (_user == null) return;

    final User? updatedUser = await Navigator.push<User>(
      context,
      MaterialPageRoute(builder: (context) => EditProfileScreen(user: _user!)),
    );

    if (updatedUser != null && mounted) {
      setState(() {
        _user = updatedUser;
      });
    }
  }

  Widget _buildProfileImage() {
    if (_user?.image != null && _user!.image!.isNotEmpty) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(28),
        child: Image.memory(
          _user!.image!,
          width: 90,
          height: 90,
          fit: BoxFit.cover,
        ),
      );
    }

    final String initial = (_user?.fullName.isNotEmpty ?? false)
        ? _user!.fullName[0].toUpperCase()
        : '?';

    return Container(
      width: 90,
      height: 90,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFFFB300), Color(0xFFFF6D00)],
        ),
        borderRadius: BorderRadius.circular(28),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Profile Picture View Display Panel
              Center(
                child: Column(
                  children: [
                    Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        color: Colors.orange.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.orange.withValues(alpha: 0.2), width: 2),
                      ),
                      child: const Center(
                        child: Text(
                          'E',
                          style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold, color: Colors.orange),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Emma Johnson',
                      style: TextStyle(fontSize: 14, color: Colors.grey.shade600, fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // 2. Information Display Cards Grid List
              const Text(
                'Account Details',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF1E1E24)),
              ),
              const SizedBox(height: 12),
              
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: Colors.grey.withValues(alpha: 0.08)),
                ),
                child: Column(
                  children: [
                    _buildInfoTile(Icons.person_outline_rounded, 'Full Name', 'Emma Johnson'),
                    _buildDivider(),
                    _buildInfoTile(Icons.email_outlined, 'Email Address', 'emma@example.com'),
                    _buildDivider(),
                    _buildInfoTile(Icons.phone_outlined, 'Phone Number', '+1 (555) 123-4567'),
                    _buildDivider(),
                    _buildInfoTile(Icons.cake_outlined, 'Date of Birth', 'May 16, 1992'),
                    _buildDivider(),
                    _buildInfoTile(Icons.wc_rounded, 'Gender', 'Female'),
                  ],
                ),
              ),
              const SizedBox(height: 40),

              // 3. Navigation CTA Trigger to swap forward into Edit mode panel
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const EditProfileScreen()),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    elevation: 0,
                  ),
                  child: const Text(
                    'Edit Profile',
                    style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
      child: Center(
        child: Text(
          initial,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 34,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildInformationRow({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFFFFF3EC),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: Colors.orange, size: 21),
          ),

          const SizedBox(width: 14),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                ),
                const SizedBox(height: 4),
                Text(
                  value.isEmpty ? 'Not provided' : value,
                  style: const TextStyle(
                    color: Color(0xFF1E1E24),
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF8F4),

      appBar: AppBar(
        backgroundColor: const Color(0xFFFFF8F4),
        elevation: 0,
        foregroundColor: const Color(0xFF1E1E24),
        title: const Text(
          'Personal Information',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),

      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.orange))
          : _user == null
          ? const Center(child: Text('No user information found.'))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  // ------------------------------------------------
                  // PROFILE HEADER
                  // ------------------------------------------------
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFFFFB300), Color(0xFFFF6D00)],
                      ),
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Column(
                      children: [
                        _buildProfileImage(),

                        const SizedBox(height: 14),

                        Text(
                          _user!.fullName,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 21,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        const SizedBox(height: 4),

                        Text(
                          _user!.email,
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.85),
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // ------------------------------------------------
                  // INFORMATION
                  // ------------------------------------------------
                  _buildInformationRow(
                    icon: Icons.person_outline_rounded,
                    title: 'Full Name',
                    value: _user!.fullName,
                  ),

                  _buildInformationRow(
                    icon: Icons.email_outlined,
                    title: 'Email Address',
                    value: _user!.email,
                  ),

                  _buildInformationRow(
                    icon: Icons.location_on_outlined,
                    title: 'Address',
                    value: _user!.address ?? '',
                  ),

                  const SizedBox(height: 12),

                  // ------------------------------------------------
                  // EDIT BUTTON
                  // ------------------------------------------------
                  SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: ElevatedButton.icon(
                      onPressed: _openEditProfile,
                      icon: const Icon(Icons.edit_rounded),
                      label: const Text(
                        'Edit Profile',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
