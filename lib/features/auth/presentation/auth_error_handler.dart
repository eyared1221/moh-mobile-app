import '../data/auth_models.dart';
import 'auth_messages.dart';

/// Centralized error handler for auth operations.
/// Backend remains source of truth for server-side business errors.
class AuthErrorHandler {
  AuthErrorHandler._();

  /// Gets user-friendly error message from any error type
  static String getMessage(Object error) {
    // Server errors with specific messages (business logic from backend)
    if (error is AuthApiException) {
      return error.message;
    }

    // Connection/network errors
    if (_isConnectionError(error)) {
      return AuthMessages.connectionFailed;
    }

    // Unknown errors (not connection-related)
    return AuthMessages.somethingWentWrong;
  }

  /// Checks if error is a connection/network error
  static bool _isConnectionError(Object error) {
    final errorString = error.toString().toLowerCase();
    return errorString.contains('socket') ||
        errorString.contains('connection') ||
        errorString.contains('network') ||
        errorString.contains('timeout') ||
        errorString.contains('unreachable') ||
        errorString.contains('dns') ||
        errorString.contains('failed host lookup') ||
        errorString.contains('connection refused');
  }

  /// Returns true if this is a connection error that should show connectivity message
  static bool isConnectivityError(Object error) {
    return error is! AuthApiException && _isConnectionError(error);
  }
}
