import 'package:flutter/material.dart';

class AppSettingsScreen extends StatefulWidget {
  const AppSettingsScreen({super.key});

  @override
  State<AppSettingsScreen> createState() => _AppSettingsScreenState();
}

class _AppSettingsScreenState extends State<AppSettingsScreen> {
  bool _orderUpdates = true;
  bool _promoOffers = true;
  bool _wishlistAlerts = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF8F4),
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
          'App Settings',
          style: TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Preferences Section
              const Text(
                'Preferences',
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
                    _buildSelectionRow('Language', 'English '),
                    _buildDivider(),
                    _buildSelectionRow('Currency', 'USD (\$) '),
                    _buildDivider(),
                    _buildSelectionRow('Theme', 'System '),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Notifications Section
              const Text(
                'Notifications',
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
                    _buildToggleRow(
                      'Order Updates',
                      _orderUpdates,
                      (val) => setState(() => _orderUpdates = val),
                    ),
                    _buildDivider(),
                    _buildToggleRow(
                      'Promotions & Offers',
                      _promoOffers,
                      (val) => setState(() => _promoOffers = val),
                    ),
                    _buildDivider(),
                    _buildToggleRow(
                      'Wishlist Alerts',
                      _wishlistAlerts,
                      (val) => setState(() => _wishlistAlerts = val),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Other Section
              const Text(
                'Other',
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
                    _buildSelectionRow('Clear Cache', '15.6 MB >'),
                    _buildDivider(),
                    _buildSelectionRow('Rate Our App', '>'),
                    _buildDivider(),
                    _buildSelectionRow('About App', 'Version 1.0.0 >'),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSelectionRow(String title, String trailingText) {
    return ListTile(
      title: Text(
        title,
        style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
      ),
      trailing: Text(
        trailingText,
        style: const TextStyle(color: Colors.grey, fontSize: 14),
      ),
      onTap: () {},
    );
  }

  Widget _buildToggleRow(
    String title,
    bool value,
    ValueChanged<bool> onChanged,
  ) {
    return ListTile(
      title: Text(
        title,
        style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
      ),
      trailing: Switch(
        value: value,
        onChanged: onChanged,
        activeColor: const Color(0xFFFF6D00),
        activeTrackColor: const Color(0xFFFF6D00).withOpacity(0.2),
      ),
    );
  }

  Widget _buildDivider() =>
      Divider(height: 1, indent: 16, color: Colors.grey.withOpacity(0.15));
}
