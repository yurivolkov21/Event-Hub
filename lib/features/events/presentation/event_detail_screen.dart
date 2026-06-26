import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';

import '../../../core/networking/api_client.dart';
import '../../../core/theme/eventhub_theme.dart';
import '../../bookings/data/booking_repository.dart';
import '../../bookmarks/data/bookmark_repository.dart';
import '../../invitations/presentation/invite_friends_sheet.dart';
import '../data/event_models.dart';
import '../data/event_repository.dart';
import 'event_form_screen.dart';
import 'event_image.dart';

class EventDetailScreen extends StatefulWidget {
  const EventDetailScreen({
    required this.eventId,
    required this.authToken,
    required this.currentUserId,
    required this.currentUserRole,
    this.eventRepository,
    super.key,
  });

  final String eventId;
  final String authToken;
  final String currentUserId;
  final String currentUserRole;
  final EventRepository? eventRepository;

  @override
  State<EventDetailScreen> createState() => _EventDetailScreenState();
}

class _EventDetailScreenState extends State<EventDetailScreen> {
  late final EventRepository _eventRepository;
  late final BookingRepository _bookingRepository;
  late final BookmarkRepository _bookmarkRepository;
  EventItem? _event;
  String? _errorMessage;
  bool _isLoading = true;
  bool _isBookmarked = false;
  bool _isBookmarkLoading = false;
  bool _isBooking = false;

  @override
  void initState() {
    super.initState();
    _eventRepository = widget.eventRepository ?? EventRepository();
    _bookingRepository = BookingRepository();
    _bookmarkRepository = BookmarkRepository();
    _loadEvent();
  }

