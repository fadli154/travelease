import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class SkeletonBox extends StatelessWidget {
  const SkeletonBox({
    super.key,
    required this.width,
    required this.height,
    this.borderRadius = 12,
  });

  final double width;
  final double height;
  final double borderRadius;

  @override
  Widget build(BuildContext context) {
    final base = Theme.of(context).colorScheme.surfaceContainerHighest;
    final highlight = Theme.of(context).colorScheme.surfaceContainerLow;

    return Shimmer.fromColors(
      baseColor: base,
      highlightColor: highlight,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: base,
          borderRadius: BorderRadius.circular(borderRadius),
        ),
      ),
    );
  }
}

class HomeScreenSkeleton extends StatelessWidget {
  const HomeScreenSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width - 40;

    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SkeletonBox(width: width, height: 200, borderRadius: 24),
                const SizedBox(height: 24),
                const SkeletonBox(width: 160, height: 22, borderRadius: 8),
                const SizedBox(height: 16),
                SizedBox(
                  height: 220,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: 3,
                    separatorBuilder: (_, __) => const SizedBox(width: 14),
                    itemBuilder: (_, __) => const SkeletonBox(width: 180, height: 220, borderRadius: 20),
                  ),
                ),
                const SizedBox(height: 24),
                const SkeletonBox(width: 140, height: 22, borderRadius: 8),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
        SliverList.builder(
          itemCount: 4,
          itemBuilder: (context, index) {
            final cardWidth = MediaQuery.sizeOf(context).width - 32;
            return Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
              child: SkeletonBox(width: cardWidth, height: 280, borderRadius: 20),
            );
          },
        ),
      ],
    );
  }
}

class DestinationListSkeleton extends StatelessWidget {
  const DestinationListSkeleton({super.key, this.itemCount = 4});

  final int itemCount;

  @override
  Widget build(BuildContext context) {
    final cardWidth = MediaQuery.sizeOf(context).width - 32;

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: itemCount,
      separatorBuilder: (_, __) => const SizedBox(height: 14),
      itemBuilder: (_, __) => SkeletonBox(
        width: cardWidth,
        height: 280,
        borderRadius: 20,
      ),
    );
  }
}

class SearchResultsSkeleton extends StatelessWidget {
  const SearchResultsSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    final tileWidth = MediaQuery.sizeOf(context).width - 32;

    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: 5,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (_, __) => SkeletonBox(
        width: tileWidth,
        height: 88,
        borderRadius: 16,
      ),
    );
  }
}
