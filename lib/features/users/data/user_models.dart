class UserSummary {
  const UserSummary({
    required this.id,
    required this.fullName,
    required this.email,
    required this.role,
    this.avatarUrl,
  });

  final String id;
  final String fullName;
  final String email;
  final String role;
  final String? avatarUrl;

  factory UserSummary.fromJson(Map<String, dynamic> json) {
    return UserSummary(
      id: json['id'] as String,
      fullName: json['fullName'] as String,
      email: json['email'] as String,
      role: json['role'] as String,
      avatarUrl: json['avatarUrl'] as String?,
    );
  }
}

class UserListResponse {
  const UserListResponse({required this.data});

  final List<UserSummary> data;

  factory UserListResponse.fromJson(Map<String, dynamic> json) {
    return UserListResponse(
      data: (json['data'] as List<dynamic>)
          .map(
            (userJson) =>
                UserSummary.fromJson(userJson as Map<String, dynamic>),
          )
          .toList(),
    );
  }
}
