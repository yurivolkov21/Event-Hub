import 'package:flutter/material.dart';

import '../../../core/networking/api_client.dart';
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
  EventItem? _event;
  String? _errorMessage;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _eventRepository = widget.eventRepository ?? EventRepository();
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
        ),
        _ => const SizedBox.shrink(),
      },
    );
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
  const _EventDetailContent({required this.event});

  final EventItem event;

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
