import 'package:flutter/material.dart';

import '../models/destination_model.dart';
import '../theme/app_spacing.dart';
import '../screens/detail/destination_detail_screen.dart';
import 'cached_destination_image.dart';

class SearchResultTile extends StatelessWidget {
  const SearchResultTile({super.key, required this.destination});

  final DestinationModel destination;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Material(
      color: colorScheme.surfaceContainerLowest,
      borderRadius: BorderRadius.circular(16),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute<void>(
              builder: (_) => DestinationDetailScreen(destination: destination),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: SizedBox(
                  width: 72,
                  height: 72,
                  child: CachedDestinationImage(
                    imageUrl: destination.imageUrl,
                    imageSeed: destination.id,
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      destination.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      destination.location,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Icon(Icons.star_rounded, size: 16, color: Colors.amber[700]),
                        const SizedBox(width: 2),
                        Text(
                          destination.displayRating.toStringAsFixed(1),
                          style: theme.textTheme.labelLarge,
                        ),
                        const SizedBox(width: 8),
                        Flexible(
                          child: Text(
                            destination.category,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.labelMedium?.copyWith(
                              color: colorScheme.primary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right_rounded, color: colorScheme.outline),
            ],
          ),
        ),
      ),
    );
  }
}
