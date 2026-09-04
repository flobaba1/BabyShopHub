class UserSession {
  UserSession._();
 

  static final UserSession instance = UserSession._();

  String? _userId;

  /// The ID of the currently logged-in user.
  String? get userId => _userId;

  /// Returns true if a user is currently logged in.
  bool get isLoggedIn => _userId != null;

  /// Save the user's ID after successful login.
  void login(String userId) {
    _userId = userId;
  }
 

  /// Clear the current user session.
  void logout() {
    _userId = null;
  }
}
}
