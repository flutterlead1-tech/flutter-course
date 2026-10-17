import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/app_user.dart';
import '../providers/auth_providers.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key, required this.user});

  final AppUser user;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final text = Theme.of(context).textTheme;
    final colors = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Paws & Homes'),
        actions: [
          IconButton(
            tooltip: 'Log out',
            icon: const Icon(Icons.logout),
            // No Navigator: the stream sends null and the AuthGate shows Login.
            onPressed: () => ref.read(authRepositoryProvider).logOut(),
          ),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 28,
                  backgroundColor: colors.secondary,
                  foregroundColor: colors.onSecondary,
                  child: Text(user.displayName.characters.first.toUpperCase(), style: text.titleLarge),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Hello, ${user.displayName}', style: text.titleLarge, overflow: TextOverflow.ellipsis),
                      Text(user.email,
                          style: text.bodyMedium?.copyWith(color: colors.onSurfaceVariant),
                          overflow: TextOverflow.ellipsis),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("You're logged in", style: text.titleMedium),
                    const SizedBox(height: 8),
                    const Text('Close the app and open it again: you will still be logged in.'),
                    const SizedBox(height: 12),
                    Text('User ID: ${user.uid}',
                        style: text.bodySmall?.copyWith(color: colors.onSurfaceVariant, fontFamily: 'monospace')),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            OutlinedButton.icon(
              onPressed: () => ref.read(authRepositoryProvider).logOut(),
              icon: const Icon(Icons.logout),
              label: const Text('Log out'),
            ),
          ],
        ),
      ),
    );
  }
}
