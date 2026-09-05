import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:baby_shop_hub/core/mysql_service.dart';
import 'package:baby_shop_hub/core/user_session.dart';
import 'package:baby_shop_hub/utilities/models/user.dart';

import 'personal_information_screen.dart';
import 'delivery_addresses_screen.dart';
import 'payment_methods_screen.dart';
import 'my_wishlist_screen.dart';
import 'privacy_security_screen.dart';
import 'app_settings_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final MySQLService _mysqlService = MySQLService();
  final UserSession _userSession = UserSession.instance;

  User? _user;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  // ============================================================
  // LOAD CURRENT USER
  // ============================================================

  Future<void> _loadUser() async {
    final String? userId = _userSession.userId;

    if (userId == null || userId.isEmpty) {
      if (!mounted) return;

      setState(() {
        _isLoading = false;
      });

      return;
    }

    try {
      final User user = await _mysqlService.getUserById(userId);

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
        SnackBar(
          content: Text(
            'Unable to load profile: '
            '${e.toString().replaceFirst('Exception: ', '')}',
          ),
        ),
      );
    }
  }

  // ============================================================
  // OPEN PERSONAL INFORMATION
  // ============================================================

  Future<void> _openPersonalInformation() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const PersonalInformationScreen(),
      ),
    );

    // Reload profile when returning.
    await _loadUser();
  }

  // ============================================================
  // PROFILE AVATAR
  // ============================================================

  Widget _buildProfileAvatar() {
    if (_user?.image != null && _user!.image!.isNotEmpty) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Image.memory(
          _user!.image!,
          width: 72,
          height: 72,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return _buildInitialAvatar();
          },
        ),
      );
    }

    return _buildInitialAvatar();
  }

  Widget _buildInitialAvatar() {
    final String initial = _user != null && _user!.fullName.trim().isNotEmpty
        ? _user!.fullName.trim()[0].toUpperCase()
        : '?';

    return Container(
      width: 72,
      height: 72,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Center(
        child: Text(
          initial,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 32,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  // ============================================================
  // PROFILE HEADER
  // ============================================================

  Widget _buildProfileHeader(BuildContext context) {
    if (_isLoading) {
      return Container(
        width: double.infinity,
        padding: EdgeInsets.only(
          top: MediaQuery.of(context).padding.top + 20,
          bottom: 24,
          left: 24,
          right: 24,
        ),
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFFFB300), Color(0xFFFF6D00)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(32)),
        ),
        child: const SizedBox(
          height: 180,
          child: Center(child: CircularProgressIndicator(color: Colors.white)),
        ),
      );
    }

    final String name = _user?.fullName.isNotEmpty == true
        ? _user!.fullName
        : 'User';

    final String email = _user?.email.isNotEmpty == true
        ? _user!.email
        : 'No email available';

    return Container(
      width: double.infinity,
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 20,
        bottom: 24,
        left: 24,
        right: 24,
      ),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFFFFB300), Color(0xFFFF6D00)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(32)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              _buildProfileAvatar(),

              const SizedBox(width: 16),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 4),

                    Text(
                      email,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.85),
                        fontSize: 13,
                      ),
                    ),

                    const SizedBox(height: 6),

                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.25),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.star, color: Colors.white, size: 12),
                          SizedBox(width: 4),
                          Text(
                            'Premium Member',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              IconButton(
                icon: const Icon(
                  Icons.edit_square,
                  color: Colors.white,
                  size: 22,
                ),
                onPressed: _openPersonalInformation,
              ),
            ],
          ),

          const SizedBox(height: 28),

          // ======================================================
          // STATS
          // ======================================================
          Container(
            padding: const EdgeInsets.symmetric(vertical: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildStatColumn('3', 'Orders'),

                Container(width: 1, height: 30, color: Colors.grey.shade200),

                _buildStatColumn('12', 'Wishlist'),

                Container(width: 1, height: 30, color: Colors.grey.shade200),

                _buildStatColumn('5', 'Reviews'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // STAT COLUMN
  // ============================================================

  Widget _buildStatColumn(String count, String label) {
    return Column(
      children: [
        Text(
          count,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1E1E24),
          ),
        ),

        const SizedBox(height: 2),

        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: Colors.grey,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  // ============================================================
  // NOTIFICATION TILE
  // ============================================================

  Widget _buildNotificationTile() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.withValues(alpha: 0.06)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFFFFF3EC),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(
              Icons.notifications_none_rounded,
              color: Colors.orange,
              size: 22,
            ),
          ),

          const SizedBox(width: 14),

          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Push Notifications',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                    color: Color(0xFF1E1E24),
                  ),
                ),

                SizedBox(height: 2),

                Text(
                  'Order updates & offers',
                  style: TextStyle(color: Colors.grey, fontSize: 12),
                ),
              ],
            ),
          ),

          Switch(value: true, onChanged: null),
        ],
      ),
    );
  }

  // ============================================================
  // MENU TILE
  // ============================================================

  Widget _buildMenuTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: const Color(0xFFFFF3EC),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Icon(icon, color: Colors.orange, size: 22),
      ),

      title: Text(
        title,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 15,
          color: Color(0xFF1E1E24),
        ),
      ),

      subtitle: Text(
        subtitle,
        style: const TextStyle(color: Colors.grey, fontSize: 12),
      ),

      trailing: const Icon(
        Icons.arrow_forward_ios_rounded,
        size: 14,
        color: Colors.grey,
      ),

      onTap: onTap,
    );
  }

  // ============================================================
  // ADMIN PANEL
  // ============================================================

  Widget _buildAdminPanelTile() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFFBF4FF),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.purple.withValues(alpha: 0.08)),
      ),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: const Color(0xFFF3E5F5),
            borderRadius: BorderRadius.circular(14),
          ),
          child: const Icon(
            Icons.bar_chart_rounded,
            color: Colors.purple,
            size: 22,
          ),
        ),

        title: const Text(
          'Admin Panel',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 15,
            color: Colors.purple,
          ),
        ),

        subtitle: const Text(
          'Manage products, orders & users',
          style: TextStyle(color: Colors.purple, fontSize: 12),
        ),

        trailing: const Icon(
          Icons.arrow_forward_ios_rounded,
          size: 14,
          color: Colors.purple,
        ),

        onTap: () {
          // Admin navigation can be connected here later.
        },
      ),
    );
  }

  // ============================================================
  // SIGN OUT
  // ============================================================

  Future<void> _signOut() async {
    final bool? shouldSignOut = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text(
            'Sign Out',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          content: const Text('Are you sure you want to sign out?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context, false);
              },
              child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
            ),

            ElevatedButton(
              onPressed: () {
                Navigator.pop(context, true);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
                foregroundColor: Colors.white,
              ),
              child: const Text('Sign Out'),
            ),
          ],
        );
      },
    );

    if (shouldSignOut != true) {
      return;
    }

    await UserSession.logout();

    if (!mounted) return;

    // Go back to login using GoRouter.
    context.go('/login');
  }

  // ============================================================
  // SIGN OUT BUTTON
  // ============================================================

  Widget _buildSignOutButton() {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: TextButton.icon(
        onPressed: _signOut,
        style: TextButton.styleFrom(
          backgroundColor: const Color(0xFFFFEBEE),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        ),
        icon: const Icon(
          Icons.logout_rounded,
          color: Colors.redAccent,
          size: 20,
        ),
        label: const Text(
          'Sign Out',
          style: TextStyle(
            color: Colors.redAccent,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
      ),
    );
  }

  // ============================================================
  // DIVIDER
  // ============================================================

  Widget _buildDivider() {
    return Padding(
      padding: const EdgeInsets.only(left: 70, right: 14),
      child: Divider(height: 1, color: Colors.grey.withValues(alpha: 0.1)),
    );
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF8F4),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          children: [
            _buildProfileHeader(context),

            const SizedBox(height: 20),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  // ==================================================
                  // NOTIFICATIONS
                  // ==================================================
                  _buildNotificationTile(),

                  const SizedBox(height: 16),

                  // ==================================================
                  // PROFILE MENU
                  // ==================================================
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(
                        color: Colors.grey.withValues(alpha: 0.06),
                      ),
                    ),
                    child: Column(
                      children: [
                        _buildMenuTile(
                          icon: Icons.person_outline_rounded,
                          title: 'Personal Information',
                          subtitle: 'Edit your profile details',
                          onTap: _openPersonalInformation,
                        ),

                        _buildDivider(),

                        _buildMenuTile(
                          icon: Icons.location_on_outlined,
                          title: 'Delivery Addresses',
                          subtitle: 'Manage saved addresses',
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    const DeliveryAddressesScreen(),
                              ),
                            );
                          },
                        ),

                        _buildDivider(),

                        _buildMenuTile(
                          icon: Icons.credit_card_outlined,
                          title: 'Payment Methods',
                          subtitle: 'Cards & payment options',
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    const PaymentMethodsScreen(),
                              ),
                            );
                          },
                        ),

                        _buildDivider(),

                        _buildMenuTile(
                          icon: Icons.card_giftcard_outlined,
                          title: 'My Wishlist',
                          subtitle: 'Saved favorite products',
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const MyWishlistScreen(),
                              ),
                            );
                          },
                        ),

                        _buildDivider(),

                        _buildMenuTile(
                          icon: Icons.shield_outlined,
                          title: 'Privacy & Security',
                          subtitle: 'Password & account security',
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    const PrivacySecurityScreen(),
                              ),
                            );
                          },
                        ),

                        _buildDivider(),

                        _buildMenuTile(
                          icon: Icons.settings_outlined,
                          title: 'App Settings',
                          subtitle: 'Language, theme & more',
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const AppSettingsScreen(),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // ==================================================
                  // ADMIN PANEL
                  // ==================================================
                  _buildAdminPanelTile(),

                  const SizedBox(height: 16),

                  // ==================================================
                  // SIGN OUT
                  // ==================================================
                  _buildSignOutButton(),

                  const SizedBox(height: 40),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
