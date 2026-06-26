import 'package:flutter/material.dart';

import '../../../core/theme/eventhub_theme.dart';
import '../application/auth_controller.dart';
import 'reset_password_screen.dart';

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
  bool _passwordVisible = false;

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

  void _switchMode() {
    setState(() {
      _mode = _isSignUp ? AuthMode.signIn : AuthMode.signUp;
    });
    widget.controller.clearError();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: AnimatedBuilder(
          animation: widget.controller,
          builder: (context, _) {
            return Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 30, 24, 30),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 430),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const _EventHubLogo(),
                        const SizedBox(height: 42),
                        Text(
                          _isSignUp ? 'Sign up' : 'Sign in',
                          style: Theme.of(context).textTheme.displaySmall
                              ?.copyWith(
                                fontWeight: FontWeight.w900,
                                color: EventHubTheme.ink,
                              ),
                        ),
                        const SizedBox(height: 28),
                        if (_isSignUp) ...[
                          TextFormField(
                            controller: _fullNameController,
                            textInputAction: TextInputAction.next,
                            decoration: const InputDecoration(
                              hintText: 'Full name',
                              prefixIcon: Icon(Icons.badge_outlined),
                            ),
                            validator: (value) {
                              if (value == null || value.trim().length < 2) {
                                return 'Full name must contain at least 2 characters';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),
                        ],
                        TextFormField(
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          textInputAction: TextInputAction.next,
                          decoration: const InputDecoration(
                            hintText: 'abc@email.com',
                            prefixIcon: Icon(Icons.mail_outline),
                          ),
                          validator: (value) {
                            final email = value?.trim() ?? '';
                            if (!email.contains('@') || !email.contains('.')) {
                              return 'Email is invalid';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _passwordController,
                          obscureText: !_passwordVisible,
                          decoration: InputDecoration(
                            hintText: 'Your password',
                            prefixIcon: const Icon(Icons.lock_outline),
                            suffixIcon: IconButton(
                              tooltip: _passwordVisible
                                  ? 'Hide password'
                                  : 'Show password',
                              onPressed: () {
                                setState(
                                  () => _passwordVisible = !_passwordVisible,
                                );
                              },
                              icon: Icon(
                                _passwordVisible
                                    ? Icons.visibility_outlined
                                    : Icons.visibility_off_outlined,
                              ),
                            ),
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
                        if (!_isSignUp)
                          Align(
                            alignment: Alignment.centerRight,
                            child: TextButton(
                              onPressed: widget.controller.isLoading
                                  ? null
                                  : () {
                                      Navigator.of(context).push(
                                        MaterialPageRoute<void>(
                                          builder: (_) =>
                                              const ResetPasswordScreen(),
                                        ),
                                      );
                                    },
                              child: const Text('Forgot Password?'),
                            ),
                          ),
                        if (_isSignUp) ...[
                          const SizedBox(height: 18),
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
                          const SizedBox(height: 18),
                          Text(
                            widget.controller.errorMessage!,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.error,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                        const SizedBox(height: 30),
                        FilledButton(
                          onPressed: widget.controller.isLoading
                              ? null
                              : _submit,
                          style: FilledButton.styleFrom(
                            minimumSize: const Size.fromHeight(62),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(18),
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(_isSignUp ? 'CREATE ACCOUNT' : 'SIGN IN'),
                              const SizedBox(width: 18),
                              Container(
                                width: 42,
                                height: 42,
                                decoration: BoxDecoration(
                                  color: EventHubTheme.primaryDark,
                                  borderRadius: BorderRadius.circular(21),
                                ),
                                child: const Icon(Icons.arrow_forward),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 18),
                        Row(
                          children: [
                            const Expanded(child: Divider()),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                              ),
                              child: Text(
                                'OR',
                                style: Theme.of(context).textTheme.bodyMedium
                                    ?.copyWith(color: EventHubTheme.muted),
                              ),
                            ),
                            const Expanded(child: Divider()),
                          ],
                        ),
                        const SizedBox(height: 18),
                        OutlinedButton.icon(
                          onPressed: widget.controller.isLoading
                              ? null
                              : () => widget.controller.signInWithGoogle(),
                          icon: const Icon(Icons.g_mobiledata, size: 30),
                          label: const Text('Continue with Google'),
                          style: OutlinedButton.styleFrom(
                            minimumSize: const Size.fromHeight(56),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(18),
                            ),
                          ),
                        ),
                        const SizedBox(height: 30),
                        Wrap(
                          alignment: WrapAlignment.center,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          children: [
                            Text(
                              _isSignUp
                                  ? 'Already have an account?'
                                  : "Don't have an account?",
                              style: Theme.of(context).textTheme.bodyLarge,
                            ),
                            TextButton(
                              onPressed: widget.controller.isLoading
                                  ? null
                                  : _switchMode,
                              child: Text(_isSignUp ? 'Sign in' : 'Sign up'),
                            ),
                          ],
                        ),
                      ],
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

class _EventHubLogo extends StatelessWidget {
  const _EventHubLogo();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          width: 92,
          height: 92,
          child: Stack(
            alignment: Alignment.center,
            children: [
              Container(
                width: 92,
                height: 92,
                decoration: const BoxDecoration(
                  color: EventHubTheme.primary,
                  shape: BoxShape.circle,
                ),
              ),
              Container(
                width: 50,
                height: 50,
                decoration: const BoxDecoration(
                  color: EventHubTheme.background,
                  shape: BoxShape.circle,
                ),
              ),
              Transform.rotate(
                angle: -0.45,
                child: Container(
                  width: 66,
                  height: 20,
                  decoration: BoxDecoration(
                    color: EventHubTheme.accent,
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 18),
        Text(
          'EventHub',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.displaySmall?.copyWith(
            fontWeight: FontWeight.w900,
            color: EventHubTheme.ink,
          ),
        ),
      ],
    );
  }
}
