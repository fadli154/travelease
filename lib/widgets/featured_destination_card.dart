import 'package:flutter/material.dart';

import '../models/destination_model.dart';
import '../screens/detail/destination_detail_screen.dart';
import 'cached_destination_image.dart';

class FeaturedDestinationCard extends StatelessWidget {
  const FeaturedDestinationCard({super.key, required this.destination});

  final DestinationModel destination;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return SizedBox(
      width: 200,
      child: Material(
        color: colorScheme.surfaceContainerLowest,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => DestinationDetailScreen(destination: destination),
              ),
            );
          },
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                height: 130,
                width: double.infinity,
                child: CachedDestinationImage(
                  imageUrl: destination.imageUrl,
                  imageSeed: destination.id,
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      destination.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(Icons.star_rounded, size: 16, color: Colors.amber[700]),
                        const SizedBox(width: 2),
                        Text(
                          destination.displayRating.toStringAsFixed(1),
                          style: theme.textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
