import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';

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
    String? deleteLabel,
  }) async {
    final l10n = AppLocalizations.of(context)!;
    var confirmed = false;
    await AwesomeDialog(
      context: context,
      dialogType: DialogType.warning,
      animType: AnimType.scale,
      title: title,
      desc: message,
      btnCancelOnPress: () {},
      btnOkOnPress: () => confirmed = true,
      btnOkText: deleteLabel ?? l10n.delete,
      btnCancelText: l10n.cancel,
      btnOkColor: Theme.of(context).colorScheme.error,
    ).show();
    return confirmed;
  }

  static Future<void> logoutSuccess(BuildContext context) async {
    final l10n = AppLocalizations.of(context)!;
    await AwesomeDialog(
      context: context,
      dialogType: DialogType.success,
      animType: AnimType.scale,
      title: l10n.logoutSuccessTitle,
      desc: l10n.logoutSuccessDesc,
      btnOkOnPress: () {},
      btnOkText: 'OK',
      autoHide: const Duration(seconds: 3),
    ).show();
  }

  static Future<bool> confirmSignOut(BuildContext context) async {
    final l10n = AppLocalizations.of(context)!;
    var confirmed = false;
    await AwesomeDialog(
      context: context,
      dialogType: DialogType.question,
      animType: AnimType.scale,
      title: l10n.signOutConfirmTitle,
      desc: l10n.signOutConfirmDesc,
      btnCancelOnPress: () {},
      btnOkOnPress: () => confirmed = true,
      btnOkText: l10n.signOut,
      btnCancelText: l10n.cancel,
    ).show();
    return confirmed;
  }
}

