import 'auth_messages.dart';

String? validatePassword(String? value) {
  if (value == null || value.isEmpty) {
    return AuthMessages.passwordRequired;
  }

  if (value.trim().isEmpty) {
    return AuthMessages.passwordNeedsNonSpaceCharacter;
  }

  if (value.length < 8) {
    return AuthMessages.passwordMinLength;
  }

  if (value != value.trim()) {
    return AuthMessages.passwordNoLeadingOrTrailingSpaces;
  }

  return null;
}
