import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

/// Maps auth errors to user-friendly copy and logs root cause in debug.
class AuthErrorMapper {
  static String userMessage(Object error) {
    if (error is FirebaseAuthException) {
      return _firebaseAuthMessage(error);
    }
    final raw = error.toString();
    if (raw.contains('cancelled') || raw.contains('canceled')) {
      return 'Sign-in was cancelled.';
    }
    if (raw.contains('network') || raw.contains('Network')) {
      return 'No internet connection. Check your network and try again.';
    }
    if (raw.contains('id token') || raw.contains('ID token')) {
      return 'Google sign-in configuration error. Ensure Web Client ID is set (see debug log).';
    }
    if (raw.contains('DEVELOPER_ERROR') || raw.contains('10:')) {
      return 'Google Sign-In is misconfigured. Add your app SHA-1 in Firebase Console.';
    }
    if (raw.contains('permission-denied') || raw.contains('PERMISSION_DENIED')) {
      return 'Could not save your profile. Check Firestore security rules.';
    }
    return 'Sign-in failed. See details in the message below or contact support.';
  }

  static String debugMessage(Object error) {
    if (error is FirebaseAuthException) {
      return 'FirebaseAuthException [${error.code}]: ${error.message}';
    }
    return error.toString();
  }

  static void log(Object error, {String? context}) {
    if (!kDebugMode) return;
    final prefix = context != null ? '[$context] ' : '';
    debugPrint('${prefix}Auth error: ${debugMessage(error)}');
    if (error is FirebaseAuthException) {
      debugPrint('${prefix}Firebase code: ${error.code}');
    }
  }

  static String _firebaseAuthMessage(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
      case 'wrong-password':
      case 'invalid-credential':
      case 'invalid-login-credentials':
        return 'Invalid email or password.';
      case 'email-already-in-use':
        return 'An account already exists with this email.';
      case 'weak-password':
        return 'Password must be at least 6 characters.';
      case 'invalid-email':
        return 'Please enter a valid email address.';
      case 'account-exists-with-different-credential':
        return 'This email is linked to another sign-in method. Try email/password.';
      case 'operation-not-allowed':
        return 'Google sign-in is disabled in Firebase Console. Enable it under Authentication → Sign-in method.';
      case 'user-disabled':
        return 'This account has been disabled.';
      case 'network-request-failed':
        return 'Network error. Check your connection.';
      default:
        return 'Authentication failed (${e.code}). ${e.message ?? ''}'.trim();
    }
  }
}
