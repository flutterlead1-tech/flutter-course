// Day 8 · Demo 1 — Connecting the app to Firebase
// Run: flutter run -t lib/day8_demos/demo1_firebase_connected.dart
//
// Firebase must be started BEFORE the app runs, in an async main()
// (the same pattern as Session 7's shared_preferences).
// lib/firebase_options.dart was created by `flutterfire configure`.
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import '../firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MaterialApp(home: ConnectedScreen()));
}

class ConnectedScreen extends StatelessWidget {
  const ConnectedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Firebase.app() is the connection we just started.
    final options = Firebase.app().options;
    final user = FirebaseAuth.instance.currentUser; // null = nobody logged in
    final text = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Firebase connected')),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          const Icon(Icons.cloud_done, size: 64, color: Colors.green),
          const SizedBox(height: 16),
          Text('Connected to Firebase', style: text.headlineSmall, textAlign: TextAlign.center),
          const SizedBox(height: 24),
          ListTile(
            leading: const Icon(Icons.folder_special),
            title: const Text('Project ID'),
            subtitle: Text(options.projectId),
          ),
          ListTile(
            leading: const Icon(Icons.person),
            title: const Text('Logged in user'),
            subtitle: Text(user == null ? 'Nobody (null)' : user.email ?? user.uid),
          ),
        ],
      ),
    );
  }
}
