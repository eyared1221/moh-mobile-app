// Centralized auth messages for consistency across screens
// Backend errors remain the source of truth for server-side business logic

class AuthMessages {
  AuthMessages._();

  // Connection errors
  static const String connectionFailed = 'Connection failed. Please check your internet and try again.';

  // Unknown errors
  static const String somethingWentWrong = 'Something went wrong. Please try again.';

  // Success messages
  static const String signInSuccess = 'You have signed in successfully.';
  static const String signUpSuccess = 'Your account has been created successfully.';
  static const String passwordResetSuccess = 'Your password has been updated successfully.';
  static const String emailVerifiedSuccess = 'Your email has been verified successfully.';
  static const String phoneVerifiedSuccess = 'Your phone number has been verified successfully.';

  // Form validation
  static const String emailOrPhoneRequired = 'Email or phone is required';
  static const String emailRequired = 'Email is required';
  static const String invalidEmail = 'Enter a valid email address';
  static const String phoneRequired = 'Phone number is required';
  static const String invalidPhone = 'Phone number must be 10 digits and start with 09 or 07';
  static const String usernameRequired = 'Username is required';
  static const String passwordRequired = 'Password is required';
  static const String passwordMinLength = 'Password must be at least 8 characters';
  static const String passwordNeedsNonSpaceCharacter =
      'Password must include at least one non-space character';
  static const String passwordNoLeadingOrTrailingSpaces =
      'Password cannot start or end with spaces';
  static const String confirmPasswordRequired = 'Confirm password is required';
  static const String passwordsDoNotMatch = 'Passwords do not match';
  static const String invalidCredentials = 'Invalid email/phone or password';
  static const String verifyAccountRequired = 'Please verify your account';
  static const String invalidOrExpiredResetCode = 'Invalid or expired reset code';
  static const String resetCodeExpired = 'Reset code has expired';
  static const String ageRequired = 'Age is required';
  static const String invalidAge = 'Enter a valid age';
  static const String ageMin = 'Age must be 10 or above';
  static const String otpRequired = 'Verification code is required';
}
