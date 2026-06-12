class NotificationItem {
  const NotificationItem({
    required this.id,
    required this.userId,
    required this.type,
    required this.title,
    required this.body,
    required this.data,
    required this.readAt,
    this.createdAt,
  });

  final String id;
  final String userId;
  final String type;
  final String title;
  final String body;
  final Map<String, String> data;
  final DateTime? readAt;
  final DateTime? createdAt;

  bool get isRead => readAt != null;

  factory NotificationItem.fromJson(Map<String, dynamic> json) {
    final rawData = json['data'];

    return NotificationItem(
      id: json['id'] as String,
      userId: json['userId'] as String,
      type: json['type'] as String,
      title: json['title'] as String,
      body: json['body'] as String,
      data: rawData is Map
          ? rawData.map(
              (key, value) => MapEntry(key.toString(), value.toString()),
            )
          : {},
      readAt: DateTime.tryParse(json['readAt'] as String? ?? ''),
      createdAt: DateTime.tryParse(json['createdAt'] as String? ?? ''),
    );
  }
}

class PaginatedNotifications {
  const PaginatedNotifications({required this.data});

  final List<NotificationItem> data;

  factory PaginatedNotifications.fromJson(Map<String, dynamic> json) {
    return PaginatedNotifications(
      data: (json['data'] as List<dynamic>)
          .map(
            (notificationJson) => NotificationItem.fromJson(
              notificationJson as Map<String, dynamic>,
            ),
          )
          .toList(),
    );
  }
}
