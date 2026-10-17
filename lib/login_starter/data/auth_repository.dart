import 'package:firebase_auth/firebase_auth.dart';

import '../models/app_user.dart';
import '../utils/auth_messages.dart';

/// A readable error for the screens to show.
class AuthException implements Exception {
  const AuthException(this.message);

  final String message;

  @override
  String toString() => message;
}

/// Everything the app needs from "an account system", as an abstract class
/// (Session 1). The app uses FirebaseAuthRepository; tests use a fake one.
abstract class AuthRepository {
  /// Sends the logged-in user, or null when logged out. Fires at app start,
  /// after login, after logout, and when the name changes.
  Stream<AppUser?> userChanges();

  Future<void> logIn({required String email, required String password});

  Future<void> register({required String name, required String email, required String password});

  Future<void> sendPasswordReset(String email);

  Future<void> logOut();
}

class FirebaseAuthRepository implements AuthRepository {
  FirebaseAuthRepository(this._auth);

  final FirebaseAuth _auth;

  // userChanges() (not authStateChanges()) also fires when the display name
  // is set after registering, so the Home greeting updates by itself.
  @override
  Stream<AppUser?> userChanges() => _auth.userChanges().map(_toAppUser);

  @override
  Future<void> logIn({required String email, required String password}) {
    return _guard(() => _auth.signInWithEmailAndPassword(email: email, password: password));
  }

  @override
  Future<void> register({required String name, required String email, required String password}) {
    return _guard(() async {
      final credential = await _auth.createUserWithEmailAndPassword(email: email, password: password);
      await credential.user?.updateDisplayName(name);
    });
  }

  @override
  Future<void> sendPasswordReset(String email) {
    return _guard(() => _auth.sendPasswordResetEmail(email: email));
  }

  @override
  Future<void> logOut() => _auth.signOut();

  AppUser? _toAppUser(User? user) {
    if (user == null) return null;
    return AppUser(uid: user.uid, email: user.email ?? '', name: user.displayName);
  }

  /// Runs a Firebase call and turns its error code into an AuthException.
  Future<void> _guard(Future<void> Function() action) async {
    try {
      await action();
    } on FirebaseAuthException catch (e) {
      throw AuthException(authMessage(e.code));
    }
  }
}
