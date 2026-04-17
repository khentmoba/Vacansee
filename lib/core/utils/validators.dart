/// Form field validation utilities for VacanSee.
///
/// Centralises all input validation logic so widgets stay dumb
/// and validation rules are easily unit-testable.
library;

class Validators {
  Validators._(); // Prevent instantiation

  /// Validates a Philippine mobile number.
  ///
  /// Accepts formats:
  ///   - 09XXXXXXXXX  (11 digits, starts with 09)
  ///   - +639XXXXXXXXX (12 chars with country code)
  ///   - 639XXXXXXXXX  (12 digits with numeric country code)
  static String? phoneNumber(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Phone number is required.';
    }
    final cleaned = value.trim().replaceAll(RegExp(r'\s+'), '');
    // Accept 09XXXXXXXXX, +639XXXXXXXXX, or 639XXXXXXXXX
    final pattern = RegExp(r'^(09\d{9}|\+639\d{9}|639\d{9})$');
    if (!pattern.hasMatch(cleaned)) {
      return 'Enter a valid PH mobile number (e.g. 09XXXXXXXXX).';
    }
    return null;
  }

  /// Validates a required display name (non-empty, 2–60 chars).
  static String? displayName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Display name is required.';
    }
    if (value.trim().length < 2) {
      return 'Name must be at least 2 characters.';
    }
    if (value.trim().length > 60) {
      return 'Name must not exceed 60 characters.';
    }
    return null;
  }

  /// Generic required-field validator.
  static String? required(String? value, {String fieldName = 'This field'}) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName is required.';
    }
    return null;
  }
}
