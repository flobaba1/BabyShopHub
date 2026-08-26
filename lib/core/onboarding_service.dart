// lib/services/onboarding_service.dart
import 'package:shared_preferences/shared_preferences.dart';

class OnboardingService {
  static const String _kFirstTimeKey = 'is_first_time';

  /// Returns true if the user is opening the app for the first time
  static Future<bool> isFirstTimeUser() async {
    final prefs = await SharedPreferences.getInstance();
    // Default to true if the key has never been set
    return prefs.getBool(_kFirstTimeKey) ?? true;
  }

  /// Call this when the user completes or skips onboarding
  static Future<void> completeOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_kFirstTimeKey, false);
  }
}