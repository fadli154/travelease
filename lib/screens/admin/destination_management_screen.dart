import 'package:flutter/material.dart';

import '../../models/destination_model.dart';
import '../../services/firebase_service.dart';
import '../../theme/app_spacing.dart';
import '../../widgets/cached_destination_image.dart';
import '../../widgets/empty_state.dart';
import '../../utils/app_feedback.dart';
import '../../widgets/skeleton_loaders.dart';
import 'add_destination_screen.dart';
import 'edit_destination_screen.dart';

class DestinationManagementScreen extends StatefulWidget {
  const DestinationManagementScreen({
    super.key,
    this.service,
    this.openAddOnStart = false,
  });

  final FirebaseService? service;
  final bool openAddOnStart;

  @override
  State<DestinationManagementScreen> createState() =>
      _DestinationManagementScreenState();
}

class _DestinationManagementScreenState
    extends State<DestinationManagementScreen> {
  FirebaseService get _service => widget.service ?? FirebaseService();

  @override
  void initState() {
    super.initState();
    if (widget.openAddOnStart) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _openAdd());
    }
  }

  Future<void> _openAdd() async {
    await Navigator.of(context).push<bool>(
      MaterialPageRoute(builder: (_) => AddDestinationScreen(service: _service)),
    );
  }

  Future<void> _openEdit(DestinationModel destination) async {
    await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => EditDestinationScreen(
          destination: destination,
          service: _service,
        ),
      ),
    );
  }

  Future<void> _confirmDelete(DestinationModel destination) async {
    final ok = await AppFeedback.confirmDelete(
      context,
      title: 'Delete Destination',
      message: 'Are you sure you want to delete this destination?',
    );

    if (!ok || !mounted) return;

    try {
      await _service.deleteDestination(destination.id);
      if (!mounted) return;
      AppFeedback.success(context, 'Destination deleted successfully');
    } catch (e) {
      if (!mounted) return;
      AppFeedback.error(
        context,
        AppFeedback.actionError(e, 'Delete destination'),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return StreamBuilder<List<DestinationModel>>(
      stream: _service.getDestinations(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const DestinationListSkeleton();
        }

        if (snapshot.hasError) {
          return EmptyState(
            icon: Icons.error_outline_rounded,
            title: 'Could not load destinations',
            subtitle: '${snapshot.error}',
          );
        }

        final list = snapshot.data ?? [];
        if (list.isEmpty) {
          return EmptyState(
            icon: Icons.map_outlined,
            title: 'No destinations yet',
            subtitle: 'Tap + Add to create your first destination.',
            action: FilledButton.icon(
              onPressed: _openAdd,
              icon: const Icon(Icons.add_rounded),
              label: const Text('Add destination'),
            ),
          );
        }

        return ListView.separated(
          padding: const EdgeInsets.all(AppSpacing.screenH),
          itemCount: list.length,
          separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.betweenCards),
          itemBuilder: (context, index) {
            final d = list[index];
            return Card(
              clipBehavior: Clip.antiAlias,
              child: InkWell(
                onTap: () => _openEdit(d),
                child: Row(
                  children: [
                    ConstrainedBox(
                      constraints: const BoxConstraints(
                        maxWidth: 96,
                        maxHeight: 96,
                      ),
                      child: AspectRatio(
                        aspectRatio: 1.0,
                        child: CachedDestinationImage(
                          imageUrl: d.imageUrl,
                          imageSeed: d.id,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(AppSpacing.md),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              d.name,
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              d.location,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: colorScheme.onSurfaceVariant,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Row(
                              children: [
                                Icon(Icons.star_rounded,
                                    size: 16, color: Colors.amber[700]),
                                Text(' ${d.displayRating.toStringAsFixed(1)}'),
                                const SizedBox(width: 12),
                                Flexible(
                                  child: Text(
                                    d.category,
                                    overflow: TextOverflow.ellipsis,
                                    style: theme.textTheme.labelMedium,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.edit_outlined, color: colorScheme.primary),
                      onPressed: () => _openEdit(d),
                    ),
                    IconButton(
                      icon: Icon(Icons.delete_outline_rounded,
                          color: colorScheme.error),
                      onPressed: () => _confirmDelete(d),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}
