import 'package:bcrypt/bcrypt.dart';

class SecurityHelper {
  /// Hashes a plain text password using BCrypt with a secure salt
  static String hashPassword(String plainPassword) {
    return BCrypt.hashpw(plainPassword, BCrypt.gensalt());
  }

  /// Verifies if a plain text password matches the stored BCrypt hash
  static bool verifyPassword(String plainPassword, String hashedPassword) {
    return BCrypt.checkpw(plainPassword, hashedPassword);
  }
}