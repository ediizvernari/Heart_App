//TODO: See where this should be moved
class AuthException implements Exception {
  final String message;
  const AuthException(this.message);

  factory AuthException.invalidCredentials() {
    return const AuthException(
      'Invalid email or password. Please check your credentials and try again.',
    );
  }

  factory AuthException.emailAlreadyInUse() {
    return const AuthException(
      'This email is already registered. Please use a different email.',
    );
  }

  factory AuthException.networkError([String details = '']) {
    final detailMsg = details.isNotEmpty ? ' ($details)' : '';
    return AuthException(
      'Network error occurred$detailMsg. Please try again later.',
    );
  }

  factory AuthException.serverError([String details = '']) {
    final detailMsg = details.isNotEmpty ? ' ($details)' : '';
    return AuthException(
      'Server error occurred$detailMsg. Please try again later.',
    );
  }

  factory AuthException.unknown([String details = '']) {
    final detailMsg = details.isNotEmpty ? ': $details' : '.';
    return AuthException(
      'An unexpected error occurred$detailMsg',
    );
  }

  @override
  String toString() => 'AuthException: $message';
}
