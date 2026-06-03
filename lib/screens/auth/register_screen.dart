import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/auth_provider.dart';
import '../../widgets/auth_feedback.dart';
import '../../widgets/google_sign_in_button.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirm = true;

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

    final auth = context.read<AuthProvider>();
    final success = await auth.register(
      name: _nameController.text,
      email: _emailController.text,
      password: _passwordController.text,
    );

    if (!mounted) return;
    if (success) {
      auth.clearError();
    } else {
      showAuthFeedback(context, auth);
    }
  }

  Future<void> _signInWithGoogle() async {
    final auth = context.read<AuthProvider>();
    final success = await auth.signInWithGoogle();
    if (!mounted) return;
    if (success) {
      auth.clearError();
    } else {
      showAuthFeedback(context, auth);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final auth = context.watch<AuthProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Create account'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight - 48),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 420),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(
                            'Join TravelEase',
                            textAlign: TextAlign.center,
                            style: theme.textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Save favorites and plan your next trip.',
                            textAlign: TextAlign.center,
                            style: theme.textTheme.bodyLarge?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                          const SizedBox(height: 32),

                          // ── Full name ──────────────────────────────────────
                          TextFormField(
                            controller: _nameController,
                            textCapitalization: TextCapitalization.words,
                            textInputAction: TextInputAction.next,
                            enabled: !auth.isAuthActionLoading,
                            decoration: const InputDecoration(
                              labelText: 'Full name',
                              prefixIcon: Icon(Icons.person_outline_rounded),
                            ),
                            validator: (v) {
                              if (v == null || v.trim().isEmpty) {
                                return 'Please enter your name';
                              }
                              if (v.trim().length < 2) {
                                return 'Name is too short';
                              }
                              return null;
                            },
                          ),

                          const SizedBox(height: 16),

                          // ── Email ──────────────────────────────────────────
                          TextFormField(
                            controller: _emailController,
                            keyboardType: TextInputType.emailAddress,
                            textInputAction: TextInputAction.next,
                            enabled: !auth.isAuthActionLoading,
                            decoration: const InputDecoration(
                              labelText: 'Email',
                              prefixIcon: Icon(Icons.email_outlined),
                            ),
                            validator: (v) {
                              if (v == null || v.trim().isEmpty) {
                                return 'Please enter your email';
                              }
                              if (!v.contains('@')) {
                                return 'Please enter a valid email';
                              }
                              return null;
                            },
                          ),

                          const SizedBox(height: 16),

                          // ── Password ───────────────────────────────────────
                          TextFormField(
                            controller: _passwordController,
                            obscureText: _obscurePassword,
                            textInputAction: TextInputAction.next,
                            enabled: !auth.isAuthActionLoading,
                            decoration: InputDecoration(
                              labelText: 'Password',
                              prefixIcon: const Icon(Icons.lock_outline_rounded),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _obscurePassword
                                      ? Icons.visibility_outlined
                                      : Icons.visibility_off_outlined,
                                ),
                                onPressed: () =>
                                    setState(() => _obscurePassword = !_obscurePassword),
                              ),
                            ),
                            validator: (v) {
                              if (v == null || v.isEmpty) {
                                return 'Please enter a password';
                              }
                              if (v.length < 6) {
                                return 'Password must be at least 6 characters';
                              }
                              return null;
                            },
                          ),

                          const SizedBox(height: 16),

                          // ── Confirm password ───────────────────────────────
                          TextFormField(
                            controller: _confirmController,
                            obscureText: _obscureConfirm,
                            textInputAction: TextInputAction.done,
                            enabled: !auth.isAuthActionLoading,
                            onFieldSubmitted: (_) => _register(),
                            decoration: InputDecoration(
                              labelText: 'Confirm password',
                              prefixIcon: const Icon(Icons.lock_outline_rounded),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _obscureConfirm
                                      ? Icons.visibility_outlined
                                      : Icons.visibility_off_outlined,
                                ),
                                onPressed: () =>
                                    setState(() => _obscureConfirm = !_obscureConfirm),
                              ),
                            ),
                            validator: (v) {
                              if (v != _passwordController.text) {
                                return 'Passwords do not match';
                              }
                              return null;
                            },
                          ),

                          const SizedBox(height: 32),

                          // ── Create Account button ──────────────────────────
                          FilledButton(
                            onPressed: auth.isAuthActionLoading ? null : _register,
                            child: auth.isAuthActionLoading
                                ? const SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2.5,
                                      color: Colors.white,
                                    ),
                                  )
                                : const Text('Create Account'),
                          ),

                          const SizedBox(height: 24),
                          Row(
                            children: [
                              Expanded(child: Divider(color: colorScheme.outlineVariant)),
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 12),
                                child: Text(
                                  'or',
                                  style: theme.textTheme.labelMedium?.copyWith(
                                    color: colorScheme.onSurfaceVariant,
                                  ),
                                ),
                              ),
                              Expanded(child: Divider(color: colorScheme.outlineVariant)),
                            ],
                          ),
                          const SizedBox(height: 16),
                          GoogleSignInButton(
                            onPressed: auth.isAuthActionLoading ? null : _signInWithGoogle,
                            label: 'Sign up with Google',
                            isLoading: auth.isAuthActionLoading,
                          ),
                          const SizedBox(height: 12),
                          TextButton(
                            onPressed: auth.isAuthActionLoading
                                ? null
                                : () => Navigator.of(context).pop(),
                            child: const Text('Already have an account? Sign in'),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
