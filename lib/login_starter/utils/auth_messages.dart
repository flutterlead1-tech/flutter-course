/// Turns a FirebaseAuthException code into a sentence the user understands.
String authMessage(String code) {
  switch (code) {
    case 'email-already-in-use':
      return 'An account already exists for this email. Try logging in.';
    case 'weak-password':
      return 'Password must be at least 6 characters.';
    case 'invalid-email':
      return 'Enter a valid email address.';
    // New Firebase projects send invalid-credential for both a wrong password
    // and an unknown email (email enumeration protection).
    case 'invalid-credential':
    case 'wrong-password':
    case 'user-not-found':
      return 'Email or password is incorrect.';
    case 'network-request-failed':
      return 'No internet connection. Check your Wi-Fi or mobile data.';
    case 'too-many-requests':
      return 'Too many attempts. Please wait a few minutes and try again.';
    case 'user-disabled':
      return 'This account has been disabled.';
    default:
      return 'Something went wrong. Please try again.';
  }
}
