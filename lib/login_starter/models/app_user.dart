// Our own user class. Screens use this instead of Firebase's User,
// so they don't depend on Firebase directly (and tests can fake it).
class AppUser {
  const AppUser({required this.uid, required this.email, this.name});

  final String uid;
  final String email;
  final String? name; // set when registering; may be null for older accounts

  /// "Ananya" from the name, or "ananya.rao" from the email if there's no name.
  String get displayName {
    final n = name?.trim() ?? '';
    return n.isNotEmpty ? n : email.split('@').first;
  }
}
