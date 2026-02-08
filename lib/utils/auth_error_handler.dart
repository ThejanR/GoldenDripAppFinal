import '../services/api_service.dart';

class AuthErrorHandler {
  /// Convert API exceptions to user-friendly error messages
  static String getFriendlyErrorMessage(Exception error) {
    if (error is ApiException) {
      // Handle specific HTTP status codes
      switch (error.statusCode) {
        case 401:
          return 'Invalid email or password. Please check your credentials and try again.';
        case 403:
          return 'Access forbidden. Please contact support if this issue persists.';
        case 404:
          return 'Service unavailable. Please try again later.';
        case 422:
          // Handle validation errors
          if (error.errors != null) {
            final errors = error.errors as Map<String, dynamic>?;
            if (errors != null && errors.containsKey('email')) {
              final emailErrors = errors['email'] as List<dynamic>?;
              if (emailErrors != null && emailErrors.isNotEmpty) {
                return emailErrors.first.toString();
              }
            }
            if (errors != null && errors.containsKey('password')) {
              final passwordErrors = errors['password'] as List<dynamic>?;
              if (passwordErrors != null && passwordErrors.isNotEmpty) {
                return passwordErrors.first.toString();
              }
            }
          }
          return 'Please check your email and password.';
        case 429:
          return 'Too many login attempts. Please wait a moment and try again.';
        case 500:
          return 'Server error. Please try again later.';
        case 502:
        case 503:
        case 504:
          return 'Service temporarily unavailable. Please try again later.';
        default:
          // Use the API message if it's descriptive enough
          if (error.message.toLowerCase().contains('invalid') ||
              error.message.toLowerCase().contains('incorrect')) {
            return 'Invalid email or password. Please check your credentials and try again.';
          }
          if (error.message.isNotEmpty &&
              !error.message.contains('ApiException')) {
            return error.message;
          }
          return 'Login failed. Please check your internet connection and try again.';
      }
    }

    // Handle network/connection errors
    final errorString = error.toString().toLowerCase();
    if (errorString.contains('socketexception') ||
        errorString.contains('handshakeexception') ||
        errorString.contains('connection')) {
      return 'Network error. Please check your internet connection and try again.';
    }

    if (errorString.contains('timeout')) {
      return 'Request timed out. Please check your connection and try again.';
    }

    // Generic fallback
    return 'Unable to login at this time. Please try again later.';
  }

  /// Check if error is related to authentication credentials
  static bool isCredentialError(Exception error) {
    if (error is ApiException) {
      return error.statusCode == 401 ||
          error.statusCode == 422 ||
          (error.message.toLowerCase().contains('invalid') &&
              error.message.toLowerCase().contains('credential'));
    }
    return false;
  }

  /// Check if error is related to network connectivity
  static bool isNetworkError(Exception error) {
    final errorString = error.toString().toLowerCase();
    return errorString.contains('socketexception') ||
        errorString.contains('handshakeexception') ||
        errorString.contains('connection') ||
        errorString.contains('timeout');
  }
}
