import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../../../core/domain/result.dart';

/// Session boundary (docs/07 "Authentication and session handling"). The
/// Firebase SDK owns refresh tokens; passwords are never persisted by the app.
sealed class Session {
  const Session();
}

class SignedOut extends Session {
  const SignedOut();
}

class Unverified extends Session {
  const Unverified(this.email);
  final String? email;
}

class SignedIn extends Session {
  const SignedIn(this.uid, this.email);
  final String uid;
  final String? email;
}

Session sessionOf(User? user) {
  if (user == null) return const SignedOut();
  if (!user.emailVerified) return Unverified(user.email);
  return SignedIn(user.uid, user.email);
}

class AuthRepository {
  AuthRepository(this._auth, {required this.googleServerClientId});

  final FirebaseAuth _auth;
  final String googleServerClientId;
  bool _googleInitialized = false;

  Stream<User?> userChanges() => _auth.userChanges();
  User? get currentUser => _auth.currentUser;

  Future<Result<void>> signInWithEmail(String email, String password) => _guard(
    () => _auth.signInWithEmailAndPassword(
      email: email.trim(),
      password: password,
    ),
  );

  Future<Result<void>> register(String email, String password) =>
      _guard(() async {
        final cred = await _auth.createUserWithEmailAndPassword(
          email: email.trim(),
          password: password,
        );
        await cred.user?.sendEmailVerification();
      });

  Future<Result<void>> resendVerification() =>
      _guard(() async => _auth.currentUser?.sendEmailVerification());

  /// Reload the user and refresh the ID token so the backend sees email_verified.
  Future<Result<void>> refreshVerification() => _guard(() async {
    await _auth.currentUser?.reload();
    await _auth.currentUser?.getIdToken(true);
  });

  Future<Result<void>> sendPasswordReset(String email) =>
      _guard(() => _auth.sendPasswordResetEmail(email: email.trim()));

  Future<Result<void>> signInWithGoogle() => _guard(() async {
    final google = GoogleSignIn.instance;
    if (!_googleInitialized) {
      await google.initialize(serverClientId: googleServerClientId);
      _googleInitialized = true;
    }
    final account = await google.authenticate();
    final idToken = account.authentication.idToken;
    if (idToken == null) throw FirebaseAuthException(code: 'missing-id-token');
    await _auth.signInWithCredential(
      GoogleAuthProvider.credential(idToken: idToken),
    );
  });

  Future<void> signOut() async {
    if (_googleInitialized) await GoogleSignIn.instance.signOut();
    await _auth.signOut();
  }

  Future<Result<void>> _guard(Future<void> Function() f) async {
    try {
      await f();
      return const Ok(null);
    } on GoogleSignInException catch (e) {
      if (e.code == GoogleSignInExceptionCode.canceled) {
        return const Err(
          AppError(ErrorKind.unauthenticated, 'Sign-in was cancelled.'),
        );
      }
      return const Err(
        AppError(
          ErrorKind.unavailable,
          'Google sign-in failed. Check your connection and try again.',
        ),
      );
    } on FirebaseAuthException catch (e) {
      return Err(
        AppError(ErrorKind.unauthenticated, _message(e.code), code: e.code),
      );
    }
  }

  static String _message(String code) => switch (code) {
    'invalid-email' => 'That email address is not valid.',
    'user-disabled' => 'This account is disabled.',
    'user-not-found' ||
    'wrong-password' ||
    'invalid-credential' => 'Email or password is incorrect.',
    'email-already-in-use' => 'An account already exists for this email.',
    'weak-password' => 'Use a stronger password (at least 8 characters).',
    'network-request-failed' =>
      'No connection. First sign-in needs the internet.',
    'too-many-requests' => 'Too many attempts. Try again later.',
    _ => 'Sign-in failed. Please try again.',
  };
}
