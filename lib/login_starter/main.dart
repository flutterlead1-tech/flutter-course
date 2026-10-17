// Day 8 project — Login Starter App (Paws & Homes login, with Firebase)
// Run: flutter run -t lib/login_starter/main.dart
// In Chrome use a fixed port so the login survives a restart:
//   flutter run -d chrome --web-port 5050 -t lib/login_starter/main.dart
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../firebase_options.dart';
import 'screens/auth_gate.dart';
import 'theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(
    ProviderScope(
      retry: (retryCount, error) => null,
      child: const LoginStarterApp(),
    ),
  );
}

class LoginStarterApp extends StatelessWidget {
  const LoginStarterApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Paws & Homes',
      debugShowCheckedModeBanner: false,
      theme: buildPawsTheme(),
      home: const AuthGate(),
    );
  }
}
