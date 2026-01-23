import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import '../config/app_config.dart';
import '../models/user_model.dart';

class ApiService {
  static const String baseUrl = AppConfig.apiBaseUrl;
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
}
