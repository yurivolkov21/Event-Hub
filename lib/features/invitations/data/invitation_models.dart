class InvitationItem {
  const InvitationItem({
    required this.id,
    required this.eventId,
    required this.fromUserId,
    required this.toUserId,
    required this.status,
    this.createdAt,
    this.updatedAt,
    this.eventTitle,
    this.eventImageUrl,
    this.eventStartAt,
    this.eventVenueName,
    this.fromUserName,
  });

  final String id;
  final String eventId;
  final String fromUserId;
  final String toUserId;
  final String status; // pending | accepted | rejected
  final DateTime? createdAt;
  final DateTime? updatedAt;

  // Enriched fields present on the inbox listing.
  final String? eventTitle;
  final String? eventImageUrl;
  final DateTime? eventStartAt;
  final String? eventVenueName;
  final String? fromUserName;

  bool get isPending => status == 'pending';

  factory InvitationItem.fromJson(Map<String, dynamic> json) {
    return InvitationItem(
      id: json['id'] as String,
      eventId: json['eventId'] as String,
      fromUserId: json['fromUserId'] as String,
      toUserId: json['toUserId'] as String,
      status: json['status'] as String,
      createdAt: DateTime.tryParse(json['createdAt'] as String? ?? ''),
      updatedAt: DateTime.tryParse(json['updatedAt'] as String? ?? ''),
      eventTitle: json['eventTitle'] as String?,
      eventImageUrl: json['eventImageUrl'] as String?,
      eventStartAt: DateTime.tryParse(json['eventStartAt'] as String? ?? ''),
      eventVenueName: json['eventVenueName'] as String?,
      fromUserName: json['fromUserName'] as String?,
    );
  }

  InvitationItem copyWith({String? status}) {
    return InvitationItem(
      id: id,
      eventId: eventId,
      fromUserId: fromUserId,
      toUserId: toUserId,
      status: status ?? this.status,
      createdAt: createdAt,
      updatedAt: updatedAt,
      eventTitle: eventTitle,
      eventImageUrl: eventImageUrl,
      eventStartAt: eventStartAt,
      eventVenueName: eventVenueName,
      fromUserName: fromUserName,
    );
  }
}

class PaginatedInvitations {
  const PaginatedInvitations({required this.data});

  final List<InvitationItem> data;

  factory PaginatedInvitations.fromJson(Map<String, dynamic> json) {
    return PaginatedInvitations(
      data: (json['data'] as List<dynamic>)
          .map(
            (item) => InvitationItem.fromJson(item as Map<String, dynamic>),
          )
          .toList(),
    );
  }
}
