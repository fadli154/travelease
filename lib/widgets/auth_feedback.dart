import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';
import '../providers/auth_provider.dart';

void showAuthFeedback(BuildContext context, AuthProvider auth) {
  if (auth.error == null) return;

  final l10n = AppLocalizations.of(context)!;
  final messenger = ScaffoldMessenger.of(context);
  messenger.clearSnackBars();
  messenger.showSnackBar(
    SnackBar(
      backgroundColor: Theme.of(context).colorScheme.errorContainer,
      behavior: SnackBarBehavior.floating,
      duration: const Duration(seconds: 6),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            auth.error!,
            style: TextStyle(
              color: Theme.of(context).colorScheme.onErrorContainer,
              fontWeight: FontWeight.w600,
            ),
          ),
          if (auth.errorDetail != null) ...[
            const SizedBox(height: 6),
            Text(
              kDebugMode
                  ? auth.errorDetail!
                  : l10n.authErrorDetailFallback,
              style: TextStyle(
                fontSize: 12,
                color: Theme.of(context).colorScheme.onErrorContainer.withValues(alpha: 0.85),
              ),
            ),
          ],
        ],
      ),
      action: SnackBarAction(
        label: l10n.dismiss,
        textColor: Theme.of(context).colorScheme.onErrorContainer,
        onPressed: () => messenger.hideCurrentSnackBar(),
      ),
    ),
  );
}

