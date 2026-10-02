import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/brand.dart';

import '../../../app/providers.dart';
import '../../../core/domain/result.dart';
import '../../../core/widgets/common.dart';

/// Google or email/password sign-in (docs/07, docs/09 onboarding step 1).
/// Passwords are handed to Firebase only and never stored by the app.
class SignInScreen extends ConsumerStatefulWidget {
  const SignInScreen({super.key});

  @override
  ConsumerState<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends ConsumerState<SignInScreen> {
  final _email = TextEditingController();
  final _password = TextEditingController();
  bool _register = false;
  bool _busy = false;
  String? _error;
  String? _info;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _run(
    Future<Result<void>> Function() action, {
    String? success,
  }) async {
    if (_busy) return;
    setState(() {
      _busy = true;
      _error = null;
      _info = null;
    });
    final r = await action();
    if (!mounted) return;
    setState(() {
      _busy = false;
      switch (r) {
        case Ok():
          _info = success;
        case Err(:final error):
          _error = error.message;
      }
    });
  }

  bool _validEmail() =>
      RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(_email.text.trim());

  void _submit() {
    if (!_validEmail()) {
      setState(() => _error = 'Enter a valid email address.');
      return;
    }
    if (_password.text.length < (_register ? 8 : 1)) {
      setState(
        () => _error = _register
            ? 'Use at least 8 characters.'
            : 'Enter your password.',
      );
      return;
    }
    final auth = ref.read(authRepositoryProvider);
    if (_register) {
      _run(
        () => auth.register(_email.text, _password.text),
        success: 'Account created. Check your email to verify it.',
      );
    } else {
      _run(() => auth.signInWithEmail(_email.text, _password.text));
    }
  }

  void _forgot() {
    if (!_validEmail()) {
      setState(
        () => _error = 'Enter your email first, then tap "Forgot password".',
      );
      return;
    }
    _run(
      () => ref.read(authRepositoryProvider).sendPasswordReset(_email.text),
      success: 'Password reset email sent.',
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth = ref.read(authRepositoryProvider);
    return Scaffold(
      appBar: AppBar(title: const Text(Brand.name)),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Semantics(
              header: true,
              child: Text(
                _register ? 'Create your account' : 'Sign in',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'First sign-in needs an internet connection. After that, your ledger works offline.',
            ),
            const SizedBox(height: 16),
            FilledButton.tonalIcon(
              onPressed: _busy ? null : () => _run(auth.signInWithGoogle),
              icon: const Icon(Icons.account_circle_outlined),
              label: const Text('Continue with Google'),
              style: FilledButton.styleFrom(
                minimumSize: const Size.fromHeight(48),
              ),
            ),
            const SizedBox(height: 16),
            const Row(
              children: [
                Expanded(child: Divider()),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8),
                  child: Text('or use email'),
                ),
                Expanded(child: Divider()),
              ],
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _email,
              keyboardType: TextInputType.emailAddress,
              autofillHints: const [AutofillHints.email],
              decoration: const InputDecoration(labelText: 'Email'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _password,
              obscureText: true,
              autofillHints: [
                _register ? AutofillHints.newPassword : AutofillHints.password,
              ],
              decoration: InputDecoration(
                labelText: 'Password',
                helperText: _register ? 'At least 8 characters' : null,
              ),
              onSubmitted: (_) => _submit(),
            ),
            if (_error != null) ErrorBanner(_error!),
            if (_info != null) ErrorBanner(_info!, info: true),
            const SizedBox(height: 12),
            FilledButton(
              onPressed: _busy ? null : _submit,
              style: FilledButton.styleFrom(
                minimumSize: const Size.fromHeight(48),
              ),
              child: _busy
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Text(_register ? 'Create account' : 'Sign in'),
            ),
            const SizedBox(height: 8),
            Wrap(
              alignment: WrapAlignment.spaceBetween,
              children: [
                TextButton(
                  onPressed: _busy
                      ? null
                      : () => setState(() {
                          _register = !_register;
                          _error = null;
                          _info = null;
                        }),
                  child: Text(
                    _register ? 'I already have an account' : 'Create account',
                  ),
                ),
                if (!_register)
                  TextButton(
                    onPressed: _busy ? null : _forgot,
                    child: const Text('Forgot password'),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
