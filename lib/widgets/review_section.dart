import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/review_model.dart';
import '../models/user_model.dart';
import '../providers/auth_provider.dart';
import '../services/firebase_service.dart';
import '../theme/app_spacing.dart';
import '../utils/app_feedback.dart';
import '../utils/image_helper.dart';
import 'cached_destination_image.dart';
import 'empty_state.dart';
import 'user_avatar.dart';

class ReviewSection extends StatelessWidget {
  const ReviewSection({
    super.key,
    required this.destinationId,
    this.service,
  });

  final String destinationId;
  final FirebaseService? service;

  FirebaseService get _service => service ?? FirebaseService();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final auth = context.watch<AuthProvider>();
    final user = auth.currentUser;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                'Reviews',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            if (user != null)
              TextButton.icon(
                onPressed: () => _showReviewDialog(context, user),
                icon: const Icon(Icons.rate_review_outlined),
                label: const Text('Write review'),
              ),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),
        StreamBuilder<List<ReviewModel>>(
          stream: _service.getReviewsForDestination(destinationId),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Padding(
                padding: EdgeInsets.all(24),
                child: Center(child: CircularProgressIndicator()),
              );
            }
            if (snapshot.hasError) {
              return EmptyState(
                icon: Icons.error_outline,
                title: 'Could not load reviews',
                subtitle: '${snapshot.error}',
                compact: true,
              );
            }

            final reviews = snapshot.data ?? [];
            if (reviews.isEmpty) {
              return const EmptyState(
                icon: Icons.reviews_outlined,
                title: 'Reviews Empty',
                subtitle: 'Be the first to share your experience.',
                compact: true,
              );
            }

            return ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: reviews.length,
              separatorBuilder: (_, _) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final review = reviews[index];
                final isOwner = user?.uid == review.userId;
                final isAdmin = user?.isAdmin ?? false;
                return _ReviewCard(
                  review: review,
                  canEdit: isOwner,
                  canDelete: isOwner || isAdmin,
                  onEdit: isOwner
                      ? () => _showReviewDialog(context, user!, existing: review)
                      : null,
                  onDelete: (isOwner || isAdmin)
                      ? () => _confirmDelete(context, review)
                      : null,
                );
              },
            );
          },
        ),
      ],
    );
  }

  Future<void> _confirmDelete(BuildContext context, ReviewModel review) async {
    final ok = await AppFeedback.confirmDelete(
      context,
      title: 'Delete Review',
      message: 'Are you sure you want to delete this review?',
    );
    if (!ok || !context.mounted) return;
    try {
      await _service.deleteReview(
        reviewId: review.id,
        destinationId: review.destinationId,
      );
      if (context.mounted) {
        AppFeedback.success(context, 'Review deleted successfully');
      }
    } catch (e) {
      if (context.mounted) {
        AppFeedback.error(
          context,
          AppFeedback.actionError(e, 'Delete review'),
        );
      }
    }
  }

  Future<void> _showReviewDialog(
    BuildContext context,
    UserModel user, {
    ReviewModel? existing,
  }) async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.viewInsetsOf(ctx).bottom,
        ),
        child: _ReviewFormSheet(
          destinationId: destinationId,
          user: user,
          existing: existing,
          service: _service,
        ),
      ),
    );
  }
}

class _ReviewCard extends StatelessWidget {
  const _ReviewCard({
    required this.review,
    required this.canEdit,
    required this.canDelete,
    this.onEdit,
    this.onDelete,
  });

  final ReviewModel review;
  final bool canEdit;
  final bool canDelete;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: theme.colorScheme.surfaceContainerLow,
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                UserAvatar(
                  name: review.userName,
                  photoUrl: review.userPhoto,
                  radius: 20,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(review.userName, style: theme.textTheme.titleSmall),
                      Row(
                        children: List.generate(5, (i) {
                          return Icon(
                            i < review.rating.round()
                                ? Icons.star_rounded
                                : Icons.star_border_rounded,
                            size: 16,
                            color: Colors.amber[700],
                          );
                        }),
                      ),
                    ],
                  ),
                ),
                if (canEdit)
                  IconButton(icon: const Icon(Icons.edit_outlined), onPressed: onEdit),
                if (canDelete)
                  IconButton(
                    icon: Icon(Icons.delete_outline, color: theme.colorScheme.error),
                    onPressed: onDelete,
                  ),
              ],
            ),
            if (review.comment.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(review.comment),
            ],
            if (review.imageUrl.isNotEmpty) ...[
              const SizedBox(height: 10),
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: CachedDestinationImage(imageUrl: review.imageUrl),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _ReviewFormSheet extends StatefulWidget {
  const _ReviewFormSheet({
    required this.destinationId,
    required this.user,
    required this.service,
    this.existing,
  });

  final String destinationId;
  final UserModel user;
  final FirebaseService service;
  final ReviewModel? existing;

  @override
  State<_ReviewFormSheet> createState() => _ReviewFormSheetState();
}

class _ReviewFormSheetState extends State<_ReviewFormSheet> {
  final _commentController = TextEditingController();
  double _rating = 5;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    if (widget.existing != null) {
      _rating = widget.existing!.rating;
      _commentController.text = widget.existing!.comment;
    }
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    setState(() => _saving = true);
    try {
      final avatarUrl = ImageHelper.userAvatarUrl(
        name: widget.user.name,
        photoUrl: widget.user.photoUrl,
      );
      if (widget.existing != null) {
        final updated = ReviewModel(
          id: widget.existing!.id,
          destinationId: widget.destinationId,
          userId: widget.user.uid,
          userName: widget.user.name,
          userPhoto: avatarUrl,
          rating: _rating,
          comment: _commentController.text.trim(),
          imageUrl: widget.existing!.imageUrl,
        );
        await widget.service.updateReview(updated);
      } else {
        final review = ReviewModel(
          id: '',
          destinationId: widget.destinationId,
          userId: widget.user.uid,
          userName: widget.user.name,
          userPhoto: avatarUrl,
          rating: _rating,
          comment: _commentController.text.trim(),
          imageUrl: '',
        );
        await widget.service.addReview(review);
      }
      if (mounted) {
        Navigator.pop(context);
        AppFeedback.success(
          context,
          widget.existing == null
              ? 'Review added successfully'
              : 'Review updated successfully',
        );
      }
    } catch (e) {
      if (mounted) {
        AppFeedback.error(
          context,
          AppFeedback.actionError(e, 'Save review'),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.screenH),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            widget.existing == null ? 'Write a review' : 'Edit review',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(5, (i) {
              final star = i + 1.0;
              return IconButton(
                onPressed: () => setState(() => _rating = star),
                icon: Icon(
                  star <= _rating ? Icons.star_rounded : Icons.star_border_rounded,
                  color: Colors.amber[700],
                  size: 32,
                ),
              );
            }),
          ),
          TextField(
            controller: _commentController,
            maxLines: 4,
            decoration: const InputDecoration(
              labelText: 'Your experience',
              alignLabelWithHint: true,
            ),
          ),
          const SizedBox(height: 16),
          FilledButton(
            onPressed: _saving ? null : _submit,
            child: _saving
                ? const SizedBox(
                    height: 22,
                    width: 22,
                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                  )
                : Text(widget.existing == null ? 'Submit review' : 'Save changes'),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
