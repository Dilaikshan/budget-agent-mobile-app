import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/providers.dart';
import '../../../core/domain/result.dart';
import '../../../core/widgets/common.dart';
import '../data/auth_repository.dart';

/// Email/password users verify their address before server data and AI
/// routes are available (docs/07). The router re-evaluates on userChanges.
class VerifyEmailScreen extends ConsumerStatefulWidget {
  const VerifyEmailScreen({super.key});

  @override
  ConsumerState<VerifyEmailScreen> createState() => _VerifyEmailScreenState();
}

class _VerifyEmailScreenState extends ConsumerState<VerifyEmailScreen> {
  bool _busy = false;
  String? _error;
  String? _info;

  Future<void> _run(
    Future<Result<void>> Function() action,
    String? success,
  ) async {
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

  @override
  Widget build(BuildContext context) {
    final auth = ref.read(authRepositoryProvider);
    final session = ref.watch(sessionProvider);
    final email = session is Unverified ? session.email : null;
    return Scaffold(
      appBar: AppBar(title: const Text('Verify your email')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            const Icon(Icons.mark_email_unread_outlined, size: 48),
            const SizedBox(height: 12),
            Text(
              email == null
                  ? 'We sent you a verification link.'
                  : 'We sent a verification link to $email.',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            const Text(
              'Verification is required before your ledger can sync or use AI suggestions. Open the link, then come back and tap "I\'ve verified".',
            ),
            if (_error != null) ErrorBanner(_error!),
            if (_info != null) ErrorBanner(_info!, info: true),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: _busy
                  ? null
                  : () => _run(
                      auth.refreshVerification,
                      'Still not verified? Check your inbox and spam folder.',
                    ),
              style: FilledButton.styleFrom(
                minimumSize: const Size.fromHeight(48),
              ),
              child: const Text("I've verified"),
            ),
            const SizedBox(height: 8),
            OutlinedButton(
              onPressed: _busy
                  ? null
                  : () => _run(
                      auth.resendVerification,
                      'Verification email sent again.',
                    ),
              style: OutlinedButton.styleFrom(
                minimumSize: const Size.fromHeight(48),
              ),
              child: const Text('Resend email'),
            ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: _busy ? null : auth.signOut,
              child: const Text('Sign out'),
            ),
          ],
        ),
      ),
    );
  }
}
