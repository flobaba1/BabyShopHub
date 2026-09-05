import 'package:shared_preferences/shared_preferences.dart';
import 'package:baby_shop_hub/utilities/models/user.dart';

class UserSession {
  // Singleton instance.
  static final UserSession instance = UserSession._internal();

  UserSession._internal();

  // SharedPreferences keys.
  static const String _keyIsLoggedIn = 'is_logged_in';
  static const String _keyUserId = 'user_id';
  static const String _keyUserName = 'user_name';
  static const String _keyUserEmail = 'user_email';
  static const String _keyIsAdmin = 'is_admin';
  static const String _keyUserStatus = 'user_status';

  // Current logged-in user.
  static User? loggedUser;

  // ---------------------------------------------------------------------------
  // INSTANCE GETTERS
  // ---------------------------------------------------------------------------

  /// Current user's ID.
  String? get userId => loggedUser?.id;

  /// Current user's full name.
  String? get userName => loggedUser?.fullName;

  /// Current user's email.
  String? get userEmail => loggedUser?.email;

  /// Whether the current user is an admin.
  bool get isAdmin => loggedUser?.isAdmin ?? false;

  /// Current user's status.
  String? get userStatus => loggedUser?.status;

  // ---------------------------------------------------------------------------
  // SAVE SESSION
  // ---------------------------------------------------------------------------

  /// Save the logged-in user's information locally.
  static Future<void> saveUserSession(User user) async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setBool(_keyIsLoggedIn, true);
    await prefs.setString(_keyUserId, user.id);
    await prefs.setString(_keyUserName, user.fullName);
    await prefs.setString(_keyUserEmail, user.email);
    await prefs.setBool(_keyIsAdmin, user.isAdmin);
    await prefs.setString(_keyUserStatus, user.status);

    // Keep the complete user in memory.
    loggedUser = user;
  }

  // ---------------------------------------------------------------------------
  // LOAD SESSION
  // ---------------------------------------------------------------------------

  /// Load the saved user session from SharedPreferences.
  static Future<void> loadUserSession() async {
    final prefs = await SharedPreferences.getInstance();

    final bool isLoggedIn = prefs.getBool(_keyIsLoggedIn) ?? false;

    if (!isLoggedIn) {
      loggedUser = null;
      return;
    }

    final String userId = prefs.getString(_keyUserId) ?? '';

    final String userName = prefs.getString(_keyUserName) ?? '';

    final String userEmail = prefs.getString(_keyUserEmail) ?? '';

    final bool isAdmin = prefs.getBool(_keyIsAdmin) ?? false;

    final String userStatus = prefs.getString(_keyUserStatus) ?? 'Active';

    // If the important information is missing,
    // consider the session invalid.
    if (userId.isEmpty || userName.isEmpty || userEmail.isEmpty) {
      loggedUser = null;
      return;
    }

    loggedUser = User(
      id: userId,
      fullName: userName,
      email: userEmail,
      isAdmin: isAdmin,
      status: userStatus,
    );
  }

  // ---------------------------------------------------------------------------
  // CHECK LOGIN STATUS
  // ---------------------------------------------------------------------------

  static Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();

    return prefs.getBool(_keyIsLoggedIn) ?? false;
  }

  // ---------------------------------------------------------------------------
  // GET USER ID
  // ---------------------------------------------------------------------------

  static Future<String?> getUserId() async {
    final prefs = await SharedPreferences.getInstance();

    return prefs.getString(_keyUserId);
  }

  // ---------------------------------------------------------------------------
  // LOGOUT
  // ---------------------------------------------------------------------------

  /// Clear only login/session information.
  ///
  /// This intentionally does NOT clear onboarding preferences.
  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.remove(_keyIsLoggedIn);
    await prefs.remove(_keyUserId);
    await prefs.remove(_keyUserName);
    await prefs.remove(_keyUserEmail);
    await prefs.remove(_keyIsAdmin);
    await prefs.remove(_keyUserStatus);

    // Also clear the in-memory user.
    loggedUser = null;
  }
}
