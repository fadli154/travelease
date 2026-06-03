import 'package:flutter/material.dart';
import '../../l10n/app_localizations.dart';

import '../../models/destination_model.dart';
import '../../services/firebase_service.dart';
import '../../theme/app_theme_controller.dart';
import '../../utils/destination_sections.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/featured_destination_card.dart';
import '../../widgets/hero_destination_banner.dart';
import '../../widgets/destination_card.dart';
import '../../widgets/section_header.dart';
import '../../widgets/skeleton_loaders.dart';
import '../../theme/app_spacing.dart';
import '../../widgets/theme_toggle_button.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({
    super.key,
    this.service,
    this.themeController,
    Stream<List<DestinationModel>>? destinationsStream,
  }) : _destinationsStream = destinationsStream;

  final FirebaseService? service;
  final AppThemeController? themeController;
  final Stream<List<DestinationModel>>? _destinationsStream;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return Scaffold(
      body: StreamBuilder<List<DestinationModel>>(
        stream:
            _destinationsStream ??
            (service ?? FirebaseService()).getDestinations(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const HomeScreenSkeleton();
          }

          if (snapshot.hasError) {
            return CustomScrollView(
              slivers: [
                _HomeAppBar(themeController: themeController),
                SliverFillRemaining(
                  child: EmptyState(
                    icon: Icons.cloud_off_rounded,
                    title: l10n.errorLoadDestinations,
                    subtitle:
                        '${l10n.errorLoadDestinationsSubtitle}\n${snapshot.error}',
                  ),
                ),
              ],
            );
          }

          final destinations = snapshot.data ?? [];
          if (destinations.isEmpty) {
            return CustomScrollView(
              slivers: [
                _HomeAppBar(themeController: themeController),
                SliverFillRemaining(
                  child: EmptyState(
                    icon: Icons.explore_off_rounded,
                    title: l10n.emptyDestinations,
                    subtitle: l10n.emptyDestinationsSubtitle,
                  ),
                ),
              ],
            );
          }

          final featured = DestinationSections.featured(destinations);
          final popular = DestinationSections.popular(destinations);

          return CustomScrollView(
            slivers: [
              _HomeAppBar(themeController: themeController),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.screenH,
                    AppSpacing.sm,
                    AppSpacing.screenH,
                    0,
                  ),
                  child: Text(
                    l10n.homeWelcomeTitle,
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.5,
                    ),
                  ),
                ),
              ),
              SliverToBoxAdapter(child: HeroDestinationBanner(destinations: featured)),
              SliverToBoxAdapter(
                child: SectionHeader(
                  title: l10n.featured,
                  subtitle: l10n.featuredSubtitle,
                ),
              ),
              SliverToBoxAdapter(
                child: SizedBox(
                  height: 220,
                  child: ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screenH),
                    scrollDirection: Axis.horizontal,
                    itemCount: featured.length,
                    separatorBuilder: (_, _) => const SizedBox(width: AppSpacing.md),
                    itemBuilder: (context, index) {
                      return FeaturedDestinationCard(destination: featured[index]);
                    },
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: SectionHeader(
                  title: l10n.popular,
                  subtitle: l10n.popularSubtitle,
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.screenH,
                  0,
                  AppSpacing.screenH,
                  AppSpacing.screenBottom,
                ),
                sliver: SliverList.separated(
                  itemCount: popular.length,
                  separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.betweenCards),
                  itemBuilder: (context, index) {
                    return DestinationCard(destination: popular[index]);
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _HomeAppBar extends StatelessWidget {
  const _HomeAppBar({this.themeController});

  final AppThemeController? themeController;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return SliverAppBar(
      floating: true,
      snap: true,
      title: Row(
        children: [
          Icon(Icons.flight_takeoff_rounded, color: colorScheme.primary, size: 26),
          const SizedBox(width: 8),
          Text(
            'TravelEase',
            style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
          ),
        ],
      ),
      actions: [
        if (themeController != null)
          ThemeToggleButton(controller: themeController!),
      ],
    );
  }
}
