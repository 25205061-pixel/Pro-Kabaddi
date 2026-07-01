class AuthFailure implements Exception {
  final String message;
  final String code;

  AuthFailure(this.code, this.message);

  /// Maps Firebase Auth's error codes to friendly, user-facing copy.
  factory AuthFailure.fromCode(String code) {
    switch (code) {
      case 'user-not-found':
        return AuthFailure(code, 'No account found with that email.');
      case 'wrong-password':
      case 'invalid-credential':
        return AuthFailure(code, 'Incorrect email or password.');
      case 'email-already-in-use':
        return AuthFailure(code, 'That email is already registered.');
      case 'weak-password':
        return AuthFailure(code, 'Choose a stronger password (6+ characters).');
      case 'invalid-email':
        return AuthFailure(code, 'That email address looks invalid.');
      case 'invalid-verification-code':
        return AuthFailure(code, 'That OTP code is incorrect.');
      case 'too-many-requests':
        return AuthFailure(code, 'Too many attempts. Please try again shortly.');
      case 'network-request-failed':
        return AuthFailure(code, 'Network error. Check your connection.');
      case 'google-sign-in-cancelled':
        return AuthFailure(code, 'Google sign-in was cancelled.');
      default:
        return AuthFailure(code, 'Something went wrong. Please try again.');
    }
  }

  @override
  String toString() => message;
}
