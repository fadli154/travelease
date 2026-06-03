import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

/// Consistent CRUD and session feedback across the app.
class AppFeedback {
  AppFeedback._();

  static void success(BuildContext context, String message) {
    final messenger = ScaffoldMessenger.of(context);
    messenger.clearSnackBars();
    messenger.showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
        content: Text(
          message,
          style: TextStyle(
            color: Theme.of(context).colorScheme.onPrimaryContainer,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  static void error(BuildContext context, String message) {
    final messenger = ScaffoldMessenger.of(context);
    messenger.clearSnackBars();
    messenger.showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        backgroundColor: Theme.of(context).colorScheme.errorContainer,
        content: Text(
          message,
          style: TextStyle(
            color: Theme.of(context).colorScheme.onErrorContainer,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  static String actionError(Object error, String action) {
    if (error is FirebaseException) {
      final msg = error.message?.trim();
      if (msg != null && msg.isNotEmpty) {
        return '$action failed: $msg';
      }
      return '$action failed (${error.code})';
    }
    if (error is FirebaseAuthException) {
      final msg = error.message?.trim();
      if (msg != null && msg.isNotEmpty) {
        return '$action failed: $msg';
      }
      return '$action failed (${error.code})';
    }
    final text = error.toString();
    if (text.contains('Exception:')) {
      return text.replaceFirst('Exception:', '').trim();
    }
    return '$action failed: $text';
  }

  static Future<bool> confirmDelete(
    BuildContext context, {
    required String title,
    required String message,
    String deleteLabel = 'Delete',
  }) async {
    var confirmed = false;
    await AwesomeDialog(
      context: context,
      dialogType: DialogType.warning,
      animType: AnimType.scale,
      title: title,
      desc: message,
      btnCancelOnPress: () {},
      btnOkOnPress: () => confirmed = true,
      btnOkText: deleteLabel,
      btnCancelText: 'Cancel',
      btnOkColor: Theme.of(context).colorScheme.error,
    ).show();
    return confirmed;
  }

  static Future<void> logoutSuccess(BuildContext context) async {
    await AwesomeDialog(
      context: context,
      dialogType: DialogType.success,
      animType: AnimType.scale,
      title: 'Berhasil logout',
      desc: 'Anda berhasil logout. Sampai jumpa lagi!',
      btnOkOnPress: () {},
      btnOkText: 'OK',
      autoHide: const Duration(seconds: 3),
    ).show();
  }

  static Future<bool> confirmSignOut(BuildContext context) async {
    var confirmed = false;
    await AwesomeDialog(
      context: context,
      dialogType: DialogType.question,
      animType: AnimType.scale,
      title: 'Sign out?',
      desc: 'You will be returned to the login screen.',
      btnCancelOnPress: () {},
      btnOkOnPress: () => confirmed = true,
      btnOkText: 'Sign Out',
      btnCancelText: 'Cancel',
    ).show();
    return confirmed;
  }
}
