import 'package:flutter/material.dart';

import '../application/auth_controller.dart';

enum AuthMode { signIn, signUp }

class AuthScreen extends StatefulWidget {
  const AuthScreen({required this.controller, super.key});

  final AuthController controller;

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _formKey = GlobalKey<FormState>();
  final _fullNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  AuthMode _mode = AuthMode.signIn;
  String _role = 'user';

  bool get _isSignUp => _mode == AuthMode.signUp;

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_isSignUp) {
      await widget.controller.register(
        fullName: _fullNameController.text.trim(),
        email: _emailController.text.trim(),
        password: _passwordController.text,
        role: _role,
      );
      return;
    }

    await widget.controller.login(
      email: _emailController.text.trim(),
      password: _passwordController.text,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: AnimatedBuilder(
                animation: widget.controller,
                builder: (context, _) {
                  return Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Icon(
                          Icons.event_available,
                          size: 48,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'EventHub',
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.headlineMedium
                              ?.copyWith(fontWeight: FontWeight.w700),
                        ),
                        const SizedBox(height: 28),
                        SegmentedButton<AuthMode>(
                          segments: const [
                            ButtonSegment(
                              value: AuthMode.signIn,
                              label: Text('Sign in'),
                              icon: Icon(Icons.login),
                            ),
                            ButtonSegment(
                              value: AuthMode.signUp,
                              label: Text('Sign up'),
                              icon: Icon(Icons.person_add),
                            ),
                          ],
                          selected: {_mode},
                          onSelectionChanged: (selection) {
                            setState(() => _mode = selection.first);
                            widget.controller.clearError();
                          },
                        ),
                        const SizedBox(height: 20),
                        if (_isSignUp) ...[
                          TextFormField(
                            controller: _fullNameController,
                            textInputAction: TextInputAction.next,
                            decoration: const InputDecoration(
                              labelText: 'Full name',
                              prefixIcon: Icon(Icons.badge_outlined),
                              border: OutlineInputBorder(),
                            ),
                            validator: (value) {
                              if (value == null || value.trim().length < 2) {
                                return 'Full name must contain at least 2 characters';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 14),
                        ],
                        TextFormField(
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          textInputAction: TextInputAction.next,
                          decoration: const InputDecoration(
                            labelText: 'Email',
                            prefixIcon: Icon(Icons.mail_outline),
                            border: OutlineInputBorder(),
                          ),
                          validator: (value) {
                            final email = value?.trim() ?? '';
                            if (!email.contains('@') || !email.contains('.')) {
                              return 'Email is invalid';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 14),
                        TextFormField(
                          controller: _passwordController,
                          obscureText: true,
                          decoration: const InputDecoration(
                            labelText: 'Password',
                            prefixIcon: Icon(Icons.lock_outline),
                            border: OutlineInputBorder(),
                          ),
                          validator: (value) {
                            if (_isSignUp &&
                                (value == null || value.length < 8)) {
                              return 'Password must contain at least 8 characters';
                            }
                            if (!_isSignUp &&
                                (value == null || value.isEmpty)) {
                              return 'Password is required';
                            }
                            return null;
                          },
                        ),
                        if (_isSignUp) ...[
                          const SizedBox(height: 14),
                          SegmentedButton<String>(
                            segments: const [
                              ButtonSegment(
                                value: 'user',
                                label: Text('User'),
                                icon: Icon(Icons.person_outline),
                              ),
                              ButtonSegment(
                                value: 'organizer',
                                label: Text('Organizer'),
                                icon: Icon(Icons.storefront_outlined),
                              ),
                            ],
                            selected: {_role},
                            onSelectionChanged: (selection) {
                              setState(() => _role = selection.first);
                            },
                          ),
                        ],
                        if (widget.controller.errorMessage != null) ...[
                          const SizedBox(height: 14),
                          Text(
                            widget.controller.errorMessage!,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.error,
                            ),
                          ),
                        ],
                        const SizedBox(height: 22),
                        FilledButton.icon(
                          onPressed: widget.controller.isLoading
                              ? null
                              : _submit,
                          icon: Icon(
                            _isSignUp ? Icons.person_add : Icons.login,
                          ),
                          label: Text(_isSignUp ? 'Create account' : 'Sign in'),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}
