import 'package:flutter/material.dart';

import '../../../core/networking/api_client.dart';
import '../data/booking_models.dart';
import '../data/booking_repository.dart';

class MyTicketsScreen extends StatefulWidget {
  const MyTicketsScreen({
    required this.authToken,
    this.bookingRepository,
    super.key,
  });

  final String authToken;
  final BookingRepository? bookingRepository;

  @override
  State<MyTicketsScreen> createState() => _MyTicketsScreenState();
}

class _MyTicketsScreenState extends State<MyTicketsScreen> {
  late final BookingRepository _bookingRepository;
  List<BookingItem> _bookings = [];
  String? _errorMessage;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _bookingRepository = widget.bookingRepository ?? BookingRepository();
    _loadBookings();
  }

  Future<void> _loadBookings() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final bookings = await _bookingRepository.listMyBookings(
        authToken: widget.authToken,
      );
      setState(() => _bookings = bookings);
    } on ApiException catch (error) {
      setState(() => _errorMessage = error.message);
    } catch (_) {
      setState(() => _errorMessage = 'Unable to load tickets');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _cancelBooking(BookingItem booking) async {
    try {
      await _bookingRepository.cancelBooking(
        authToken: widget.authToken,
        bookingId: booking.id,
      );
      await _loadBookings();
    } on ApiException catch (error) {
      setState(() => _errorMessage = error.message);
    } catch (_) {
      setState(() => _errorMessage = 'Unable to cancel booking');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('My Tickets')),
      body: RefreshIndicator(
        onRefresh: _loadBookings,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            if (_isLoading)
              const Padding(
                padding: EdgeInsets.only(top: 96),
                child: Center(child: CircularProgressIndicator()),
              )
            else if (_errorMessage != null)
              _TicketMessage(
                icon: Icons.error_outline,
                message: _errorMessage!,
                onRetry: _loadBookings,
              )
            else if (_bookings.isEmpty)
              _TicketMessage(
                icon: Icons.confirmation_number_outlined,
                message: 'No tickets yet',
                onRetry: _loadBookings,
              )
            else
              ..._bookings.map(
                (booking) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _TicketCard(
                    booking: booking,
                    onCancel: booking.status == 'cancelled'
                        ? null
                        : () => _cancelBooking(booking),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _TicketCard extends StatelessWidget {
  const _TicketCard({required this.booking, required this.onCancel});

  final BookingItem booking;
  final VoidCallback? onCancel;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.confirmation_number, color: colorScheme.primary),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    booking.eventTitle ?? 'Event ${booking.eventId}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text('Quantity: ${booking.quantity}'),
            Text('Total: \$${booking.totalPrice.toStringAsFixed(0)}'),
            Text('Status: ${booking.status}'),
            if (onCancel != null) ...[
              const SizedBox(height: 10),
              OutlinedButton.icon(
                onPressed: onCancel,
                icon: const Icon(Icons.close),
                label: const Text('Cancel booking'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _TicketMessage extends StatelessWidget {
  const _TicketMessage({
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
      padding: const EdgeInsets.only(top: 96),
      child: Center(
        child: Column(
          children: [
            Icon(
              icon,
              size: 40,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            const SizedBox(height: 12),
            Text(message),
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
