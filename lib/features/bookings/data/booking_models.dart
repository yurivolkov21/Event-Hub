class BookingItem {
  const BookingItem({
    required this.id,
    required this.userId,
    required this.eventId,
    required this.quantity,
    required this.totalPrice,
    required this.status,
    this.eventTitle,
    this.eventImageUrl,
    this.eventStartAt,
    this.eventVenueName,
    this.createdAt,
    this.updatedAt,
  });

  final String id;
  final String userId;
  final String eventId;
  final int quantity;
  final double totalPrice;
  final String status;
  final String? eventTitle;
  final String? eventImageUrl;
  final DateTime? eventStartAt;
  final String? eventVenueName;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  factory BookingItem.fromJson(Map<String, dynamic> json) {
    final eventJson = json['event'] as Map<String, dynamic>?;

    return BookingItem(
      id: json['id'] as String,
      userId: json['userId'] as String,
      eventId: json['eventId'] as String,
      quantity: (json['quantity'] as num).toInt(),
      totalPrice: (json['totalPrice'] as num).toDouble(),
      status: json['status'] as String,
      eventTitle: eventJson?['title'] as String?,
      eventImageUrl: eventJson?['imageUrl'] as String?,
      eventStartAt: DateTime.tryParse(eventJson?['startAt'] as String? ?? ''),
      eventVenueName: eventJson?['venueName'] as String?,
      createdAt: DateTime.tryParse(json['createdAt'] as String? ?? ''),
      updatedAt: DateTime.tryParse(json['updatedAt'] as String? ?? ''),
    );
  }
}

class PaginatedBookings {
  const PaginatedBookings({required this.data});

  final List<BookingItem> data;

  factory PaginatedBookings.fromJson(Map<String, dynamic> json) {
    return PaginatedBookings(
      data: (json['data'] as List<dynamic>)
          .map(
            (bookingJson) =>
                BookingItem.fromJson(bookingJson as Map<String, dynamic>),
          )
          .toList(),
    );
  }
}
