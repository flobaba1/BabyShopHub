import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:baby_shop_hub/core/mysql_service.dart';
import 'package:baby_shop_hub/core/user_session.dart';

class PrivacySecurityScreen extends StatefulWidget {
  const PrivacySecurityScreen({super.key});

  @override
  State<PrivacySecurityScreen> createState() => _PrivacySecurityScreenState();
}

class _PrivacySecurityScreenState extends State<PrivacySecurityScreen> {
  final MySQLService _mysqlService = MySQLService();

  bool _twoFactorEnabled = false;
  bool _isLoadingTwoFactor = true;
  bool _isUpdatingTwoFactor = false;

  // ============================================================
  // GET CURRENT USER ID
  // ============================================================
  String? get _userId => UserSession.loggedUser?.id;

  @override
  void initState() {
    super.initState();
    _loadTwoFactorStatus();
  }

  // ============================================================
  // LOAD 2FA STATUS FROM MYSQL
  // ============================================================
  Future<void> _loadTwoFactorStatus() async {
    final String? userId = _userId;

    if (userId == null || userId.isEmpty) {
      if (!mounted) return;

      setState(() {
        _isLoadingTwoFactor = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No logged-in user was found. Please log in again.'),
          backgroundColor: Colors.redAccent,
          behavior: SnackBarBehavior.floating,
        ),
      );

      return;
    }

    try {
      final bool status = await _mysqlService.getTwoFactorStatus(userId);

      if (!mounted) return;

      setState(() {
        _twoFactorEnabled = status;
        _isLoadingTwoFactor = false;
      });
    } catch (error) {
      if (!mounted) return;

      setState(() {
        _isLoadingTwoFactor = false;
      });

      final String errorMessage = error.toString().replaceAll(
        'Exception: ',
        '',
      );

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Could not load security settings: $errorMessage'),
          backgroundColor: Colors.redAccent,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  // ============================================================
  // TOGGLE 2FA
  // ============================================================
  Future<void> _toggleTwoFactor(bool newValue) async {
    // Prevent another update while one is already running.
    if (_isUpdatingTwoFactor) {
      return;
    }

    final String? userId = _userId;

    if (userId == null || userId.isEmpty) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Your session has expired. Please log in again.'),
          backgroundColor: Colors.redAccent,
          behavior: SnackBarBehavior.floating,
        ),
      );

      return;
    }

