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

class UserProfile {
  const UserProfile({
    required this.id,
    required this.fullName,
    required this.email,
    required this.role,
    this.avatarUrl,
    this.phone,
    this.bio,
    this.interests = const [],
  });

  final String id;
  final String fullName;
  final String email;
  final String role;
  final String? avatarUrl;
  final String? phone;
  final String? bio;
  final List<String> interests;

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id'] as String,
      fullName: json['fullName'] as String,
      email: json['email'] as String,
      role: json['role'] as String,
      avatarUrl: json['avatarUrl'] as String?,
      phone: json['phone'] as String?,
      bio: json['bio'] as String?,
      interests:
          (json['interests'] as List<dynamic>?)
              ?.map((value) => value as String)
              .toList() ??
          const [],
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
