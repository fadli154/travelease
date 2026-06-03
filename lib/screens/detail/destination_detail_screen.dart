import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../l10n/app_localizations.dart';

import '../../models/destination_model.dart';
import '../../providers/auth_provider.dart';
import '../../services/firebase_service.dart';
import '../../theme/app_spacing.dart';
import '../../widgets/animated_favorite_button.dart';
import '../../widgets/cached_destination_image.dart';
import '../../widgets/destination_map_card.dart';
import '../../utils/app_feedback.dart';
import '../../widgets/review_section.dart';
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
  bool _isFavorite = false;
  StreamSubscription<bool>? _favoriteSub;

  FirebaseService get _service => widget.service ?? FirebaseService();

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _bindFavoriteStream();
  }

  void _bindFavoriteStream() {
    final userId = context.read<AuthProvider>().currentUser?.uid ?? '';
    _favoriteSub?.cancel();
    if (userId.isEmpty) {
      _isFavorite = false;
      return;
    }
    _favoriteSub = _service.isFavorite(userId, widget.destination.id).listen((
      value,
    ) {
      if (mounted) setState(() => _isFavorite = value);
    });
  }

  @override
  void dispose() {
    _favoriteSub?.cancel();
    super.dispose();
  }

  Future<void> _toggleFavorite(String userId) async {
    if (_isToggling) return;
    final wasFavorite = _isFavorite;
    final l10n = AppLocalizations.of(context)!;

    setState(() => _isToggling = true);
    try {
      await _service.toggleFavorite(
        userId,
        widget.destination.id,
        currentlyFavorite: wasFavorite,
      );
      if (!mounted) return;
      AppFeedback.success(
        context,
        wasFavorite
            ? l10n.favoriteRemoved
            : l10n.favoriteAdded,
      );
    } catch (e) {
      if (!mounted) return;
      AppFeedback.error(
        context,
        AppFeedback.actionError(
          e,
          wasFavorite ? 'Remove favorite' : 'Add favorite',
        ),
      );
    } finally {
      if (mounted) setState(() => _isToggling = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final l10n = AppLocalizations.of(context)!;
    final destination = widget.destination;
    final auth = context.watch<AuthProvider>();
    final userId = auth.currentUser?.uid ?? '';
    final isLoggedIn = userId.isNotEmpty;
    final displayRating = destination.displayRating;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 360,
            pinned: true,
            stretch: false,
            backgroundColor: colorScheme.surface,
            flexibleSpace: FlexibleSpaceBar(
              titlePadding: const EdgeInsets.only(
                left: 16,
                right: 16,
                bottom: 16,
              ),
              title: Text(
                destination.name,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.titleLarge?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                  shadows: const [Shadow(blurRadius: 8, color: Colors.black54)],
                ),
              ),
              background: Stack(
                fit: StackFit.expand,
                children: [
                  CachedDestinationImage(
                    imageUrl: destination.imageUrl,
                    imageSeed: destination.id,
                  ),
                  DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.black.withValues(alpha: 0.4),
                          Colors.transparent,
                          Colors.black.withValues(alpha: 0.75),
                        ],
                        stops: const [0, 0.4, 1],
                      ),
                    ),
                  ),
                  Positioned(
                    left: 16,
                    right: 16,
                    bottom: 110,
                    child: Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _HeroChip(
                          icon: Icons.category_rounded,
                          label: destination.category,
                        ),
                        if (destination.ticketPrice > 0)
                          _HeroChip(
                            icon: Icons.confirmation_number_outlined,
                            label:
                                'Rp ${_formatPrice(destination.ticketPrice)}',
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              if (isLoggedIn)
                AnimatedFavoriteButton(
                  isFavorite: _isFavorite,
                  isLoading: _isToggling,
                  onPressed: () => _toggleFavorite(userId),
                ),
            ],
          ),
          SliverToBoxAdapter(
            child: Transform.translate(
              offset: const Offset(0, -20),
              child: Container(
                decoration: BoxDecoration(
                  color: colorScheme.surface,
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(28),
                  ),
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
                    _StatsGrid(
                      location: destination.locationName,
                      rating: displayRating,
                      totalReviews: destination.totalReviews,
                      ticketPrice: destination.ticketPrice,
                      formatPrice: _formatPrice,
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    _DetailActionRow(
                      isLoggedIn: isLoggedIn,
                      isFavorite: _isFavorite,
                      isToggling: _isToggling,
                      onFavorite: () => _toggleFavorite(userId),
                      onMaps: () => _openMaps(destination),
                      onReview: isLoggedIn
                          ? () => _scrollToReviews(context)
                          : () => Navigator.of(context).push(
                              MaterialPageRoute<void>(
                                builder: (_) => const LoginScreen(),
                              ),
                            ),
                    ),
                    const SizedBox(height: AppSpacing.section),
                    Text(
                      l10n.overview,
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      destination.description.isEmpty
                          ? l10n.noDescription
                          : destination.description,
                      style: theme.textTheme.bodyLarge?.copyWith(
                        height: 1.65,
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.section),
                    DestinationMapCard(destination: destination),
                    const SizedBox(height: AppSpacing.section),
                    ReviewSection(
                      destinationId: destination.id,
                      service: _service,
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

  Future<void> _openMaps(DestinationModel destination) async {
    final uri = destination.hasCoordinates
        ? Uri.parse(
            'https://www.google.com/maps/search/?api=1&query=${destination.latitude},${destination.longitude}',
          )
        : Uri.parse(
            'https://www.google.com/maps/search/?api=1&query=${Uri.encodeComponent(destination.locationName)}',
          );
    try {
      if (await canLaunchUrl(uri)) {
        final success = await launchUrl(uri, mode: LaunchMode.externalApplication);
        if (!success) {
          await launchUrl(uri, mode: LaunchMode.platformDefault);
        }
      } else {
        await launchUrl(uri, mode: LaunchMode.platformDefault);
      }
    } catch (e) {
      if (mounted) {
        final l10n = AppLocalizations.of(context)!;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.couldNotOpenMap(e.toString()))),
        );
      }
    }
  }

  void _scrollToReviews(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    // Review section is below the fold; user can scroll — show hint.
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(l10n.scrollDownReview),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  String _formatPrice(double price) {
    return price
        .toStringAsFixed(0)
        .replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (m) => '${m[1]}.',
        );
  }
}

class _HeroChip extends StatelessWidget {
  const _HeroChip({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.45),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white24),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: Colors.white),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatsGrid extends StatelessWidget {
  const _StatsGrid({
    required this.location,
    required this.rating,
    required this.totalReviews,
    required this.ticketPrice,
    required this.formatPrice,
  });

  final String location;
  final double rating;
  final int totalReviews;
  final double ticketPrice;
  final String Function(double) formatPrice;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 10,
      crossAxisSpacing: 10,
      childAspectRatio: 1.55,
      children: [
        _StatTile(
          icon: Icons.location_on_rounded,
          label: l10n.location,
          value: location,
          color: colorScheme.primaryContainer,
        ),
        _StatTile(
          icon: Icons.star_rounded,
          label: l10n.rating,
          value: rating.toStringAsFixed(1),
          subtitle: totalReviews > 0
              ? l10n.reviewsCount(totalReviews)
              : l10n.noReviewsCount,
          color: Colors.amber.withValues(alpha: 0.2),
        ),
        _StatTile(
          icon: Icons.confirmation_number_outlined,
          label: l10n.ticket,
          value: ticketPrice > 0
              ? 'Rp ${formatPrice(ticketPrice)}'
              : l10n.freeTicket,
          color: colorScheme.secondaryContainer,
        ),
        _StatTile(
          icon: Icons.reviews_outlined,
          label: l10n.reviews,
          value: '$totalReviews',
          color: colorScheme.tertiaryContainer,
        ),
      ],
    );
  }
}

class _StatTile extends StatelessWidget {
  const _StatTile({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
    this.subtitle,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color color;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: color,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 20),
            const Spacer(),
            Text(label, style: Theme.of(context).textTheme.labelMedium),
            Text(
              value,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(
                context,
              ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800),
            ),
            if (subtitle != null)
              Text(subtitle!, style: Theme.of(context).textTheme.labelSmall),
          ],
        ),
      ),
    );
  }
}

class _DetailActionRow extends StatelessWidget {
  const _DetailActionRow({
    required this.isLoggedIn,
    required this.isFavorite,
    required this.isToggling,
    required this.onFavorite,
    required this.onMaps,
    required this.onReview,
  });

  final bool isLoggedIn;
  final bool isFavorite;
  final bool isToggling;
  final VoidCallback onFavorite;
  final VoidCallback onMaps;
  final VoidCallback onReview;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Row(
      children: [
        Expanded(
          child: FilledButton.tonalIcon(
            onPressed: isToggling || !isLoggedIn ? null : onFavorite,
            icon: Icon(
              isFavorite
                  ? Icons.favorite_rounded
                  : Icons.favorite_border_rounded,
            ),
            label: Text(
              isFavorite ? l10n.saved : l10n.favorite,
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: FilledButton.tonalIcon(
            onPressed: onMaps,
            icon: const Icon(Icons.map_rounded),
            label: Text(
              l10n.maps,
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: FilledButton.tonalIcon(
            onPressed: onReview,
            icon: const Icon(Icons.rate_review_outlined),
            label: Text(
              l10n.review,
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12),
            ),
          ),
        ),
      ],
    );
  }
}
