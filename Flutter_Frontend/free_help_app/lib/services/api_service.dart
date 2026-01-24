import 'dart:convert';
import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;

import '../config/app_config.dart';
import '../models/user_model.dart';

class ApiService {
  static const String baseUrl = AppConfig.apiBaseUrl;

  // ===========================
  // 👤 USER PROFILE
  // ===========================
  static Future<AppUser> fetchCurrentUser() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      throw Exception("User not authenticated");
    }

    final token = await user.getIdToken(true);

    final response = await http.get(
      Uri.parse("$baseUrl/users/me/"),
      headers: {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json",
      },
    );

    if (response.statusCode == 200) {
      return AppUser.fromJson(jsonDecode(response.body));
    } else {
      throw Exception("Failed to load user profile");
    }
  }

  // ===========================
  // 📝 CREATE HELP / FOOD / EVENT POST (WITH IMAGES)
  // ===========================
  static Future<void> createPost({
    required String postType,
    required String title,
    required String description,
    required double latitude,
    required double longitude,
    required int radius,
    required List<File> images,
    required bool isActive,
    DateTime? eventTime,
  }) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      throw Exception("User not authenticated");
    }

    final token = await user.getIdToken(true);

    final request = http.MultipartRequest(
      "POST",
      Uri.parse("$baseUrl/posts/create/"),
    );

    request.headers["Authorization"] = "Bearer $token";

    request.fields.addAll({
      "post_type": postType,
      "title": title,
      "description": description,
      "latitude": latitude.toString(),
      "longitude": longitude.toString(),
      "visibility_radius_km": radius.toString(),
      
    });

    request.fields["is_active"] = isActive.toString().toLowerCase();

    if (!isActive && eventTime != null) {
      request.fields["event_time"] = eventTime.toIso8601String();
    }


    // Add up to 3 images
    for (final image in images.take(3)) {
      request.files.add(
        await http.MultipartFile.fromPath("images", image.path),
      );
    }

    final response = await request.send();

    if (response.statusCode != 201) {
      throw Exception("Failed to create post");
    }
  }
}