  Future<void> _loadEvent() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final event = await _eventRepository.getEventById(widget.eventId);
      setState(() => _event = event);
      await _loadBookmarkState(event.id);
    } on ApiException catch (error) {
      setState(() => _errorMessage = error.message);
    } catch (_) {
      setState(() => _errorMessage = 'Unable to load event');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _loadBookmarkState(String eventId) async {
    try {
      final bookmarks = await _bookmarkRepository.listMyBookmarks(
        authToken: widget.authToken,
      );

      if (mounted) {
        setState(() {
          _isBookmarked = bookmarks.any(
            (bookmark) => bookmark.eventId == eventId,
          );
        });
      }
    } catch (_) {
      // Bookmark state is helpful but should not block event detail rendering.
    }
  }

  @override
  Widget build(BuildContext context) {
    final event = _event;
    final canManage =
        event != null &&
        (widget.currentUserRole == 'admin' ||
            event.organizerId == widget.currentUserId);

    return Scaffold(
      body: switch ((_isLoading, _errorMessage, event)) {
        (true, _, _) => const Center(child: CircularProgressIndicator()),
        (false, final message?, _) => _EventErrorState(
          message: message,
          onRetry: _loadEvent,
        ),
        (false, _, final loadedEvent?) => _EventDetailContent(
          event: loadedEvent,
          isBookmarked: _isBookmarked,
          isBookmarkLoading: _isBookmarkLoading,
          canManage: canManage,
          onBack: () => Navigator.of(context).pop(),
          onInvite: () => _openInviteFriends(loadedEvent),
          onShare: () => _shareEvent(loadedEvent),
          onBookmark: () => _toggleBookmark(loadedEvent),
          onEdit: () => _openEditEvent(loadedEvent),
          onDelete: () => _confirmDelete(loadedEvent),
        ),
        _ => const SizedBox.shrink(),
      },
      bottomNavigationBar: event == null || _errorMessage != null || _isLoading
          ? null
          : _BookingBar(
              event: event,
              isBooking: _isBooking,
              onBook: () => _bookEvent(event),
            ),
    );
  }

  Future<void> _toggleBookmark(EventItem event) async {
    setState(() => _isBookmarkLoading = true);

    try {
      if (_isBookmarked) {
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

      if (mounted) {
        setState(() => _isBookmarked = !_isBookmarked);
      }
    } on ApiException catch (error) {
      setState(() => _errorMessage = error.message);
    } catch (_) {
      setState(() => _errorMessage = 'Unable to update bookmark');
    } finally {
      if (mounted) {
        setState(() => _isBookmarkLoading = false);
      }
    }
  }

  Future<void> _bookEvent(EventItem event) async {
    final quantity = await _pickQuantity();

    if (quantity == null) {
      return;
    }

    setState(() {
      _isBooking = true;
      _errorMessage = null;
    });

    try {
      await _bookingRepository.createBooking(
        authToken: widget.authToken,
        eventId: event.id,
        quantity: quantity,
      );

      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Booking confirmed')));
      }

      await _loadEvent();
    } on ApiException catch (error) {
      setState(() => _errorMessage = error.message);
    } catch (_) {
      setState(() => _errorMessage = 'Unable to book event');
    } finally {
      if (mounted) {
        setState(() => _isBooking = false);
      }
    }
  }

  Future<int?> _pickQuantity() {
    var quantity = 1;

    return showDialog<int>(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('Book ticket'),
              content: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton.outlined(
                    onPressed: quantity <= 1
                        ? null
                        : () => setDialogState(() => quantity--),
                    icon: const Icon(Icons.remove),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 18),
                    child: Text(
                      '$quantity',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                  ),
                  IconButton.outlined(
                    onPressed: quantity >= 10
                        ? null
                        : () => setDialogState(() => quantity++),
                    icon: const Icon(Icons.add),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Cancel'),
                ),
                FilledButton.icon(
                  onPressed: () => Navigator.of(context).pop(quantity),
                  icon: const Icon(Icons.confirmation_number_outlined),
                  label: const Text('Book'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _openInviteFriends(EventItem event) async {
    final invited = await showInviteFriendsSheet(
      context: context,
      authToken: widget.authToken,
      eventId: event.id,
    );

    if (invited == true && mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Invitations sent')));
    }
  }

  Future<void> _shareEvent(EventItem event) async {
    final text = [
      event.title,
      _formatDateTime(event.startAt),
      '${event.venueName}, ${event.address}',
      if (event.description.isNotEmpty) event.description,
    ].join('\n\n');

    try {
      await SharePlus.instance.share(
        ShareParams(text: text, subject: event.title),
      );
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Unable to open share sheet')),
        );
      }
    }
  }

  Future<void> _openEditEvent(EventItem event) async {
    final changed = await Navigator.of(context).push<bool>(
      MaterialPageRoute<bool>(
        builder: (_) => EventFormScreen(
          authToken: widget.authToken,
          event: event,
          eventRepository: _eventRepository,
        ),
      ),
    );

    if (changed == true && mounted) {
      Navigator.of(context).pop(true);
    }
  }

  Future<void> _confirmDelete(EventItem event) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Delete event?'),
          content: Text('This will permanently delete "${event.title}".'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            FilledButton.icon(
              onPressed: () => Navigator.of(context).pop(true),
              icon: const Icon(Icons.delete_outline),
              label: const Text('Delete'),
            ),
          ],
        );
      },
    );

    if (confirmed != true) {
      return;
    }

    try {
      await _eventRepository.deleteEvent(
        eventId: event.id,
        authToken: widget.authToken,
      );

      if (mounted) {
        Navigator.of(context).pop(true);
      }
    } on ApiException catch (error) {
      setState(() => _errorMessage = error.message);
    } catch (_) {
      setState(() => _errorMessage = 'Unable to delete event');
    }
  }
}

class _EventDetailContent extends StatelessWidget {
  const _EventDetailContent({
    required this.event,
    required this.isBookmarked,
    required this.isBookmarkLoading,
    required this.canManage,
    required this.onBack,
    required this.onInvite,
    required this.onShare,
    required this.onBookmark,
    required this.onEdit,
    required this.onDelete,
  });

