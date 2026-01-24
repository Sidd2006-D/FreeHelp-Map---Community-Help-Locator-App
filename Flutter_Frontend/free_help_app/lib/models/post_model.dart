class HelpPost {
  final int id;
  final String postType;
  final String title;
  final String description;
  final double latitude;
  final double longitude;
  final int radius;
  final List<String> images; // image URLs

  HelpPost({
    required this.id,
    required this.postType,
    required this.title,
    required this.description,
    required this.latitude,
    required this.longitude,
    required this.radius,
    required this.images,
  });

  factory HelpPost.fromJson(Map<String, dynamic> json) {
    return HelpPost(
      id: json['id'],
      postType: json['post_type'],
      title: json['title'],
      description: json['description'],
      latitude: json['latitude'],
      longitude: json['longitude'],
      radius: json['visibility_radius_km'],
      images:
          (json['images'] as List?)
              ?.map((img) => img['image'] as String)
              .toList() ??
          [],
    );
  }
}
