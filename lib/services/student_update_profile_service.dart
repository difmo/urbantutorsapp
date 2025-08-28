import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:urbantutorsapp/models/student_update_profile_model.dart';

class StudentProfileService {
  final String baseUrl = "STUDENT_PROFILE_UPDATE"; // Replace with your actual API base URL

  /// Fetch Student Profile
  Future<StudentProfileResponse> fetchStudentProfile(int userId) async {
    try {
      final response = await http.get(
        Uri.parse("$baseUrl/student-profile/$userId"),
        headers: {
          "Accept": "application/json",
          "Content-Type": "application/json",
        },
      );

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        return StudentProfileResponse.fromJson(jsonData);
      } else {
        throw Exception("Failed to load profile. Code: ${response.statusCode}");
      }
    } catch (e) {
      throw Exception("Error fetching profile: $e");
    }
  }

  /// Update Student Profile
  Future<StudentProfileResponse> updateStudentProfile(
   Map<String, dynamic> updateData) async {
    try {
      final response = await http.post(
        Uri.parse("$baseUrl/student-profile/update"),
        headers: {
          "Accept": "application/json",
          "Content-Type": "application/json",
        },
        body: json.encode(updateData),
      );

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        return StudentProfileResponse.fromJson(jsonData);
      } else {
        throw Exception("Failed to update profile. Code: ${response.statusCode}");
      }
    } catch (e) {
      throw Exception("Error updating profile: $e");
    }
  }
}