  final EventItem event;
  final bool isBookmarked;
  final bool isBookmarkLoading;
  final bool canManage;
  final VoidCallback onBack;
  final VoidCallback onInvite;
  final VoidCallback onShare;
  final VoidCallback onBookmark;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: EdgeInsets.zero,
      children: [
        _DetailHero(
          event: event,
          isBookmarked: isBookmarked,
          isBookmarkLoading: isBookmarkLoading,
          onBack: onBack,
          onBookmark: onBookmark,
          onShare: onShare,
          onInvite: onInvite,
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 132),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                event.title,
                style: Theme.of(context).textTheme.displaySmall?.copyWith(
                  color: EventHubTheme.ink,
                  fontWeight: FontWeight.w800,
                  height: 1.12,
                ),
              ),
              const SizedBox(height: 24),
              _InfoRow(
                icon: Icons.calendar_month,
                title: _formatLongDate(event.startAt),
                subtitle: _formatTimeRange(event.startAt, event.endAt),
              ),
              const SizedBox(height: 18),
              _InfoRow(
                icon: Icons.location_on,
                title: event.venueName,
                subtitle: event.address,
              ),
              const SizedBox(height: 18),
              _OrganizerRow(event: event),
              const SizedBox(height: 30),
              Text(
                'About Event',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 12),
              Text(
                event.description,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: EventHubTheme.muted,
                  height: 1.58,
                ),
              ),
              const SizedBox(height: 26),
              Row(
                children: [
                  Expanded(
                    child: _MetricPill(
                      icon: Icons.confirmation_number_outlined,
                      label:
                          '${event.remainingTickets.clamp(0, event.capacity)} left',
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _MetricPill(
                      icon: event.isFree ? Icons.money_off : Icons.sell,
                      label: event.isFree
                          ? 'Free'
                          : '\$${event.price.toStringAsFixed(0)}',
                    ),
                  ),
                ],
              ),
              if (canManage) ...[
                const SizedBox(height: 18),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: onEdit,
                        icon: const Icon(Icons.edit),
                        label: const Text('Edit'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: onDelete,
                        icon: const Icon(Icons.delete_outline),
                        label: const Text('Delete'),
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _DetailHero extends StatelessWidget {
  const _DetailHero({
    required this.event,
    required this.isBookmarked,
    required this.isBookmarkLoading,
    required this.onBack,
    required this.onBookmark,
    required this.onShare,
    required this.onInvite,
  });

  final EventItem event;
  final bool isBookmarked;
  final bool isBookmarkLoading;
  final VoidCallback onBack;
  final VoidCallback onBookmark;
  final VoidCallback onShare;
  final VoidCallback onInvite;

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.paddingOf(context).top;

    return SizedBox(
      height: 398,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          EventImage(imageUrl: event.imageUrl, height: 342),
          Positioned.fill(
            bottom: 56,
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.18),
              ),
            ),
          ),
          Positioned(
            left: 16,
            right: 16,
            top: topPadding + 12,
            child: Row(
              children: [
                IconButton.filled(
                  tooltip: 'Back',
                  onPressed: onBack,
                  style: IconButton.styleFrom(
                    backgroundColor: Colors.black.withValues(alpha: 0.24),
                    foregroundColor: Colors.white,
                  ),
                  icon: const Icon(Icons.arrow_back),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Event Details',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
                IconButton.filled(
                  tooltip: 'Share',
                  onPressed: onShare,
                  style: IconButton.styleFrom(
                    backgroundColor: Colors.black.withValues(alpha: 0.24),
                    foregroundColor: Colors.white,
                  ),
                  icon: const Icon(Icons.ios_share),
                ),
                const SizedBox(width: 8),
                IconButton.filled(
                  tooltip: isBookmarked ? 'Remove bookmark' : 'Bookmark',
                  onPressed: isBookmarkLoading ? null : onBookmark,
                  style: IconButton.styleFrom(
                    backgroundColor: Colors.white.withValues(alpha: 0.25),
                    foregroundColor: Colors.white,
                  ),
                  icon: Icon(
                    isBookmarked ? Icons.bookmark : Icons.bookmark_border,
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            left: 32,
            right: 32,
            bottom: 0,
            child: _GoingPill(
              goingCount: event.bookedCount + 20,
              onInvite: event.status == 'published' ? onInvite : null,
            ),
          ),
        ],
      ),
    );
  }
}

class _GoingPill extends StatelessWidget {
  const _GoingPill({required this.goingCount, required this.onInvite});

  final int goingCount;
  final VoidCallback? onInvite;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      elevation: 14,
      shadowColor: const Color(0x1F6F73A8),
      borderRadius: BorderRadius.circular(36),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        child: Row(
          children: [
            const _HeroAvatar(color: Color(0xFFFF8BA7), label: 'A'),
            const _HeroAvatar(color: Color(0xFFFFC1A6), label: 'S'),
            const _HeroAvatar(color: Color(0xFF75C7F0), label: 'J'),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                '+$goingCount Going',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: EventHubTheme.primary,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
            FilledButton(
              onPressed: onInvite,
              style: FilledButton.styleFrom(
                minimumSize: const Size(94, 48),
                padding: const EdgeInsets.symmetric(horizontal: 18),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: const Text('Invite'),
            ),
          ],
        ),
      ),
    );
  }
}

