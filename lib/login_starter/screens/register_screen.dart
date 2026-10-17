import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/auth_repository.dart';
import '../providers/auth_providers.dart';
import '../utils/validators.dart';
import '../widgets/auth_widgets.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();
  bool _loading = false;
  String? _error;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      await ref.read(authRepositoryProvider).register(
            name: _nameController.text.trim(),
            email: _emailController.text.trim(),
            password: _passwordController.text,
          );
      // Registering also logs the user in, so the AuthGate underneath now
      // shows Home. Close this screen to reveal it.
      if (mounted) Navigator.pop(context);
      return;
    } on AuthException catch (e) {
      if (mounted) setState(() => _error = e.message);
    }
    if (mounted) setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final colors = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(backgroundColor: Colors.transparent),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                children: [
                  const Align(alignment: Alignment.centerLeft, child: PawLogo()),
                  const SizedBox(height: 28),
                  Text('Create your account', style: text.headlineMedium),
                  const SizedBox(height: 6),
                  Text('It takes less than a minute.',
                      style: text.bodyLarge?.copyWith(color: colors.onSurfaceVariant)),
                  const SizedBox(height: 32),
                  LabeledField(
                    label: 'Name',
                    child: TextFormField(
                      controller: _nameController,
                      textCapitalization: TextCapitalization.words,
                      textInputAction: TextInputAction.next,
                      validator: validateName,
                      decoration: const InputDecoration(hintText: 'Ananya Rao', prefixIcon: Icon(Icons.person_outline)),
                    ),
                  ),
                  const SizedBox(height: 18),
                  LabeledField(
                    label: 'Email',
                    child: TextFormField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.next,
                      validator: validateEmail,
                      decoration: const InputDecoration(hintText: 'name@example.com', prefixIcon: Icon(Icons.mail_outline)),
                    ),
                  ),
                  const SizedBox(height: 18),
                  LabeledField(
                    label: 'Password',
                    child: PasswordField(
                      controller: _passwordController,
                      validator: validateNewPassword,
                      hint: 'At least 6 characters',
                      textInputAction: TextInputAction.next,
                    ),
                  ),
                  const SizedBox(height: 18),
                  LabeledField(
                    label: 'Confirm password',
                    child: PasswordField(
                      controller: _confirmController,
                      validator: (value) => value != _passwordController.text ? 'Passwords do not match' : null,
                      onSubmitted: _register,
                    ),
                  ),
                  const SizedBox(height: 24),
                  if (_error != null) ...[
                    ErrorBanner(message: _error!),
                    const SizedBox(height: 16),
                  ],
                  PrimaryButton(label: 'Create account', loading: _loading, onPressed: _register),
                  const SizedBox(height: 12),
                  TextButton(
                    onPressed: _loading ? null : () => Navigator.pop(context),
                    child: const Text('Already have an account? Log in'),
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
