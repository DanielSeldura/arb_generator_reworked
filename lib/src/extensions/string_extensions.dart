/// Extensions on [String]
extension StringExtensions on String {
  /// Whether the string is a valid locale code
  bool get isValidLocale {
    final parts = split('_');
    if (parts.length > 2) return false;

    // Language code should be 2-3 lowercase letters
    final languageCode = parts[0];
    if (!RegExp(r'^[a-z]{2,3}$').hasMatch(languageCode)) return false;

    // Country code (if present) should be 2-3 uppercase letters
    if (parts.length == 2) {
      final countryCode = parts[1];
      if (!RegExp(r'^[A-Z]{2,3}$').hasMatch(countryCode)) return false;
    }

    return true;
  }

  /// Whether the string is a valid variable name in lowerCamelCase
  bool get isValidVariableName {
    if (isEmpty) return false;

    // Must start with lowercase letter
    if (!RegExp(r'^[a-z]').hasMatch(this)) return false;

    // Can only contain letters, numbers, and underscores
    if (!RegExp(r'^[a-zA-Z0-9_]+$').hasMatch(this)) return false;

    // Should be in lowerCamelCase
    if (contains('_')) return false;

    return true;
  }
}
