import 'package:flutter/material.dart';
import '../../l10n/app_localizations.dart';

import '../../models/destination_model.dart';
import '../../services/firebase_service.dart';
import '../../theme/app_theme_controller.dart';
import '../../widgets/destination_card.dart';
import '../../widgets/empty_state.dart';
import '../../theme/app_spacing.dart';
import '../../widgets/theme_toggle_button.dart';
import '../auth/login_screen.dart';

class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({
    super.key,
    required this.userId,
    this.service,
    this.themeController,
    Stream<List<DestinationModel>>? favoritesStream,
  }) : _favoritesStream = favoritesStream;

  final String userId;
  final FirebaseService? service;
  final AppThemeController? themeController;
  final Stream<List<DestinationModel>>? _favoritesStream;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final firebase = service ?? FirebaseService();

    // Guest: not logged in
    if (userId.isEmpty) {
      return Scaffold(
        appBar: AppBar(
          title: Text(l10n.myFavorites),
          actions: [
            if (themeController != null)
              ThemeToggleButton(controller: themeController!),
          ],
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.favorite_border_rounded,
                  size: 72,
                  color: colorScheme.onSurfaceVariant,
                ),
                const SizedBox(height: 20),
                Text(
                  l10n.signInToSaveFavorites,
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  l10n.signInToSaveFavoritesSubtitle,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 24),
                FilledButton.icon(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) => const LoginScreen(),
                      ),
                    );
                  },
                  icon: const Icon(Icons.login_rounded),
                  label: Text(l10n.signIn),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 120,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              titlePadding: const EdgeInsets.only(left: 20, bottom: 16),
              title: Text(
                l10n.myFavorites,
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: colorScheme.onPrimaryContainer,
                ),
              ),
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      colorScheme.primary,
                      colorScheme.primary.withValues(alpha: 0.75),
                    ],
                  ),
                ),
              ),
            ),
            actions: [
              if (themeController != null)
                ThemeToggleButton(controller: themeController!),
            ],
          ),
          StreamBuilder<List<DestinationModel>>(
            stream: _favoritesStream ??
                firebase.getFavoriteDestinations(userId),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const SliverFillRemaining(
                  child: Center(child: CircularProgressIndicator()),
                );
              }

              if (snapshot.hasError) {
                return SliverFillRemaining(
                  child: EmptyState(
                    icon: Icons.cloud_off_rounded,
                    title: l10n.errorLoadFavorites,
                    subtitle: '${snapshot.error}',
                  ),
                );
              }

              final favorites = snapshot.data ?? [];
              if (favorites.isEmpty) {
                return SliverFillRemaining(
                  child: EmptyState(
                    icon: Icons.favorite_border_rounded,
                    title: l10n.favoritesEmpty,
                    subtitle: l10n.favoritesEmptySubtitle,
                  ),
                );
              }

              return SliverPadding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.screenH,
                  AppSpacing.md,
                  AppSpacing.screenH,
                  AppSpacing.screenBottom,
                ),
                sliver: SliverList.separated(
                  itemCount: favorites.length,
                  separatorBuilder: (context, index) =>
                      const SizedBox(height: AppSpacing.betweenCards),
                  itemBuilder: (context, index) {
                    return DestinationCard(destination: favorites[index]);
                  },
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
