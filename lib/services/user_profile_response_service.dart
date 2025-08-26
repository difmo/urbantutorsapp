import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/user_profile_response_model.dart'; // <-- your model

class UserProfileResponseService {
  final String baseUrl = "USER_PROFIEL_FETCH"; // replace with actual endpoint

  /// Fetch profile (GET)
  Future<UserProfileResponseModel?> fetchProfile() async {
    try {
      final response = await http.get(
        Uri.parse(baseUrl),
        headers: {
          "Content-Type": "application/json",
          "Accept": "application/json",
          // "Authorization": "Bearer YOUR_TOKEN", // uncomment if auth required
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return UserProfileResponseModel.fromJson(data);
      } else {
        print("❌ Error: ${response.statusCode} - ${response.body}");
        return null;
      }
    } catch (e) {
      print("❌ Exception in fetchProfile: $e");
      return null;
    }
  }

  /// Update profile (PUT/POST depending on backend)
  Future<UserProfileResponseModel?> updateProfile(
      Map<String, dynamic> updateData) async {
    try {
      final response = await http.put(
        Uri.parse(baseUrl),
        headers: {
          "Content-Type": "application/json",
          "Accept": "application/json",
          // "Authorization": "Bearer YOUR_TOKEN",
        },
        body: jsonEncode(updateData),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return UserProfileResponseModel.fromJson(data);
      } else {
        print("❌ Error: ${response.statusCode} - ${response.body}");
        return null;
      }
    } catch (e) {
      print("❌ Exception in updateProfile: $e");
      return null;
    }
  }
}