class _HeroAvatar extends StatelessWidget {
  const _HeroAvatar({required this.color, required this.label});

  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Align(
      widthFactor: 0.7,
      child: CircleAvatar(
        radius: 23,
        backgroundColor: Colors.white,
        child: CircleAvatar(
          radius: 20,
          backgroundColor: color,
          child: Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 58,
          height: 58,
          decoration: BoxDecoration(
            color: EventHubTheme.softBlue,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Icon(icon, color: EventHubTheme.primary, size: 29),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: Theme.of(
                  context,
                ).textTheme.bodyLarge?.copyWith(color: EventHubTheme.muted),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _OrganizerRow extends StatelessWidget {
  const _OrganizerRow({required this.event});

  final EventItem event;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 58,
          height: 58,
          decoration: BoxDecoration(
            color: EventHubTheme.coral,
            borderRadius: BorderRadius.circular(16),
          ),
          child: const Icon(Icons.person, color: Colors.white, size: 30),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                event.organizerName ?? 'EventHub Organizer',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 4),
              Text(
                event.status,
                style: Theme.of(
                  context,
                ).textTheme.bodyLarge?.copyWith(color: EventHubTheme.muted),
              ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: EventHubTheme.softBlue,
            borderRadius: BorderRadius.circular(14),
          ),
          child: const Text(
            'Organizer',
            style: TextStyle(
              color: EventHubTheme.primary,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ],
    );
  }
}

class _MetricPill extends StatelessWidget {
  const _MetricPill({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFECEEFF)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: EventHubTheme.primary, size: 18),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: EventHubTheme.ink,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _BookingBar extends StatelessWidget {
  const _BookingBar({
    required this.event,
    required this.isBooking,
    required this.onBook,
  });

  final EventItem event;
  final bool isBooking;
  final VoidCallback onBook;

  @override
  Widget build(BuildContext context) {
    final canBook = event.status == 'published' && !isBooking;

    return SafeArea(
      minimum: const EdgeInsets.fromLTRB(24, 12, 24, 18),
      child: FilledButton(
        onPressed: canBook ? onBook : null,
        style: FilledButton.styleFrom(
          minimumSize: const Size.fromHeight(64),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              isBooking
                  ? 'BOOKING...'
                  : event.isFree
                  ? 'BOOK TICKET'
                  : 'BUY TICKET \$${event.price.toStringAsFixed(0)}',
            ),
            const SizedBox(width: 18),
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: EventHubTheme.primaryDark,
                borderRadius: BorderRadius.circular(22),
              ),
              child: const Icon(Icons.arrow_forward, color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }
}

class _EventErrorState extends StatelessWidget {
  const _EventErrorState({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.error_outline,
              size: 40,
              color: Theme.of(context).colorScheme.error,
            ),
            const SizedBox(height: 12),
            Text(message, textAlign: TextAlign.center),
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

String _formatDateTime(DateTime value) {
  final local = value.toLocal();
  final day = local.day.toString().padLeft(2, '0');
  final month = local.month.toString().padLeft(2, '0');
  final hour = local.hour.toString().padLeft(2, '0');
  final minute = local.minute.toString().padLeft(2, '0');

  return '$day/$month/${local.year} $hour:$minute';
}

String _formatLongDate(DateTime value) {
  final local = value.toLocal();

  return '${local.day} ${_monthName(local.month)}, ${local.year}';
}

String _formatTimeRange(DateTime start, DateTime end) {
  final localStart = start.toLocal();
  final localEnd = end.toLocal();

  return '${_weekdayName(localStart.weekday)}, ${_formatClock(localStart)} - ${_formatClock(localEnd)}';
}

String _formatClock(DateTime value) {
  final hour = value.hour.toString().padLeft(2, '0');
  final minute = value.minute.toString().padLeft(2, '0');

  return '$hour:$minute';
}

String _weekdayName(int weekday) {
  const weekdays = [
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
    'Sunday',
  ];

  return weekdays[weekday - 1];
}

String _monthName(int month) {
  const months = [
    'January',
    'February',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December',
  ];

  return months[month - 1];
}
