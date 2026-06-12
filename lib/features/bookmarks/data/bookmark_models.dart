class BookmarkItem {
  const BookmarkItem({
    required this.id,
    required this.userId,
    required this.eventId,
    this.createdAt,
  });

  final String id;
  final String userId;
  final String eventId;
  final DateTime? createdAt;

  factory BookmarkItem.fromJson(Map<String, dynamic> json) {
    return BookmarkItem(
      id: json['id'] as String,
      userId: json['userId'] as String,
      eventId: json['eventId'] as String,
      createdAt: DateTime.tryParse(json['createdAt'] as String? ?? ''),
    );
  }
}

class PaginatedBookmarks {
  const PaginatedBookmarks({required this.data});

  final List<BookmarkItem> data;

  factory PaginatedBookmarks.fromJson(Map<String, dynamic> json) {
    return PaginatedBookmarks(
      data: (json['data'] as List<dynamic>)
          .map(
            (bookmarkJson) =>
                BookmarkItem.fromJson(bookmarkJson as Map<String, dynamic>),
          )
          .toList(),
    );
  }
}
