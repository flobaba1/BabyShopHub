import 'package:flutter/material.dart';
import 'edit_profile_screen.dart'; // Import your edit form file

class PersonalInformationScreen extends StatelessWidget {
  const PersonalInformationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF8F4), // Theme background hue matching your styling rules
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Color(0xFF1E1E24)),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Personal Information',
          style: TextStyle(color: Color(0xFF1E1E24), fontWeight: FontWeight.bold, fontSize: 18),
        ),
        centerTitle: true,
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
          ),
        ),
      ),
    );
  }

  Widget _buildInfoTile(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16),
      child: Row(
        children: [
          Icon(icon, color: Colors.orange.shade400, size: 22),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.w500)),
              const SizedBox(height: 4),
              Text(value, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF1E1E24))),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDivider() => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: Divider(height: 1, color: Colors.grey.withValues(alpha: 0.08)),
      );
}
