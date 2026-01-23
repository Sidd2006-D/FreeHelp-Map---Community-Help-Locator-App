class AppUser {
  final String uid;
  final String email;
  final String name;
  final double trustScore;
  final String? profileImage;

  AppUser({
    required this.uid,
    required this.email,
    required this.name,
    required this.trustScore,
    this.profileImage,
  });

  factory AppUser.fromJson(Map<String, dynamic> json) {
    return AppUser(
      uid: json['uid'],
      email: json['email'] ?? '',
      name: json['name'] ?? '',
      trustScore: (json['trust_score'] ?? 0).toDouble(),
      profileImage: json['profile_image'],
    );
  }
}
