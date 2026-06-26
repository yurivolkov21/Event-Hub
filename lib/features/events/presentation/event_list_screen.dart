import 'package:flutter/material.dart';

import '../../../core/networking/api_client.dart';
import '../../../core/theme/eventhub_theme.dart';
import '../../../core/widgets/empty_state.dart';
import '../../bookmarks/data/bookmark_repository.dart';
import '../../invitations/presentation/my_invitations_screen.dart';
import '../data/event_models.dart';
import '../data/event_repository.dart';
import 'all_events_screen.dart';
import 'event_detail_screen.dart';
import 'event_filter_sheet.dart';
import 'event_form_screen.dart';
import 'event_image.dart';

class EventListScreen extends StatefulWidget {
  const EventListScreen({
    required this.authToken,
    required this.currentUserId,
    required this.currentUserRole,
    this.eventRepository,
    this.bookmarkRepository,
    super.key,
  });

  final String authToken;
  final String currentUserId;
  final String currentUserRole;
  final EventRepository? eventRepository;
  final BookmarkRepository? bookmarkRepository;

  @override
  State<EventListScreen> createState() => _EventListScreenState();
}

class _EventListScreenState extends State<EventListScreen> {
  late final EventRepository _eventRepository;
  late final BookmarkRepository _bookmarkRepository;
  final _searchController = TextEditingController();

