// Day 8 · Demo 2 — Register, log in, log out, and every error message
// Run: flutter run -t lib/day8_demos/demo2_register_login.dart
//
// There is NO form validation here on purpose, so you can send bad input
// to Firebase and see each error code it returns. Try:
//   - Register an email that already exists     → email-already-in-use
//   - Register with password "123"               → weak-password
//   - Email "abc"                                → invalid-email
//   - Log in with a wrong password               → invalid-credential
//   - Turn off the Wi-Fi and log in              → network-request-failed
// After registering, open Firebase console → Authentication → Users.
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import '../firebase_options.dart';
import 'auth_messages.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MaterialApp(home: AuthPlayground()));
}

class AuthPlayground extends StatefulWidget {
  const AuthPlayground({super.key});

  @override
  State<AuthPlayground> createState() => _AuthPlaygroundState();
}

class _AuthPlaygroundState extends State<AuthPlayground> {
  final _auth = FirebaseAuth.instance; // the reception desk
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _loading = false;
  String? _errorCode; // e.g. 'weak-password'
  String? _result; // what happened, in plain words

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // Runs one Firebase call with a loading state and error handling.
  Future<void> _run(String successMessage, Future<void> Function() action) async {
    setState(() {
      _loading = true;
      _errorCode = null;
      _result = null;
    });
    try {
      await action();
      _result = successMessage;
    } on FirebaseAuthException catch (e) {
      _errorCode = e.code; // what Firebase says
      _result = authMessage(e.code); // what the user should read
    }
    if (!mounted) return;
    setState(() => _loading = false);
  }

  Future<void> _register() => _run('Account created and logged in.', () {
        return _auth.createUserWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text,
        );
      });

  Future<void> _logIn() => _run('Logged in.', () {
        return _auth.signInWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text,
        );
      });

  Future<void> _logOut() => _run('Logged out.', _auth.signOut);

  @override
  Widget build(BuildContext context) {
    final user = _auth.currentUser; // null = logged out
    final colors = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Register & log in')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: ListTile(
              leading: Icon(user == null ? Icons.person_off : Icons.verified_user),
              title: Text(user == null ? 'Logged out' : 'Logged in'),
              subtitle: Text(user == null ? 'currentUser is null' : '${user.email}\nuid: ${user.uid}'),
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            decoration: const InputDecoration(labelText: 'Email', border: OutlineInputBorder()),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _passwordController,
            obscureText: true,
            decoration: const InputDecoration(labelText: 'Password', border: OutlineInputBorder()),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              FilledButton(onPressed: _loading ? null : _register, child: const Text('Register')),
              FilledButton.tonal(onPressed: _loading ? null : _logIn, child: const Text('Log in')),
              OutlinedButton(onPressed: _loading ? null : _logOut, child: const Text('Log out')),
            ],
          ),
          const SizedBox(height: 24),
          if (_loading) const Center(child: CircularProgressIndicator()),
          if (_result != null)
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: _errorCode == null ? colors.primaryContainer : colors.errorContainer,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (_errorCode != null) Text('e.code = "$_errorCode"', style: const TextStyle(fontFamily: 'monospace')),
                  Text(_result!),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
