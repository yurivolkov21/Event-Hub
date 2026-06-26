class ReviewItem {
  const ReviewItem({
    required this.id,
    required this.rating,
    required this.comment,
    this.userName,
    this.userAvatar,
    this.createdAt,
  });

  final String id;
  final int rating;
  final String comment;
  final String? userName;
  final String? userAvatar;
  final DateTime? createdAt;

  factory ReviewItem.fromJson(Map<String, dynamic> json) {
    return ReviewItem(
      id: json['id'] as String,
      rating: (json['rating'] as num).toInt(),
      comment: (json['comment'] as String?) ?? '',
      userName: json['userName'] as String?,
      userAvatar: json['userAvatar'] as String?,
      createdAt: DateTime.tryParse(json['createdAt'] as String? ?? ''),
    );
  }
}