    // ==========================================================
    // CONFIRMATION DIALOG
    // ==========================================================
    final bool? confirmed = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Text(
            newValue
                ? 'Enable Two-Factor Authentication?'
                : 'Disable Two-Factor Authentication?',
            style: const TextStyle(
              fontSize: 19,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          content: Text(
            newValue
                ? 'You will be required to enter a verification code whenever you log in to your account.'
                : 'You will no longer be required to enter a verification code when you log in.',
            style: const TextStyle(
              fontSize: 14,
              height: 1.5,
              color: Colors.grey,
            ),
          ),
          actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext, false);
              },
              child: const Text(
                'Cancel',
                style: TextStyle(
                  color: Colors.grey,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(dialogContext, true);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFF6500),
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                newValue ? 'Enable' : 'Disable',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        );
      },
    );

    // User cancelled.
    if (confirmed != true) {
      return;
    }

    if (!mounted) return;

    // ==========================================================
    // UPDATE MYSQL
    // ==========================================================
    setState(() {
      _isUpdatingTwoFactor = true;
    });

    try {
      await _mysqlService.updateTwoFactorStatus(
        userId: userId,
        enabled: newValue,
      );

      if (!mounted) return;

      setState(() {
        _twoFactorEnabled = newValue;
        _isUpdatingTwoFactor = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            newValue
                ? 'Two-Factor Authentication enabled'
                : 'Two-Factor Authentication disabled',
          ),
          backgroundColor: newValue ? Colors.green : Colors.redAccent,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
    } catch (error) {
      if (!mounted) return;

      setState(() {
        _isUpdatingTwoFactor = false;
      });

      final String errorMessage = error.toString().replaceAll(
        'Exception: ',
        '',
      );

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Could not update Two-Factor Authentication: $errorMessage',
          ),
          backgroundColor: Colors.redAccent,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
    }
  }

  // ============================================================
  // LOGOUT
  // ============================================================
  void _logout() {
    UserSession.logout();
    context.go('/login');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF8F4),

      // ==========================================================
      // APP BAR
      // ==========================================================
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new,
            color: Colors.black87,
            size: 20,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Privacy & Security',
          style: TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
      ),

      // ==========================================================
      // BODY
      // ==========================================================
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ========================================================
              // SECURITY
              // ========================================================
              const Text(
                'Security',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey,
                ),
              ),

              const SizedBox(height: 10),

              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  children: [
                    _buildSettingsRow(
                      Icons.lock_outline_rounded,
                      'Change Password',
                      trailing: const Icon(
                        Icons.arrow_forward_ios_rounded,
                        size: 14,
                        color: Colors.grey,
                      ),
                    ),

                    _buildDivider(),

                    // ==================================================
                    // TWO FACTOR AUTHENTICATION
                    // ==================================================
                    _buildSettingsRow(
                      Icons.verified_user_outlined,
                      'Two-Factor Authentication',
                      trailing: _buildTwoFactorSwitch(),
                    ),

                    _buildDivider(),

                    _buildSettingsRow(
                      Icons.devices_rounded,
                      'Login Activity',
                      trailing: const Icon(
                        Icons.arrow_forward_ios_rounded,
                        size: 14,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // ========================================================
              // PRIVACY
              // ========================================================
              const Text(
                'Privacy',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey,
                ),
              ),

              const SizedBox(height: 10),

              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  children: [
                    _buildSettingsRow(
                      Icons.folder_shared_outlined,
                      'Manage Data',
                      subtitle: 'Download or delete your data',
                    ),

                    _buildDivider(),

                    _buildSettingsRow(
                      Icons.privacy_tip_outlined,
                      'Privacy Policy',
                      subtitle: 'Read our privacy policy',
                    ),

                    _buildDivider(),

                    _buildSettingsRow(
                      Icons.block_flipped,
                      'Blocked Users',
                      subtitle: 'Manage blocked accounts',
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // ========================================================
              // LOGOUT
              // ========================================================
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: ListTile(
                  leading: const Icon(
                    Icons.logout_rounded,
                    color: Colors.redAccent,
                  ),
                  title: const Text(
                    'Logout',
                    style: TextStyle(
                      color: Colors.redAccent,
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                  onTap: _logout,
                ),
              ),

              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  // ============================================================
  // 2FA SWITCH
  // ============================================================
  Widget _buildTwoFactorSwitch() {
    if (_isLoadingTwoFactor) {
      return const SizedBox(
        width: 24,
        height: 24,
        child: Padding(
          padding: EdgeInsets.all(3),
          child: CircularProgressIndicator(
            strokeWidth: 2.5,
            color: Color(0xFFFF6500),
          ),
        ),
      );
    }

    return Switch(
      value: _twoFactorEnabled,
      onChanged: _isUpdatingTwoFactor ? null : _toggleTwoFactor,
      activeThumbColor: Colors.white,
      activeTrackColor: Color(0xFFFF6500),
      inactiveThumbColor: Colors.white,
      inactiveTrackColor: Colors.grey.shade300,
    );
  }

  // ============================================================
  // SETTINGS ROW
  // ============================================================
  Widget _buildSettingsRow(
    IconData icon,
    String title, {
    String? subtitle,
    Widget? trailing,
  }) {
    return ListTile(
      leading: Icon(icon, color: Colors.black87, size: 22),
      title: Text(
        title,
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
      ),
      subtitle: subtitle != null
          ? Text(
              subtitle,
              style: const TextStyle(color: Colors.grey, fontSize: 12),
            )
          : null,
      trailing:
          trailing ??
          const Icon(
            Icons.arrow_forward_ios_rounded,
            size: 14,
            color: Colors.grey,
          ),
      onTap: () {},
    );
  }

  // ============================================================
  // DIVIDER
  // ============================================================
  Widget _buildDivider() {
    return Divider(height: 1, indent: 56, color: Colors.grey.withOpacity(0.15));
  }
}
