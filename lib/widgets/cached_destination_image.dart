import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class CachedDestinationImage extends StatelessWidget {
  const CachedDestinationImage({
    super.key,
    required this.imageUrl,
    this.fit = BoxFit.cover,
    this.borderRadius,
    this.placeholderIcon = Icons.landscape_rounded,
  });

  final String imageUrl;
  final BoxFit fit;
  final BorderRadius? borderRadius;
  final IconData placeholderIcon;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    Widget child;
    if (imageUrl.isEmpty) {
      child = _placeholder(colorScheme);
    } else {
      child = CachedNetworkImage(
        imageUrl: imageUrl,
        fit: fit,
        placeholder: (_, __) => _shimmer(colorScheme),
        errorWidget: (_, __, ___) => _error(colorScheme),
      );
    }

    if (borderRadius != null) {
      child = ClipRRect(borderRadius: borderRadius!, child: child);
    }
    return child;
  }

  Widget _shimmer(ColorScheme colorScheme) {
    return Shimmer.fromColors(
      baseColor: colorScheme.surfaceContainerHighest,
      highlightColor: colorScheme.surfaceContainerLow,
      child: ColoredBox(color: colorScheme.surfaceContainerHighest),
    );
  }

  Widget _placeholder(ColorScheme colorScheme) {
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            colorScheme.primary.withValues(alpha: 0.85),
            colorScheme.tertiary.withValues(alpha: 0.7),
          ],
        ),
      ),
      child: Center(
        child: Icon(placeholderIcon, size: 48, color: colorScheme.onPrimary.withValues(alpha: 0.8)),
      ),
    );
  }

  Widget _error(ColorScheme colorScheme) {
    return ColoredBox(
      color: colorScheme.surfaceContainerHighest,
      child: Center(
        child: Icon(
          Icons.broken_image_outlined,
          size: 40,
          color: colorScheme.onSurfaceVariant,
        ),
      ),
    );
  }
}
