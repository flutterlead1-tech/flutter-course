// Checked in the app BEFORE asking Firebase, so obvious mistakes
// get an instant message without a network call.

String? validateName(String? value) {
  final name = value?.trim() ?? '';
  if (name.isEmpty) return 'Enter your name';
  if (name.length < 2) return 'Name must be at least 2 characters';
  return null;
}

String? validateEmail(String? value) {
  final email = value?.trim() ?? '';
  if (email.isEmpty) return 'Enter your email';
  if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(email)) {
    return 'Enter a valid email, like name@example.com';
  }
  return null;
}

// Login: only check it isn't empty. Whether it's right is Firebase's job.
String? validateLoginPassword(String? value) {
  if (value == null || value.isEmpty) return 'Enter your password';
  return null;
}

// Register: Firebase's minimum is 6 characters.
String? validateNewPassword(String? value) {
  if (value == null || value.isEmpty) return 'Choose a password';
  if (value.length < 6) return 'Password must be at least 6 characters';
  return null;
}
