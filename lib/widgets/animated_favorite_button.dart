import 'package:flutter/material.dart';

/// Stable favorite toggle — fixed size, no layout-affecting animations.
class AnimatedFavoriteButton extends StatelessWidget {
  const AnimatedFavoriteButton({
    super.key,
    required this.isFavorite,
    required this.onPressed,
    this.isLoading = false,
  });

  final bool isFavorite;
  final VoidCallback? onPressed;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final color = isFavorite ? colorScheme.error : colorScheme.onSurface;

    return SizedBox(
      width: 48,
      height: 48,
      child: IconButton(
        onPressed: isLoading ? null : onPressed,
        icon: isLoading
            ? SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: colorScheme.primary,
                ),
              )
            : Icon(
                isFavorite ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                color: color,
              ),
      ),
    );
  }
}
