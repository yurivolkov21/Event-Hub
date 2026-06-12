class EventItem {
  const EventItem({
    required this.id,
    required this.title,
    required this.description,
    required this.categoryId,
    required this.organizerId,
    required this.startAt,
    required this.endAt,
    required this.venueName,
    required this.address,
    required this.price,
    required this.capacity,
    required this.bookedCount,
    required this.status,
    this.imageUrl,
    this.city,
    this.country,
    this.latitude,
    this.longitude,
  });

  final String id;
  final String title;
  final String description;
  final String categoryId;
  final String organizerId;
  final String? imageUrl;
  final DateTime startAt;
  final DateTime endAt;
  final String venueName;
  final String address;
  final String? city;
  final String? country;
  final double? latitude;
  final double? longitude;
  final double price;
  final int capacity;
  final int bookedCount;
  final String status;

  int get remainingTickets => capacity - bookedCount;
  bool get isFree => price == 0;

  factory EventItem.fromJson(Map<String, dynamic> json) {
    return EventItem(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      categoryId: json['categoryId'] as String,
      organizerId: json['organizerId'] as String,
      imageUrl: json['imageUrl'] as String?,
      startAt: DateTime.parse(json['startAt'] as String),
      endAt: DateTime.parse(json['endAt'] as String),
      venueName: json['venueName'] as String,
      address: json['address'] as String,
      city: json['city'] as String?,
      country: json['country'] as String?,
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
      price: (json['price'] as num).toDouble(),
      capacity: (json['capacity'] as num).toInt(),
      bookedCount: (json['bookedCount'] as num).toInt(),
      status: json['status'] as String,
    );
  }
}

class EventCategoryOption {
  const EventCategoryOption({required this.id, required this.name});

  final String id;
  final String name;
}

const eventCategoryOptions = [
  EventCategoryOption(id: '650000000000000000000001', name: 'Sports'),
  EventCategoryOption(id: '650000000000000000000002', name: 'Music'),
  EventCategoryOption(id: '650000000000000000000003', name: 'Food'),
  EventCategoryOption(id: '650000000000000000000004', name: 'Art'),
  EventCategoryOption(id: '650000000000000000000005', name: 'Movie'),
  EventCategoryOption(id: '650000000000000000000006', name: 'Concert'),
  EventCategoryOption(id: '650000000000000000000007', name: 'Games Online'),
  EventCategoryOption(id: '650000000000000000000008', name: 'Others'),
];

class EventFormInput {
  const EventFormInput({
    required this.title,
    required this.description,
    required this.categoryId,
    required this.startAt,
    required this.endAt,
    required this.venueName,
    required this.address,
    required this.price,
    required this.capacity,
    required this.status,
    this.city,
    this.country,
  });

  final String title;
  final String description;
  final String categoryId;
  final DateTime startAt;
  final DateTime endAt;
  final String venueName;
  final String address;
  final String? city;
  final String? country;
  final double price;
  final int capacity;
  final String status;

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'description': description,
      'categoryId': categoryId,
      'startAt': startAt.toUtc().toIso8601String(),
      'endAt': endAt.toUtc().toIso8601String(),
      'venueName': venueName,
      'address': address,
      'city': city,
      'country': country,
      'price': price,
      'capacity': capacity,
      'status': status,
    };
  }
}

class EventPagination {
  const EventPagination({
    required this.page,
    required this.limit,
    required this.total,
    required this.totalPages,
  });

  final int page;
  final int limit;
  final int total;
  final int totalPages;

  factory EventPagination.fromJson(Map<String, dynamic> json) {
    return EventPagination(
      page: (json['page'] as num).toInt(),
      limit: (json['limit'] as num).toInt(),
      total: (json['total'] as num).toInt(),
      totalPages: (json['totalPages'] as num).toInt(),
    );
  }
}

class PaginatedEvents {
  const PaginatedEvents({required this.data, required this.pagination});

  final List<EventItem> data;
  final EventPagination pagination;

  factory PaginatedEvents.fromJson(Map<String, dynamic> json) {
    return PaginatedEvents(
      data: (json['data'] as List<dynamic>)
          .map(
            (eventJson) =>
                EventItem.fromJson(eventJson as Map<String, dynamic>),
          )
          .toList(),
      pagination: EventPagination.fromJson(
        json['pagination'] as Map<String, dynamic>,
      ),
    );
  }
}
