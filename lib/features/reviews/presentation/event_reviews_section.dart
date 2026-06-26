import 'package:flutter/material.dart';

import '../../../core/networking/api_client.dart';
import '../../../core/theme/eventhub_theme.dart';
import '../data/review_models.dart';
import '../data/review_repository.dart';

const _starColor = EventHubTheme.orange;

/// Self-contained reviews block for the event detail screen: lists reviews and
/// lets a signed-in user write (or update) their own review.
class EventReviewsSection extends StatefulWidget {
  const EventReviewsSection({
    required this.eventId,
    required this.authToken,
    this.reviewRepository,
    super.key,
  });

  final String eventId;
  final String authToken;
  final ReviewRepository? reviewRepository;

  @override
  State<EventReviewsSection> createState() => _EventReviewsSectionState();
}

class _EventReviewsSectionState extends State<EventReviewsSection> {
  late final ReviewRepository _reviewRepository;
  List<ReviewItem> _reviews = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _reviewRepository = widget.reviewRepository ?? ReviewRepository();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final reviews = await _reviewRepository.listReviews(widget.eventId);
      if (!mounted) return;
      setState(() => _reviews = reviews);
    } on ApiException catch (error) {
      if (!mounted) return;
      setState(() => _errorMessage = error.message);
    } catch (_) {
      if (!mounted) return;
      setState(() => _errorMessage = 'Unable to load reviews');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  double get _average {
    if (_reviews.isEmpty) return 0;
    final sum = _reviews.fold<int>(0, (total, r) => total + r.rating);
    return sum / _reviews.length;
  }

  Future<void> _writeReview() async {
    final result = await showModalBottomSheet<_ReviewDraft>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (_) => const _WriteReviewSheet(),
    );

    if (result == null) return;

    try {
      await _reviewRepository.createReview(
        authToken: widget.authToken,
        eventId: widget.eventId,
        rating: result.rating,
        comment: result.comment,
      );
      await _load();
    } on ApiException catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(error.message)));
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Unable to submit review')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                'Reviews',
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ),
            if (!_isLoading && _reviews.isNotEmpty) ...[
              const Icon(Icons.star_rounded, color: _starColor, size: 20),
              const SizedBox(width: 4),
              Text(
                '${_average.toStringAsFixed(1)} (${_reviews.length})',
                style: const TextStyle(fontWeight: FontWeight.w800),
              ),
            ],
          ],
        ),
        const SizedBox(height: 12),
        OutlinedButton.icon(
          onPressed: _writeReview,
          icon: const Icon(Icons.rate_review_outlined, size: 18),
          label: const Text('Write a review'),
          style: OutlinedButton.styleFrom(minimumSize: const Size(0, 46)),
        ),
        const SizedBox(height: 14),
        if (_isLoading)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 16),
            child: Center(child: CircularProgressIndicator()),
          )
        else if (_errorMessage != null)
          Text(
            _errorMessage!,
            style: TextStyle(color: Theme.of(context).colorScheme.error),
          )
        else if (_reviews.isEmpty)
          Text(
            'No reviews yet. Be the first to share your experience!',
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: EventHubTheme.muted),
          )
        else
          ..._reviews.map((review) => _ReviewCard(review: review)),
      ],
    );
  }
}

class _ReviewCard extends StatelessWidget {
  const _ReviewCard({required this.review});

  final ReviewItem review;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 20,
            backgroundColor: EventHubTheme.primary.withValues(alpha: 0.14),
            foregroundColor: EventHubTheme.primary,
            backgroundImage:
                (review.userAvatar != null && review.userAvatar!.isNotEmpty)
                ? NetworkImage(review.userAvatar!)
                : null,
            child: (review.userAvatar == null || review.userAvatar!.isEmpty)
                ? Text(
                    _initial(review.userName),
                    style: const TextStyle(fontWeight: FontWeight.w900),
                  )
                : null,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        review.userName ?? 'EventHub user',
                        style: const TextStyle(fontWeight: FontWeight.w800),
                      ),
                    ),
                    if (review.createdAt != null)
                      Text(
                        _formatDate(review.createdAt!),
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: EventHubTheme.muted,
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 4),
                _StarRow(rating: review.rating),
                if (review.comment.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Text(
                    review.comment,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: EventHubTheme.muted,
                      height: 1.4,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _initial(String? name) {
    if (name == null || name.trim().isEmpty) return '?';
    return name.trim().characters.first.toUpperCase();
  }

  String _formatDate(DateTime value) {
    final local = value.toLocal();
    return '${local.day.toString().padLeft(2, '0')}/'
        '${local.month.toString().padLeft(2, '0')}/${local.year}';
  }
}

class _StarRow extends StatelessWidget {
  const _StarRow({required this.rating});

  final int rating;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (index) {
        return Icon(
          index < rating ? Icons.star_rounded : Icons.star_border_rounded,
          color: _starColor,
          size: 18,
        );
      }),
    );
  }
}

class _ReviewDraft {
  const _ReviewDraft({required this.rating, required this.comment});

  final int rating;
  final String comment;
}

class _WriteReviewSheet extends StatefulWidget {
  const _WriteReviewSheet();

  @override
  State<_WriteReviewSheet> createState() => _WriteReviewSheetState();
}

class _WriteReviewSheetState extends State<_WriteReviewSheet> {
  int _rating = 5;
  final _commentController = TextEditingController();

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;

    return Padding(
      padding: EdgeInsets.fromLTRB(24, 20, 24, 24 + bottomInset),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 44,
              height: 5,
              decoration: BoxDecoration(
                color: EventHubTheme.muted.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
          const SizedBox(height: 18),
          Text(
            'Write a review',
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(5, (index) {
              final value = index + 1;
              return IconButton(
                onPressed: () => setState(() => _rating = value),
                iconSize: 38,
                icon: Icon(
                  value <= _rating
                      ? Icons.star_rounded
                      : Icons.star_border_rounded,
                  color: _starColor,
                ),
              );
            }),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _commentController,
            maxLines: 3,
            maxLength: 1000,
            decoration: const InputDecoration(
              hintText: 'Share your experience (optional)',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),
          FilledButton(
            onPressed: () {
              Navigator.of(context).pop(
                _ReviewDraft(
                  rating: _rating,
                  comment: _commentController.text.trim(),
                ),
              );
            },
            style: FilledButton.styleFrom(
              minimumSize: const Size.fromHeight(54),
            ),
            child: const Text('Submit review'),
          ),
        ],
      ),
    );
  }
}
