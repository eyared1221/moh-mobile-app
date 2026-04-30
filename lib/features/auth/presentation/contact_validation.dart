class ContactValidation {
  static final RegExp _emailPattern = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
  static final RegExp _phonePattern = RegExp(r'^(09|07)\d{8}$');
  static final RegExp _letterPattern = RegExp(r'[A-Za-z]');

  static bool isValidEmail(String value) {
    return _emailPattern.hasMatch(value.trim());
  }

  static bool isValidPhone(String value) {
    return _phonePattern.hasMatch(value.trim());
  }

  static bool looksLikeEmail(String value) {
    final trimmed = value.trim();
    return trimmed.contains('@') || _letterPattern.hasMatch(trimmed);
  }

  static String? validate(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Email or phone is required';
    }

    final trimmed = value.trim();
    if (looksLikeEmail(trimmed)) {
      return isValidEmail(trimmed) ? null : 'Enter a valid email address';
    }

    return isValidPhone(trimmed)
        ? null
        : 'Phone number must be 10 digits and start with 09 or 07';
  }
}
