class UserProfile {
  const UserProfile({
    required this.id,
    required this.username,
    this.displayName,
    this.nickname,
    this.pronouns,
    this.bio,
    this.avatarUrl,
    this.favoriteDrinkIds = const [],
    this.onboardingCompleted = true,
  });

  final String id;
  final String username;
  final String? displayName;
  final String? nickname;
  final String? pronouns;
  final String? bio;
  final String? avatarUrl;
  final List<String> favoriteDrinkIds;
  final bool onboardingCompleted;

  String get presentationName => displayName?.isNotEmpty == true ? displayName! : username;

  factory UserProfile.fromJson(Map<String, dynamic> json) => UserProfile(
        id: json['id'] as String,
        username: json['username'] as String,
        displayName: json['display_name'] as String?,
        nickname: json['nickname'] as String?,
        pronouns: json['pronouns'] as String?,
        bio: json['bio'] as String?,
        avatarUrl: json['avatar_url'] as String?,
        favoriteDrinkIds: ((json['favorite_drink_ids'] as List?)
                ?.map((e) => e as String)
                .toList()) ??
            [],
        onboardingCompleted: json['onboarding_completed'] as bool? ?? true,
      );
}
