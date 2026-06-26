import 'package:flutter/material.dart';

import '../../../core/networking/api_client.dart';
import '../../../core/theme/eventhub_theme.dart';
import '../../../core/widgets/empty_state.dart';
import '../data/event_models.dart';
import '../data/event_repository.dart';
import 'event_detail_screen.dart';
import 'event_image.dart';

/// Full vertical listing of events ("See All Events" in the Figma), reached
/// from the "See All" actions on the Home/Explore screen.
class AllEventsScreen extends StatefulWidget {
  const AllEventsScreen({
    required this.authToken,
    required this.currentUserId,
    required this.currentUserRole,
    this.eventRepository,
    super.key,
  });

  final String authToken;
  final String currentUserId;
  final String currentUserRole;
  final EventRepository? eventRepository;

  @override
  State<AllEventsScreen> createState() => _AllEventsScreenState();
}

class _AllEventsScreenState extends State<AllEventsScreen> {
  late final EventRepository _eventRepository;
  final _searchController = TextEditingController();

  List<EventItem> _events = [];
  String? _errorMessage;
  bool _isLoading = true;
  bool _isSearchVisible = false;

  @override
  void initState() {
    super.initState();
    _eventRepository = widget.eventRepository ?? EventRepository();
    _loadEvents();
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
        limit: 50,
      );
      if (!mounted) return;
      setState(() => _events = response.data);
    } on ApiException catch (error) {
      if (!mounted) return;
      setState(() => _errorMessage = error.message);
    } catch (_) {
      if (!mounted) return;
      setState(() => _errorMessage = 'Unable to load events');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _toggleSearch() {
    setState(() {
      _isSearchVisible = !_isSearchVisible;
      if (!_isSearchVisible && _searchController.text.isNotEmpty) {
        _searchController.clear();
        _loadEvents();
      }
    });
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Events'),
        actions: [
          IconButton(
            tooltip: 'Search',
            onPressed: _toggleSearch,
            icon: Icon(_isSearchVisible ? Icons.close : Icons.search),
          ),
        ],
      ),
      body: Column(
        children: [
          if (_isSearchVisible)
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 4, 20, 12),
              child: TextField(
                controller: _searchController,
                autofocus: true,
                textInputAction: TextInputAction.search,
                onSubmitted: (_) => _loadEvents(),
                decoration: InputDecoration(
                  hintText: 'Search events...',
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: IconButton(
                    tooltip: 'Search',
                    onPressed: _loadEvents,
                    icon: const Icon(Icons.arrow_forward),
                  ),
                ),
              ),
            ),
          Expanded(
            child: RefreshIndicator(
              onRefresh: _loadEvents,
              child: _buildBody(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage != null) {
      return ListView(
        children: [
          const SizedBox(height: 120),
          Center(
            child: Column(
              children: [
                const Icon(
                  Icons.error_outline,
                  size: 42,
                  color: EventHubTheme.primary,
                ),
                const SizedBox(height: 12),
                Text(_errorMessage!),
                const SizedBox(height: 16),
                OutlinedButton.icon(
                  onPressed: _loadEvents,
                  icon: const Icon(Icons.refresh),
                  label: const Text('Retry'),
                ),
              ],
            ),
          ),
        ],
      );
    }

    if (_events.isEmpty) {
      return ListView(
        children: const [
          SizedBox(height: 40),
          EmptyState(
            icon: Icons.event_busy,
            title: 'No Upcoming Event',
            message:
                'No events match your search. Try a different keyword or refresh.',
          ),
        ],
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(20),
      itemCount: _events.length,
      separatorBuilder: (_, _) => const SizedBox(height: 14),
      itemBuilder: (context, index) {
        final event = _events[index];

        return _AllEventsRow(event: event, onTap: () => _openEvent(event));
      },
    );
  }
}

class _AllEventsRow extends StatelessWidget {
  const _AllEventsRow({required this.event, required this.onTap});

  final EventItem event;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      elevation: 6,
      shadowColor: const Color(0x106F73A8),
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: SizedBox(
                  width: 84,
                  height: 84,
                  child: EventImage(imageUrl: event.imageUrl, height: 84),
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
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      event.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        const Icon(
                          Icons.location_on,
                          color: EventHubTheme.muted,
                          size: 15,
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            '${event.venueName} · ${event.address}',
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
            ],
          ),
        ),
      ),
    );
  }
}

String _formatDateTime(DateTime value) {
  final local = value.toLocal();
  const weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
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
  final weekday = weekdays[local.weekday - 1];
  final month = months[local.month - 1];
  final hour = local.hour.toString().padLeft(2, '0');
  final minute = local.minute.toString().padLeft(2, '0');

  return '$weekday, $month ${local.day} · $hour:$minute';
}
