import 'package:flutter/material.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF8F4),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // TOP PROFILE HEADER
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(20, 60, 20, 30),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFFFF8A3D), Color(0xFFFF6B00)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Row(
                children: [
                  // Profile Avatar
                  Container(
                    width: 70,
                    height: 70,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    alignment: Alignment.center,
                    child: const Text(
                      'E',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),

                  const SizedBox(width: 16),

                  // User Details
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Emma Johnson',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),

                        const SizedBox(height: 4),

                        Text(
                          'emma@example.com',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.white.withOpacity(0.9),
                          ),
                        ),

                        const SizedBox(height: 8),

                        // Premium Badge
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.star, size: 14, color: Colors.white),
                              SizedBox(width: 4),
                              Text(
                                'Premium Member',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Edit Button
                  IconButton(
                    icon: const Icon(
                      Icons.edit_note,
                      color: Colors.white,
                      size: 28,
                    ),
                    onPressed: () {},
                  ),
                ],
              ),
            ),

            // ============================================================
            // STATS CARD
            // ============================================================
            Transform.translate(
              offset: const Offset(0, -15),
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 20),
                padding: const EdgeInsets.symmetric(vertical: 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildStatItem('3', 'Orders'),

                    Container(
                      width: 1,
                      height: 30,
                      color: Colors.grey.shade200,
                    ),

                    _buildStatItem('12', 'Wishlist'),

                    Container(
                      width: 1,
                      height: 30,
                      color: Colors.grey.shade200,
                    ),

                    _buildStatItem('5', 'Reviews'),
                  ],
                ),
              ),
            ),

            // ============================================================
            // SETTINGS SECTION
            // ============================================================
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  // Push Notifications
                  _buildNotificationTile(),

                  const SizedBox(height: 12),

                  // ======================================================
                  // MENU OPTIONS
                  // ======================================================
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.grey.shade100),
                    ),
                    child: Column(
                      children: [
                        _buildMenuTile(
                          Icons.person_outline,
                          'Personal Information',
                          'Edit your profile details',
                        ),

                        _buildDivider(),

                        _buildMenuTile(
                          Icons.location_on_outlined,
                          'Delivery Addresses',
                          'Manage saved addresses',
                        ),

                        _buildDivider(),

                        _buildMenuTile(
                          Icons.credit_card_outlined,
                          'Payment Methods',
                          'Cards & payment options',
                        ),

                        _buildDivider(),

                        _buildMenuTile(
                          Icons.card_giftcard_outlined,
                          'My Wishlist',
                          'Saved favorite products',
                        ),

                        _buildDivider(),

                        _buildMenuTile(
                          Icons.lock_open_outlined,
                          'Privacy & Security',
                          'Password & account security',
                        ),

                        _buildDivider(),

                        _buildMenuTile(
                          Icons.settings_outlined,
                          'App Settings',
                          'Language, theme & more',
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // ADMIN PANEL
                  Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFFF9F5FF),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFFEADBFF)),
                    ),
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 4,
                      ),

                      leading: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF4EBFF),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.bar_chart_rounded,
                          color: Color(0xFF7F56D9),
                        ),
                      ),

                      title: const Text(
                        'Admin Panel',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF6941C6),
                        ),
                      ),

                      subtitle: const Text(
                        'Manage products, orders & users',
                        style: TextStyle(
                          color: Color(0xFF7F56D9),
                          fontSize: 12,
                        ),
                      ),

                      trailing: const Icon(
                        Icons.arrow_forward_ios,
                        size: 14,
                        color: Color(0xFF7F56D9),
                      ),

                      onTap: () {
                        // TODO: Navigate to Admin Panel
                      },
                    ),
                  ),

                  const SizedBox(height: 24),

                  // ======================================================
                  // SIGN OUT BUTTON
                  // ======================================================
                  SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: TextButton.icon(
                      style: TextButton.styleFrom(
                        backgroundColor: const Color(0xFFFFF1F1),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),

                      icon: const Icon(Icons.logout, color: Colors.redAccent),

                      label: const Text(
                        'Sign Out',
                        style: TextStyle(
                          color: Colors.redAccent,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),

                      onPressed: () {
                        // TODO: Add sign out functionality
                      },
                    ),
                  ),

                  const SizedBox(height: 40),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ================================================================
  // STAT ITEM
  // ================================================================
  Widget _buildStatItem(String count, String label) {
    return Column(
      children: [
        Text(
          count,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),

        const SizedBox(height: 4),

        Text(label, style: const TextStyle(fontSize: 13, color: Colors.grey)),
      ],
    );
  }

  // ================================================================
  // NOTIFICATION TILE
  // ================================================================
  Widget _buildNotificationTile() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),

        // Icon
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: const Color(0xFFFFF6F0),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Icon(
            Icons.notifications_none_outlined,
            color: Colors.orange,
          ),
        ),

        // Title
        title: const Text(
          'Push Notifications',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),

        // Subtitle
        subtitle: const Text(
          'Order updates & offers',
          style: TextStyle(fontSize: 12),
        ),

        // Switch
        trailing: Switch(
          value: true,
          activeColor: Colors.white,
          activeTrackColor: Colors.orange,
          onChanged: (value) {
            // TODO: Handle notification setting
          },
        ),
      ),
    );
  }

  // ================================================================
  // MENU TILE
  // ================================================================
  Widget _buildMenuTile(IconData icon, String title, String subtitle) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),

      // Icon
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: const Color(0xFFFFF6F0),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: Colors.orange),
      ),

      // Title
      title: Text(
        title,
        style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
      ),

      // Subtitle
      subtitle: Text(
        subtitle,
        style: const TextStyle(fontSize: 12, color: Colors.grey),
      ),

      // Arrow
      trailing: const Icon(
        Icons.arrow_forward_ios,
        size: 14,
        color: Colors.grey,
      ),

      onTap: () {
        // TODO: Navigate to selected screen
      },
    );
  }

  // ================================================================
  // DIVIDER
  // ================================================================
  Widget _buildDivider() {
    return Divider(
      height: 1,
      thickness: 1,
      indent: 70,
      color: Colors.grey.shade100,
    );
  }
}
