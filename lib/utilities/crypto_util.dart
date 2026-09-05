import 'dart:math';

class CryptoUtils {
  /// Generates a cryptographically secure numeric OTP of specified [length] (default 6 digits)
  static String generateOtp({int length = 6}) {
    final Random random = Random.secure();
    final String digits = '0123456789';
    
    return List.generate(
      length, 
      (_) => digits[random.nextInt(digits.length)],
    ).join();
  }

  /// Generates a random secure password with configurable complexity
  static String generateRandomPassword({
    int length = 12,
    bool includeUppercase = true,
    bool includeLowercase = true,
    bool includeNumbers = true,
    bool includeSpecial = true,
  }) {
    const String upper = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';
    const String lower = 'abcdefghijklmnopqrstuvwxyz';
    const String numbers = '0123456789';
    const String special = '!@#\$%^&*()_+-=[]{}|;:,.<>?';

    final Random random = Random.secure();
    final List<String> requiredChars = [];
    String characterPool = '';

    // Ensure at least one character from each enabled set is included
    if (includeUppercase) {
      characterPool += upper;
      requiredChars.add(upper[random.nextInt(upper.length)]);
    }
    if (includeLowercase) {
      characterPool += lower;
      requiredChars.add(lower[random.nextInt(lower.length)]);
    }
    if (includeNumbers) {
      characterPool += numbers;
      requiredChars.add(numbers[random.nextInt(numbers.length)]);
    }
    if (includeSpecial) {
      characterPool += special;
      requiredChars.add(special[random.nextInt(special.length)]);
    }

    if (characterPool.isEmpty) {
      throw ArgumentError('At least one character set must be enabled.');
    }

    // Fill remaining password length from character pool
    final int remainingLength = length - requiredChars.length;
    final List<String> passwordChars = List.from(requiredChars);

    for (int i = 0; i < remainingLength; i++) {
      passwordChars.add(characterPool[random.nextInt(characterPool.length)]);
    }

    // Shuffle characters so predictable types aren't always at the start
    passwordChars.shuffle(random);

    return passwordChars.join();
  }
}