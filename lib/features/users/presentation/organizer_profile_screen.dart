import 'package:flutter/material.dart';

import '../../../core/networking/api_client.dart';
import '../../../core/theme/eventhub_theme.dart';
import '../../events/data/event_models.dart';
import '../../events/data/event_repository.dart';
import '../../events/presentation/event_detail_screen.dart';
import '../../reviews/data/review_models.dart';
import '../../reviews/data/review_repository.dart';
import '../data/user_models.dart';
import '../data/user_repository.dart';

class OrganizerProfileScreen extends StatefulWidget {
  const OrganizerProfileScreen({
    required this.organizerId,
    required this.authToken,
    required this.currentUserId,
    required this.currentUserRole,
    super.key,
  });

  final String organizerId;
  final String authToken;
  final String currentUserId;
  final String currentUserRole;

  @override
  State<OrganizerProfileScreen> createState() => _OrganizerProfileScreenState();
}

class _OrganizerProfileScreenState extends State<OrganizerProfileScreen> {
  final _userRepository = UserRepository();
  final _eventRepository = EventRepository();
  final _reviewRepository = ReviewRepository();

  UserProfile? _profile;
  List<EventItem> _events = [];
  List<ReviewItem> _reviews = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final results = await Future.wait([
        _userRepository.getUserById(widget.organizerId),
        _eventRepository.listEvents(organizerId: widget.organizerId, limit: 50),
        _reviewRepository.listOrganizerReviews(widget.organizerId),
      ]);

      if (!mounted) return;
      setState(() {
        _profile = results[0] as UserProfile;
        _events = (results[1] as PaginatedEvents).data;
        _reviews = results[2] as List<ReviewItem>;
      });
    } on ApiException catch (error) {
      if (!mounted) return;
      setState(() => _errorMessage = error.message);
    } catch (_) {
      if (!mounted) return;
      setState(() => _errorMessage = 'Unable to load organizer');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _openEvent(EventItem event) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => EventDetailScreen(
          eventId: event.id,
          authToken: widget.authToken,
          currentUserId: widget.currentUserId,
          currentUserRole: widget.currentUserRole,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (_errorMessage != null || _profile == null) {
      return Scaffold(
        appBar: AppBar(),
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(_errorMessage ?? 'Organizer not found'),
              const SizedBox(height: 12),
              OutlinedButton.icon(
                onPressed: _load,
                icon: const Icon(Icons.refresh),
                label: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    final profile = _profile!;

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(title: const Text('Organizer')),
        body: Column(
          children: [
            const SizedBox(height: 12),
            CircleAvatar(
              radius: 44,
              backgroundColor: EventHubTheme.primary.withValues(alpha: 0.14),
              foregroundColor: EventHubTheme.primary,
              backgroundImage:
                  (profile.avatarUrl != null && profile.avatarUrl!.isNotEmpty)
                  ? NetworkImage(profile.avatarUrl!)
                  : null,
              child: (profile.avatarUrl == null || profile.avatarUrl!.isEmpty)
                  ? Text(
                      _initials(profile.fullName),
                      style: const TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.w900,
                      ),
                    )
                  : null,
            ),
            const SizedBox(height: 12),
            Text(
              profile.fullName,
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _Stat(value: '${_events.length}', label: 'Events'),
                Container(
                  width: 1,
                  height: 32,
                  margin: const EdgeInsets.symmetric(horizontal: 24),
                  color: EventHubTheme.muted.withValues(alpha: 0.3),
                ),
                _Stat(value: '${_reviews.length}', label: 'Reviews'),
              ],
            ),
            const SizedBox(height: 14),
            const TabBar(
              labelColor: EventHubTheme.primary,
              indicatorColor: EventHubTheme.primary,
              tabs: [
                Tab(text: 'ABOUT'),
                Tab(text: 'EVENTS'),
                Tab(text: 'REVIEWS'),
              ],
            ),
            Expanded(
              child: TabBarView(
                children: [
                  _AboutTab(profile: profile),
                  _EventsTab(events: _events, onOpenEvent: _openEvent),
                  _ReviewsTab(reviews: _reviews),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _initials(String value) {
    final words = value
        .trim()
        .split(RegExp(r'\s+'))
        .where((word) => word.isNotEmpty)
        .toList();
    if (words.isEmpty) return '?';
    return words
        .take(2)
        .map((word) => word.characters.first)
        .join()
        .toUpperCase();
  }
}

class _Stat extends StatelessWidget {
  const _Stat({required this.value, required this.label});

  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
        ),
        Text(
          label,
          style: Theme.of(
            context,
          ).textTheme.bodySmall?.copyWith(color: EventHubTheme.muted),
        ),
      ],
    );
  }
}

class _AboutTab extends StatelessWidget {
  const _AboutTab({required this.profile});

  final UserProfile profile;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        Text('About', style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 10),
        Text(
          (profile.bio != null && profile.bio!.isNotEmpty)
              ? profile.bio!
              : 'This organizer has not added a description yet.',
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            color: EventHubTheme.muted,
            height: 1.5,
          ),
        ),
        if (profile.interests.isNotEmpty) ...[
          const SizedBox(height: 24),
          Text('Interests', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 12),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: profile.interests
                .map(
                  (interest) => Chip(
                    label: Text(interest),
                    backgroundColor: EventHubTheme.primary.withValues(
                      alpha: 0.12,
                    ),
                    side: BorderSide.none,
                  ),
                )
                .toList(),
          ),
        ],
      ],
    );
  }
}

