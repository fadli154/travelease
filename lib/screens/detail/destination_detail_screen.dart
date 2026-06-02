import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/destination_model.dart';
import '../../providers/auth_provider.dart';
import '../../services/firebase_service.dart';
import '../../theme/app_spacing.dart';
import '../../widgets/animated_favorite_button.dart';
import '../../widgets/cached_destination_image.dart';
import '../../widgets/destination_map_card.dart';
import '../auth/login_screen.dart';

class DestinationDetailScreen extends StatefulWidget {
  const DestinationDetailScreen({
    super.key,
    required this.destination,
    this.service,
  });

  final DestinationModel destination;
  final FirebaseService? service;

  @override
  State<DestinationDetailScreen> createState() =>
      _DestinationDetailScreenState();
}

class _DestinationDetailScreenState extends State<DestinationDetailScreen> {
  bool _isToggling = false;

  FirebaseService get _service => widget.service ?? FirebaseService();

  Future<void> _toggleFavorite(String userId, bool currentlyFavorite) async {
    if (_isToggling) return;

    setState(() => _isToggling = true);
    try {
      await _service.toggleFavorite(
        userId,
        widget.destination.id,
        currentlyFavorite: currentlyFavorite,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            currentlyFavorite
                ? 'Removed from favorites'
                : 'Added to favorites',
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not update favorite: $e')),
      );
    } finally {
      if (mounted) setState(() => _isToggling = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final destination = widget.destination;
    final auth = context.watch<AuthProvider>();
    final userId = auth.currentUser?.uid ?? '';
    final isLoggedIn = userId.isNotEmpty;

    return Scaffold(
      extendBodyBehindAppBar: true,
      body: CustomScrollView(
        slivers: [
          // ── Hero image app bar ─────────────────────────────────────────────
          SliverAppBar(
            expandedHeight: 340,
            pinned: true,
            stretch: true,
            backgroundColor: colorScheme.surface,
            flexibleSpace: FlexibleSpaceBar(
              stretchModes: const [
                StretchMode.zoomBackground,
                StretchMode.blurBackground,
              ],
              background: Stack(
                fit: StackFit.expand,
                children: [
                  CachedDestinationImage(imageUrl: destination.imageUrl),
                  DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.black.withValues(alpha: 0.35),
                          Colors.transparent,
                          Colors.black.withValues(alpha: 0.55),
                        ],
                        stops: const [0, 0.45, 1],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              if (isLoggedIn)
                StreamBuilder<bool>(
                  stream: _service.isFavorite(userId, destination.id),
                  builder: (context, snapshot) {
                    final isFavorite = snapshot.data ?? false;
                    return AnimatedFavoriteButton(
                      isFavorite: isFavorite,
                      isLoading: _isToggling,
                      onPressed: () => _toggleFavorite(userId, isFavorite),
                    );
                  },
                ),
            ],
          ),

          // ── Content ────────────────────────────────────────────────────────
          SliverToBoxAdapter(
            child: Transform.translate(
              offset: const Offset(0, -20),
              child: Container(
                decoration: BoxDecoration(
                  color: colorScheme.surface,
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(28)),
                ),
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.xl,
                  AppSpacing.xl,
                  AppSpacing.xl,
                  AppSpacing.screenBottom + 16,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Name + rating
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            destination.name,
                            style: theme.textTheme.headlineMedium?.copyWith(
                              fontWeight: FontWeight.w800,
                              letterSpacing: -0.5,
                              height: 1.15,
                            ),
                          ),
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        _RatingBadge(rating: destination.rating),
                      ],
                    ),

                    const SizedBox(height: AppSpacing.md),

                    _InfoRow(
                      icon: Icons.location_on_rounded,
                      label: destination.location,
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    _InfoRow(
                      icon: Icons.category_outlined,
                      label: destination.category,
                    ),

                    // Ticket price
                    if (destination.ticketPrice > 0) ...[
                      const SizedBox(height: AppSpacing.sm),
                      _InfoRow(
                        icon: Icons.confirmation_number_outlined,
                        label:
                            'Rp ${destination.ticketPrice.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.')}',
                      ),
                    ],

                    const SizedBox(height: AppSpacing.section),

                    // Overview
                    Text(
                      'Overview',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      destination.description.isEmpty
                          ? 'No description available for this destination.'
                          : destination.description,
                      style: theme.textTheme.bodyLarge?.copyWith(
                        height: 1.65,
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),

                    const SizedBox(height: AppSpacing.section),
                    DestinationMapCard(
                      location: destination.location,
                      placeName: destination.name,
                    ),
                    const SizedBox(height: AppSpacing.section),

                    // Favorite button or login prompt
                    if (isLoggedIn)
                      StreamBuilder<bool>(
                        stream: _service.isFavorite(userId, destination.id),
                        builder: (context, snapshot) {
                          final isFavorite = snapshot.data ?? false;
                          return SizedBox(
                            width: double.infinity,
                            child: FilledButton.icon(
                              onPressed: _isToggling
                                  ? null
                                  : () => _toggleFavorite(userId, isFavorite),
                              icon: Icon(
                                isFavorite
                                    ? Icons.favorite_rounded
                                    : Icons.favorite_border_rounded,
                              ),
                              label: Text(
                                isFavorite
                                    ? 'Saved to Favorites'
                                    : 'Add to Favorites',
                              ),
                              style: FilledButton.styleFrom(
                                backgroundColor: isFavorite
                                    ? colorScheme.errorContainer
                                    : colorScheme.primary,
                                foregroundColor: isFavorite
                                    ? colorScheme.onErrorContainer
                                    : colorScheme.onPrimary,
                              ),
                            ),
                          );
                        },
                      )
                    else
                      OutlinedButton.icon(
                        onPressed: () => Navigator.of(context).push(
                          MaterialPageRoute<void>(
                            builder: (_) => const LoginScreen(),
                          ),
                        ),
                        icon: const Icon(Icons.favorite_border_rounded),
                        label: const Text('Sign in to save favorite'),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Private widgets ───────────────────────────────────────────────────────────

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Row(
      children: [
        Icon(icon, size: 20, color: colorScheme.primary),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: Text(
            label,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ),
      ],
    );
  }
}

class _RatingBadge extends StatelessWidget {
  const _RatingBadge({required this.rating});

  final double rating;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.amber.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.amber.withValues(alpha: 0.35)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.star_rounded, color: Colors.amber[700], size: 22),
          const SizedBox(width: 4),
          Text(
            rating.toStringAsFixed(1),
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}
