import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/auth_providers.dart';
import 'home_screen.dart';
import 'login_screen.dart';

/// Decides which screen to show: Login when nobody is logged in, Home when
/// someone is. It rebuilds by itself after login, register and logout.
class AuthGate extends ConsumerWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ref.watch(authStateProvider).when(
          loading: () => const Scaffold(body: Center(child: CircularProgressIndicator())),
          error: (error, _) => Scaffold(body: Center(child: Text('Could not check your login: $error'))),
          data: (user) => user == null ? const LoginScreen() : HomeScreen(user: user),
        );
  }
}
