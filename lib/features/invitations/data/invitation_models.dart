class InvitationItem {
  const InvitationItem({
    required this.id,
    required this.eventId,
    required this.fromUserId,
    required this.toUserId,
    required this.status,
    this.createdAt,
    this.updatedAt,
  });

  final String id;
  final String eventId;
  final String fromUserId;
  final String toUserId;
  final String status;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  factory InvitationItem.fromJson(Map<String, dynamic> json) {
    return InvitationItem(
      id: json['id'] as String,
      eventId: json['eventId'] as String,
      fromUserId: json['fromUserId'] as String,
      toUserId: json['toUserId'] as String,
      status: json['status'] as String,
      createdAt: DateTime.tryParse(json['createdAt'] as String? ?? ''),
      updatedAt: DateTime.tryParse(json['updatedAt'] as String? ?? ''),
    );
  }
}
