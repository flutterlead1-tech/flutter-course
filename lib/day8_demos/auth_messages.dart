// Shared by demos 2 and 3: turn a FirebaseAuthException code into a sentence.
String authMessage(String code) {
  switch (code) {
    case 'email-already-in-use':
      return 'An account already exists for this email. Try logging in.';
    case 'weak-password':
      return 'Password must be at least 6 characters.';
    case 'invalid-email':
      return 'Enter a valid email address.';
    // New projects return invalid-credential for BOTH a wrong password and an
    // unknown email (email enumeration protection). Older projects may still
    // send wrong-password or user-not-found, so all three share one message.
    case 'invalid-credential':
    case 'wrong-password':
    case 'user-not-found':
      return 'Email or password is incorrect.';
    case 'missing-password':
      return 'Enter your password.';
    case 'network-request-failed':
      return 'No internet connection. Check your Wi-Fi or mobile data.';
    case 'too-many-requests':
      return 'Too many attempts. Please wait a few minutes and try again.';
    case 'user-disabled':
      return 'This account has been disabled.';
    case 'operation-not-allowed':
      return 'Email/Password sign-in is turned off in the Firebase console.';
    default:
      return 'Something went wrong ($code). Please try again.';
  }
}
