import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';

import '../../../core/networking/api_client.dart';
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
      appBar: AppBar(
        title: Text(event?.title ?? 'Event'),
        actions: [
          if (canManage) ...[
            IconButton(
              tooltip: 'Edit',
              onPressed: () => _openEditEvent(event),
              icon: const Icon(Icons.edit),
            ),
            IconButton(
              tooltip: 'Delete',
              onPressed: () => _confirmDelete(event),
              icon: const Icon(Icons.delete_outline),
            ),
          ],
          if (event != null)
            IconButton(
              tooltip: _isBookmarked ? 'Remove bookmark' : 'Bookmark',
              onPressed: _isBookmarkLoading
                  ? null
                  : () => _toggleBookmark(event),
              icon: Icon(
                _isBookmarked ? Icons.bookmark : Icons.bookmark_border,
              ),
            ),
        ],
      ),
      body: switch ((_isLoading, _errorMessage, event)) {
        (true, _, _) => const Center(child: CircularProgressIndicator()),
        (false, final message?, _) => _EventErrorState(
          message: message,
          onRetry: _loadEvent,
        ),
        (false, _, final loadedEvent?) => _EventDetailContent(
          event: loadedEvent,
          isBooking: _isBooking,
          onBook: () => _bookEvent(loadedEvent),
          onInvite: () => _openInviteFriends(loadedEvent),
          onShare: () => _shareEvent(loadedEvent),
        ),
        _ => const SizedBox.shrink(),
      },
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
    required this.isBooking,
    required this.onBook,
    required this.onInvite,
    required this.onShare,
  });

  final EventItem event;
  final bool isBooking;
  final VoidCallback onBook;
  final VoidCallback onInvite;
  final VoidCallback onShare;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return ListView(
      padding: EdgeInsets.zero,
      children: [
        EventImage(imageUrl: event.imageUrl, height: 260),
        Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Chip(
                    label: Text(
                      event.isFree
                          ? 'Free'
                          : '\$${event.price.toStringAsFixed(0)}',
                    ),
                  ),
                  const SizedBox(width: 8),
                  Chip(label: Text(event.status)),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                event.title,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 16),
              _DetailRow(
                icon: Icons.schedule,
                label: _formatDateTime(event.startAt),
              ),
              const SizedBox(height: 10),
              _DetailRow(
                icon: Icons.location_on_outlined,
                label: '${event.venueName}, ${event.address}',
              ),
              const SizedBox(height: 10),
              _DetailRow(
                icon: Icons.confirmation_number_outlined,
                label:
                    '${event.remainingTickets.clamp(0, event.capacity)} tickets left',
              ),
              const SizedBox(height: 24),
              Divider(color: colorScheme.outlineVariant),
              const SizedBox(height: 20),
              Text(
                event.description,
                style: Theme.of(
                  context,
                ).textTheme.bodyLarge?.copyWith(height: 1.45),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: event.status == 'published' ? onInvite : null,
                      icon: const Icon(Icons.person_add_alt_1),
                      label: const Text('Invite'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: onShare,
                      icon: const Icon(Icons.ios_share),
                      label: const Text('Share'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: isBooking || event.status != 'published'
                      ? null
                      : onBook,
                  icon: const Icon(Icons.confirmation_number_outlined),
                  label: Text(isBooking ? 'Booking...' : 'Book Ticket'),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: Theme.of(context).colorScheme.primary),
        const SizedBox(width: 10),
        Expanded(child: Text(label)),
      ],
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