class _EventsTab extends StatelessWidget {
  const _EventsTab({required this.events, required this.onOpenEvent});

  final List<EventItem> events;
  final ValueChanged<EventItem> onOpenEvent;

  @override
  Widget build(BuildContext context) {
    if (events.isEmpty) {
      return const Center(child: Text('No events yet'));
    }

    return ListView.separated(
      padding: const EdgeInsets.all(20),
      itemCount: events.length,
      separatorBuilder: (_, _) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final event = events[index];

        return Material(
          color: Colors.white,
          elevation: 4,
          shadowColor: const Color(0x106F73A8),
          borderRadius: BorderRadius.circular(16),
          child: ListTile(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            leading: const CircleAvatar(
              backgroundColor: EventHubTheme.softBlue,
              foregroundColor: EventHubTheme.primary,
              child: Icon(Icons.event),
            ),
            title: Text(
              event.title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontWeight: FontWeight.w800),
            ),
            subtitle: Text(
              '${event.venueName} · ${event.isFree ? 'Free' : '\$${event.price.toStringAsFixed(0)}'}',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => onOpenEvent(event),
          ),
        );
      },
    );
  }
}

class _ReviewsTab extends StatelessWidget {
  const _ReviewsTab({required this.reviews});

  final List<ReviewItem> reviews;

  @override
  Widget build(BuildContext context) {
    if (reviews.isEmpty) {
      return const Center(child: Text('No reviews yet'));
    }

    return ListView.separated(
      padding: const EdgeInsets.all(20),
      itemCount: reviews.length,
      separatorBuilder: (_, _) => const Divider(height: 28),
      itemBuilder: (context, index) {
        final review = reviews[index];

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              radius: 20,
              backgroundColor: EventHubTheme.primary.withValues(alpha: 0.14),
              foregroundColor: EventHubTheme.primary,
              child: Text(
                (review.userName != null && review.userName!.isNotEmpty)
                    ? review.userName!.characters.first.toUpperCase()
                    : '?',
                style: const TextStyle(fontWeight: FontWeight.w900),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    review.userName ?? 'EventHub user',
                    style: const TextStyle(fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: List.generate(5, (starIndex) {
                      return Icon(
                        starIndex < review.rating
                            ? Icons.star_rounded
                            : Icons.star_border_rounded,
                        color: EventHubTheme.orange,
                        size: 18,
                      );
                    }),
                  ),
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
        );
      },
    );
  }
}
