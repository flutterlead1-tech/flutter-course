import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/auth_repository.dart';
import '../providers/auth_providers.dart';
import '../utils/validators.dart';
import '../widgets/auth_widgets.dart';
import 'register_screen.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _loading = false;
  String? _error;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _logIn() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      await ref.read(authRepositoryProvider).logIn(
            email: _emailController.text.trim(),
            password: _passwordController.text,
          );
      // Success: no Navigator. The AuthGate sees the user and shows Home.
    } on AuthException catch (e) {
      if (mounted) setState(() => _error = e.message);
    }
    if (mounted) setState(() => _loading = false);
  }

  Future<void> _forgotPassword() async {
    final messenger = ScaffoldMessenger.of(context);
    final email = _emailController.text.trim();
    if (validateEmail(email) != null) {
      messenger.showSnackBar(const SnackBar(content: Text('Type your email above first, then tap Forgot password.')));
      return;
    }
    try {
      await ref.read(authRepositoryProvider).sendPasswordReset(email);
      // With email enumeration protection, Firebase doesn't say whether the
      // account exists, so the message doesn't either.
      messenger.showSnackBar(SnackBar(content: Text('If an account exists for $email, a reset link is on its way.')));
    } on AuthException catch (e) {
      messenger.showSnackBar(SnackBar(content: Text(e.message)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final colors = Theme.of(context).colorScheme;

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.fromLTRB(24, 40, 24, 24),
                children: [
                  const Align(alignment: Alignment.centerLeft, child: PawLogo()),
                  const SizedBox(height: 28),
                  Text('Welcome back', style: text.headlineMedium),
                  const SizedBox(height: 6),
                  Text('Log in to meet pets waiting for a home.',
                      style: text.bodyLarge?.copyWith(color: colors.onSurfaceVariant)),
                  const SizedBox(height: 32),
                  LabeledField(
                    label: 'Email',
                    child: TextFormField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.next,
                      validator: validateEmail,
                      decoration: const InputDecoration(
                        hintText: 'name@example.com',
                        prefixIcon: Icon(Icons.mail_outline),
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),
                  LabeledField(
                    label: 'Password',
                    child: PasswordField(
                      controller: _passwordController,
                      validator: validateLoginPassword,
                      onSubmitted: _logIn,
                    ),
                  ),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(onPressed: _forgotPassword, child: const Text('Forgot password?')),
                  ),
                  if (_error != null) ...[
                    ErrorBanner(message: _error!),
                    const SizedBox(height: 16),
                  ],
                  PrimaryButton(label: 'Log in', loading: _loading, onPressed: _logIn),
                  const SizedBox(height: 22),
                  Row(
                    children: [
                      const Expanded(child: Divider()),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: Text('or', style: TextStyle(color: colors.onSurfaceVariant)),
                      ),
                      const Expanded(child: Divider()),
                    ],
                  ),
                  const SizedBox(height: 22),
                  OutlinedButton(
                    onPressed: _loading
                        ? null
                        : () => Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => const RegisterScreen()),
                            ),
                    child: const Text('Create an account'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
