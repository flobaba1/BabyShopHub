import 'package:shared_preferences/shared_preferences.dart';
import 'package:baby_shop_hub/utilities/models/user.dart';

class UserSession {
  static const String _keyIsLoggedIn = 'is_logged_in';
  static const String _keyUserId = 'user_id';
  static const String _keyUserName = 'user_name';
  static const String _keyUserEmail = 'user_email';
  static const String _keyIsAdmin = 'is_admin';
  static const String _KeyUserStatus = 'user_status';

  // List of all keys associated with an active user session
  static const List<String> _sessionKeys = [
    _keyIsLoggedIn,
    _keyUserId,
    _keyUserName,
    _keyUserEmail,
    _keyIsAdmin,
    _KeyUserStatus,
  ];

  static User? loggedUser;

  /// Save user session upon successful login
  static Future<void> saveUserSession(User user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyIsLoggedIn, true);
    await prefs.setString(_keyUserId, user.id);
    await prefs.setString(_keyUserName, user.fullName);
    await prefs.setString(_keyUserEmail, user.email);
    await prefs.setBool(_keyIsAdmin, user.isAdmin);
    await prefs.setString(_KeyUserStatus, user.status);
    loggedUser = user; // Store the user in memory for quick access
  }

  /// Retrieve user session data from SharedPreferences
  static Future<void> loadUserSession() async {
    final prefs = await SharedPreferences.getInstance();
    final bool isLoggedIn = prefs.getBool(_keyIsLoggedIn) ?? false;

    if (!isLoggedIn) {
      loggedUser = null; // Return an empty session if not logged in
    }

    final String userId = prefs.getString(_keyUserId) ?? '';
    final String userName = prefs.getString(_keyUserName) ?? '';
    final String userEmail = prefs.getString(_keyUserEmail) ?? '';
    final bool isAdmin = prefs.getBool(_keyIsAdmin) ?? false;
    final String userStatus = prefs.getString(_KeyUserStatus) ?? '';

    if (userId.isEmpty || userName.isEmpty || userEmail.isEmpty) {
      loggedUser = null;
      return; // Return an empty session if any essential data is missing
    }

    loggedUser = User(
      id: userId,
      fullName: userName,
      email: userEmail,
      isAdmin: isAdmin,
      status: userStatus,
    );
  }

  /// Check if user is logged in
  static Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyIsLoggedIn) ?? false;
  }

  /// Get stored User ID
  static Future<String?> getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyUserId);
  }
 

  /// Clear ONLY session-related data during explicit logout
  /// Preserves onboarding flags and other app preferences
  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    
    for (final key in _sessionKeys) {
      await prefs.remove(key);
    }
  }
}