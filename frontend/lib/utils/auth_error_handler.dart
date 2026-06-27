/// Maps raw Firebase / Apple / Google auth exceptions to short,
/// user-friendly messages.  Returns null when the user intentionally
/// cancelled — callers should silently swallow those cases.
String? friendlyAuthError(Object error) {
  final raw = error.toString();

  // ── User cancelled (silent) ────────────────────────────────────────────
  // Apple error 1001 = AuthorizationErrorCode.canceled
  if (raw.contains('AuthorizationErrorCode.canceled') ||
      raw.contains('error 1001') ||
      raw.contains('com.google.GIDSignIn') && raw.contains('cancel') ||
      raw.contains('PlatformException(sign_in_canceled') ||
      raw.contains('sign_in_cancelled')) {
    return null; // swallow silently
  }

  // ── Firebase Auth error codes ──────────────────────────────────────────
  if (raw.contains('firebase_auth/')) {
    if (raw.contains('invalid-credential') ||
        raw.contains('wrong-password') ||
        raw.contains('invalid-email')) {
      return 'Incorrect email or password. Please try again.';
    }
    if (raw.contains('user-not-found')) {
      return 'No account found with that email.';
    }
    if (raw.contains('email-already-in-use')) {
      return 'An account with this email already exists.';
    }
    if (raw.contains('weak-password')) {
      return 'Password must be at least 6 characters.';
    }
    if (raw.contains('too-many-requests')) {
      return 'Too many attempts. Please wait a moment and try again.';
    }
    if (raw.contains('user-disabled')) {
      return 'This account has been disabled. Please contact support.';
    }
    if (raw.contains('network-request-failed')) {
      return 'No internet connection. Please check your network.';
    }
    if (raw.contains('popup-closed-by-user') ||
        raw.contains('popup-blocked')) {
      return null; // user closed popup — silent
    }
    if (raw.contains('account-exists-with-different-credential')) {
      return 'An account already exists with a different sign-in method.';
    }
    if (raw.contains('keychain-error')) {
      return 'Keychain access error. Try restarting the simulator or erasing its content (Device -> Erase All Content and Settings).';
    }
    // Generic Firebase fallback
    return 'Sign-in failed. Please try again.';
  }

  // ── Apple Sign-In errors ───────────────────────────────────────────────
  if (raw.contains('AuthorizationErrorCode') ||
      raw.contains('AuthenticationServices')) {
    if (raw.contains('unknown') || raw.contains('error 1000')) {
      return 'Apple Sign-In is not available right now. Try again.';
    }
    if (raw.contains('failed') || raw.contains('error 1004')) {
      return 'Apple Sign-In failed. Please try again.';
    }
    if (raw.contains('notHandled') || raw.contains('invalidResponse')) {
      return 'Apple returned an unexpected response. Please try again.';
    }
    if (raw.contains('identity token') || raw.contains('identityToken')) {
      return 'Could not verify Apple ID. Ensure you are signed into iCloud.';
    }
    return 'Apple Sign-In failed. Please try again.';
  }

  // ── Google Sign-In errors ──────────────────────────────────────────────
  if (raw.contains('google') || raw.contains('GoogleSignIn')) {
    if (raw.contains('network_error')) {
      return 'No internet connection. Please check your network.';
    }
    return 'Google Sign-In failed. Please try again.';
  }

  // ── Validation / custom errors (thrown by us) ─────────────────────────
  if (raw.startsWith('Exception: ')) {
    return raw.replaceFirst('Exception: ', '');
  }

  // ── Generic fallback ───────────────────────────────────────────────────
  return 'Something went wrong. Please try again.';
}