  List<EventItem> _events = [];
  Set<String> _bookmarkedEventIds = {};
  String? _errorMessage;
  String? _selectedCategoryId;
  EventFilter _filter = EventFilter.empty;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _eventRepository = widget.eventRepository ?? EventRepository();
    _bookmarkRepository = widget.bookmarkRepository ?? BookmarkRepository();
    _loadEvents();
    _loadBookmarks();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadEvents() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final response = await _eventRepository.listEvents(
        search: _searchController.text,
        categoryId: _selectedCategoryId,
        minPrice: _filter.minPrice,
        maxPrice: _filter.maxPrice,
        date: _filter.date,
      );
      setState(() => _events = response.data);
    } on ApiException catch (error) {
      setState(() => _errorMessage = error.message);
    } catch (_) {
      setState(() => _errorMessage = 'Unable to load events');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _loadBookmarks() async {
    try {
      final bookmarks = await _bookmarkRepository.listMyBookmarks(
        authToken: widget.authToken,
      );
      if (!mounted) {
        return;
      }
      setState(() {
        _bookmarkedEventIds = bookmarks.map((bookmark) => bookmark.eventId).toSet();
      });
    } catch (_) {
      // Bookmark indicators are best-effort; ignore load failures.
    }
  }

  Future<void> _toggleBookmark(EventItem event) async {
    final wasBookmarked = _bookmarkedEventIds.contains(event.id);

    setState(() {
      if (wasBookmarked) {
        _bookmarkedEventIds.remove(event.id);
      } else {
        _bookmarkedEventIds.add(event.id);
      }
    });

    try {
      if (wasBookmarked) {
        await _bookmarkRepository.deleteBookmark(
          authToken: widget.authToken,
          eventId: event.id,
        );
      } else {
        await _bookmarkRepository.createBookmark(
          authToken: widget.authToken,
          eventId: event.id,
        );
      }
    } catch (_) {
      if (!mounted) {
        return;
      }
      // Roll back the optimistic update if the request failed.
      setState(() {
        if (wasBookmarked) {
          _bookmarkedEventIds.add(event.id);
        } else {
          _bookmarkedEventIds.remove(event.id);
        }
      });
    }
  }

  Future<void> _openFilters() async {
    final result = await showEventFilterSheet(context, _filter);

    if (result == null) {
      return;
    }

    setState(() => _filter = result);
    _loadEvents();
  }

  void _selectCategory(String? categoryId) {
    setState(() => _selectedCategoryId = categoryId);
    _loadEvents();
  }

  void _openEvent(EventItem event) {
    Navigator.of(context)
        .push<bool>(
          MaterialPageRoute<bool>(
            builder: (_) => EventDetailScreen(
              eventId: event.id,
              authToken: widget.authToken,
              currentUserId: widget.currentUserId,
              currentUserRole: widget.currentUserRole,
            ),
          ),
        )
        .then((changed) {
          if (changed == true) {
            _loadEvents();
          }
        });
  }

  void _openInvitations() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => MyInvitationsScreen(
          authToken: widget.authToken,
          currentUserId: widget.currentUserId,
          currentUserRole: widget.currentUserRole,
        ),
      ),
    );
  }

  void _openAllEvents() {
    Navigator.of(context)
        .push<bool>(
          MaterialPageRoute<bool>(
            builder: (_) => AllEventsScreen(
              authToken: widget.authToken,
              currentUserId: widget.currentUserId,
              currentUserRole: widget.currentUserRole,
            ),
          ),
        )
        .then((changed) {
          if (changed == true) {
            _loadEvents();
          }
        });
  }

  Future<void> _openCreateEvent() async {
    final changed = await Navigator.of(context).push<bool>(
      MaterialPageRoute<bool>(
        builder: (_) => EventFormScreen(authToken: widget.authToken),
      ),
    );

    if (changed == true) {
      // Clear any active filter/search so a newly created event is always
      // visible in the list (otherwise it can look like the create "failed").
      _searchController.clear();
      setState(() {
        _selectedCategoryId = null;
        _filter = EventFilter.empty;
      });
      await _loadEvents();
    }
  }

  @override
  Widget build(BuildContext context) {
    final canCreate =
        widget.currentUserRole == 'organizer' ||
        widget.currentUserRole == 'admin';

    return Scaffold(
      floatingActionButton: canCreate
          ? FloatingActionButton(
              tooltip: 'Create event',
              onPressed: _openCreateEvent,
              child: const Icon(Icons.add),
            )
          : null,
      body: RefreshIndicator(
        onRefresh: _loadEvents,
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            _ExploreHeader(
              searchController: _searchController,
              selectedCategoryId: _selectedCategoryId,
              isFilterActive: _filter.isActive,
              onSearch: _loadEvents,
              onOpenFilters: _openFilters,
              onCategorySelected: _selectCategory,
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 22, 24, 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _SectionHeader(
                    title: 'Upcoming Events',
                    onTap: _openAllEvents,
                  ),
                  const SizedBox(height: 16),
                  if (_isLoading)
                    const _EventListLoading()
                  else if (_errorMessage != null)
                    _EventListMessage(
                      icon: Icons.error_outline,
                      message: _errorMessage!,
                      onRetry: _loadEvents,
                    )
                  else if (_events.isEmpty)
                    EmptyState(
                      icon: Icons.event_busy,
                      title: 'No Upcoming Event',
                      message:
                          'There are no events to show right now. Pull to refresh or check back soon.',
                      actionLabel: 'EXPLORE EVENTS',
                      onAction: _loadEvents,
                    )
                  else ...[
                    SizedBox(
                      height: 368,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: _events.length,
                        separatorBuilder: (_, _) => const SizedBox(width: 18),
                        itemBuilder: (context, index) {
                          final event = _events[index];

                          return SizedBox(
                            width: 292,
                            child: _FeaturedEventCard(
                              event: event,
                              isBookmarked: _bookmarkedEventIds.contains(
                                event.id,
                              ),
                              onTap: () => _openEvent(event),
                              onToggleBookmark: () => _toggleBookmark(event),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 26),
                    _InviteBanner(onTap: _openInvitations),
                    const SizedBox(height: 28),
                    _SectionHeader(title: 'Nearby You', onTap: _openAllEvents),
                    const SizedBox(height: 14),
                    ..._events.map(
                      (event) => Padding(
                        padding: const EdgeInsets.only(bottom: 14),
                        child: _CompactEventTile(
                          event: event,
                          onTap: () => _openEvent(event),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ExploreHeader extends StatelessWidget {
  const _ExploreHeader({
    required this.searchController,
    required this.selectedCategoryId,
    required this.isFilterActive,
    required this.onSearch,
    required this.onOpenFilters,
    required this.onCategorySelected,
  });

  final TextEditingController searchController;
  final String? selectedCategoryId;
  final bool isFilterActive;
  final VoidCallback onSearch;
  final VoidCallback onOpenFilters;
  final ValueChanged<String?> onCategorySelected;

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.paddingOf(context).top;

    return Container(
      decoration: const BoxDecoration(
        color: EventHubTheme.primary,
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(36)),
      ),
      padding: EdgeInsets.fromLTRB(20, topPadding + 14, 20, 24),
      child: Column(
        children: [
          Row(
            children: [
              IconButton.filled(
                tooltip: 'Back',
                onPressed: () => Navigator.of(context).maybePop(),
                style: IconButton.styleFrom(
                  backgroundColor: Colors.white.withValues(alpha: 0.18),
                  foregroundColor: Colors.white,
                ),
                icon: const Icon(Icons.arrow_back),
              ),
              const Spacer(),
              Column(
                children: [
                  Text(
                    'Current Location',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.white.withValues(alpha: 0.7),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'EventHub, Android',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
              const Spacer(),
              IconButton.filled(
                tooltip: 'Refresh',
                onPressed: onSearch,
                style: IconButton.styleFrom(
                  backgroundColor: Colors.white.withValues(alpha: 0.18),
                  foregroundColor: Colors.white,
                ),
                icon: const Icon(Icons.notifications_none),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: searchController,
                  onSubmitted: (_) => onSearch(),
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: 'Search...',
                    hintStyle: TextStyle(
                      color: Colors.white.withValues(alpha: 0.55),
                      fontSize: 20,
                      fontWeight: FontWeight.w500,
                    ),
                    prefixIcon: const Icon(Icons.search, color: Colors.white),
                    suffixIcon: IconButton(
                      tooltip: 'Search',
                      onPressed: onSearch,
                      icon: const Icon(
                        Icons.arrow_forward,
                        color: Colors.white,
                      ),
                    ),
                    filled: false,
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              FilledButton.icon(
                onPressed: onOpenFilters,
                icon: const Icon(Icons.tune, size: 18),
                label: Text(isFilterActive ? 'Filters •' : 'Filters'),
                style: FilledButton.styleFrom(
                  backgroundColor: isFilterActive
                      ? Colors.white
                      : Colors.white.withValues(alpha: 0.16),
                  foregroundColor: isFilterActive
                      ? EventHubTheme.primary
                      : Colors.white,
                  minimumSize: const Size(0, 48),
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 54,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                _CategoryPill(
                  label: 'All',
                  icon: Icons.apps,
                  color: EventHubTheme.primaryDark,
                  selected: selectedCategoryId == null,
                  onTap: () => onCategorySelected(null),
                ),
                ...eventCategoryOptions.map((category) {
                  final style = _categoryStyle(category.name);

                  return _CategoryPill(
                    label: category.name,
                    icon: style.icon,
                    color: style.color,
                    selected: selectedCategoryId == category.id,
                    onTap: () => onCategorySelected(category.id),
                  );
                }),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CategoryPill extends StatelessWidget {
  const _CategoryPill({
    required this.label,
    required this.icon,
    required this.color,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final Color color;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 12),
      child: ActionChip(
        onPressed: onTap,
        avatar: Icon(icon, color: Colors.white, size: 20),
        label: Text(label),
        labelStyle: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w800,
        ),
        backgroundColor: selected ? color : color.withValues(alpha: 0.86),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        side: BorderSide(
          color: selected ? Colors.white : Colors.transparent,
          width: 1.4,
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title, required this.onTap});

  final String title;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(title, style: Theme.of(context).textTheme.headlineSmall),
        ),
        TextButton.icon(
          onPressed: onTap,
          iconAlignment: IconAlignment.end,
          icon: const Icon(Icons.play_arrow, size: 18),
          label: const Text('See All'),
        ),
      ],
    );
  }
}

class _FeaturedEventCard extends StatelessWidget {
  const _FeaturedEventCard({
    required this.event,
    required this.isBookmarked,
    required this.onTap,
    required this.onToggleBookmark,
  });

  final EventItem event;
  final bool isBookmarked;
  final VoidCallback onTap;
  final VoidCallback onToggleBookmark;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      elevation: 12,
      shadowColor: const Color(0x146F73A8),
      borderRadius: BorderRadius.circular(24),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(18),
                    child: EventImage(imageUrl: event.imageUrl, height: 174),
                  ),
                  Positioned(
                    left: 12,
                    top: 12,
                    child: _DateBadge(date: event.startAt),
                  ),
                  Positioned(
                    right: 12,
                    top: 12,
                    child: IconButton.filled(
                      tooltip: isBookmarked ? 'Remove bookmark' : 'Bookmark',
                      onPressed: onToggleBookmark,
                      style: IconButton.styleFrom(
                        backgroundColor: Colors.white.withValues(alpha: 0.9),
                        foregroundColor: isBookmarked
                            ? EventHubTheme.coral
                            : EventHubTheme.muted,
                      ),
                      icon: Icon(
                        isBookmarked ? Icons.bookmark : Icons.bookmark_border,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Text(
                event.title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  const _MiniAvatar(color: Color(0xFFFF8BA7), label: 'A'),
                  const _MiniAvatar(color: Color(0xFFFFC1A6), label: 'S'),
                  const _MiniAvatar(color: Color(0xFF75C7F0), label: 'J'),
                  const SizedBox(width: 8),
                  Text(
                    '+${event.bookedCount + 20} Going',
                    style: const TextStyle(
                      color: EventHubTheme.primary,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  const Icon(
                    Icons.location_on,
                    color: EventHubTheme.muted,
                    size: 18,
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      '${event.venueName}, ${event.address}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CompactEventTile extends StatelessWidget {
  const _CompactEventTile({required this.event, required this.onTap});

  final EventItem event;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      elevation: 6,
      shadowColor: const Color(0x106F73A8),
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: SizedBox(
                  width: 90,
                  height: 88,
                  child: EventImage(imageUrl: event.imageUrl, height: 88),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _formatDateTime(event.startAt),
                      style: const TextStyle(
                        color: EventHubTheme.primary,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      event.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(
                          Icons.location_on,
                          color: EventHubTheme.muted,
                          size: 16,
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            event.venueName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: EventHubTheme.muted),
            ],
          ),
        ),
      ),
    );
  }
}

class _InviteBanner extends StatelessWidget {
  const _InviteBanner({required this.onTap});

  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: const Color(0xFFD8FAFA),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Your invitations',
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900),
                ),
                const SizedBox(height: 8),
                Text(
                  'See events friends invited you to',
                  style: Theme.of(
                    context,
                  ).textTheme.bodyLarge?.copyWith(color: EventHubTheme.muted),
                ),
                const SizedBox(height: 18),
                FilledButton(
                  onPressed: onTap,
                  style: FilledButton.styleFrom(
                    backgroundColor: EventHubTheme.accent,
                    minimumSize: const Size(132, 48),
                  ),
                  child: const Text('VIEW'),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Container(
            width: 86,
            height: 86,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.7),
              borderRadius: BorderRadius.circular(28),
            ),
            child: const Icon(
              Icons.card_giftcard,
              color: EventHubTheme.primary,
              size: 42,
            ),
          ),
        ],
      ),
    );
  }
}

class _DateBadge extends StatelessWidget {
  const _DateBadge({required this.date});

  final DateTime date;

  @override
  Widget build(BuildContext context) {
    final local = date.toLocal();

    return Container(
      width: 58,
      height: 70,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.94),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            local.day.toString().padLeft(2, '0'),
            style: const TextStyle(
              color: EventHubTheme.coral,
              fontSize: 21,
              fontWeight: FontWeight.w900,
            ),
          ),
          Text(
            _monthShort(local.month).toUpperCase(),
            style: const TextStyle(
              color: EventHubTheme.coral,
              fontWeight: FontWeight.w900,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}

class _MiniAvatar extends StatelessWidget {
  const _MiniAvatar({required this.color, required this.label});

  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Align(
      widthFactor: 0.72,
      child: CircleAvatar(
        radius: 15,
        backgroundColor: Colors.white,
        child: CircleAvatar(
          radius: 13,
          backgroundColor: color,
          child: Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w900,
              fontSize: 11,
            ),
          ),
        ),
      ),
    );
  }
}

class _EventListLoading extends StatelessWidget {
  const _EventListLoading();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.only(top: 72, bottom: 72),
      child: Center(child: CircularProgressIndicator()),
    );
  }
}

class _EventListMessage extends StatelessWidget {
  const _EventListMessage({
    required this.icon,
    required this.message,
    required this.onRetry,
  });

  final IconData icon;
  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 72, bottom: 72),
      child: Center(
        child: Column(
          children: [
            Icon(icon, size: 42, color: EventHubTheme.primary),
            const SizedBox(height: 12),
            Text(message, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 16),
            OutlinedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}

class _CategoryStyle {
  const _CategoryStyle({required this.icon, required this.color});

  final IconData icon;
  final Color color;
}

_CategoryStyle _categoryStyle(String categoryName) {
  switch (categoryName.toLowerCase()) {
    case 'sports':
      return const _CategoryStyle(
        icon: Icons.sports_basketball,
        color: EventHubTheme.coral,
      );
    case 'music':
      return const _CategoryStyle(
        icon: Icons.music_note,
        color: EventHubTheme.orange,
      );
    case 'food':
      return const _CategoryStyle(
        icon: Icons.restaurant,
        color: EventHubTheme.green,
      );
    case 'art':
      return const _CategoryStyle(
        icon: Icons.brush_outlined,
        color: Color(0xFF7D6BFF),
      );
    case 'movie':
      return const _CategoryStyle(
        icon: Icons.movie_outlined,
        color: Color(0xFF4AC7EC),
      );
    case 'concert':
      return const _CategoryStyle(
        icon: Icons.mic_external_on_outlined,
        color: Color(0xFFFF6A8D),
      );
    case 'games online':
      return const _CategoryStyle(
        icon: Icons.sports_esports_outlined,
        color: Color(0xFF2EC9A6),
      );
    default:
      return const _CategoryStyle(
        icon: Icons.category_outlined,
        color: EventHubTheme.primary,
      );
  }
}

String _formatDateTime(DateTime value) {
  final local = value.toLocal();
  final day = local.day.toString().padLeft(2, '0');
  final month = _monthShort(local.month);
  final hour = local.hour.toString().padLeft(2, '0');
  final minute = local.minute.toString().padLeft(2, '0');

  return '$day $month, $hour:$minute';
}

String _monthShort(int month) {
  const months = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];

  return months[month - 1];
}
