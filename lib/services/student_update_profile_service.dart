import 'dart:convert';
import 'package:get/get_connect.dart';
import 'package:http/http.dart' as http;
import 'package:urbantutorsapp/models/profile_update_response_model.dart';
import 'package:urbantutorsapp/models/student_update_profile_model.dart';
import 'package:urbantutorsapp/services/ApiService.dart';
import 'package:urbantutorsapp/utils/api_constants.dart';

class StudentProfileService {
  Future<StudentProfileResponse> fetchProfile() async {
    try {
      final response = await ApiService.post(
        ApiConstants.STUDENT_PROFILE_UPDATE,
        null, // no body for fetching
      );

      print("✅ Response from getProfileUpdate: ${response.data}");

      return StudentProfileResponse.fromJson(response.data);
    } catch (e) {
      print("❌ Error in getProfileUpdate (from ProfileUpdateService):");
      print(e.toString());
      throw e;
    }
  }

  Future<StudentProfileResponse> updateStudentProfile(
      StudentProfileUpdateRequest data) async {
    print(data.toJson());
    print("coming from student update profile service");
    try {
      final response = await ApiService.post(
          ApiConstants.STUDENT_PROFILE_UPDATE, data.toJson()
          //  data, // no body for fetching
          );

      print("✅ Response from getProfileUpdate: ${response.data}");

      return StudentProfileResponse.fromJson(response.data);
    } catch (e) {
      print("❌ Error in getProfileUpdate (from ProfileUpdateService):");
      print(e.toString());
      throw e;
    }
  }

  /// Update Student Profile
}
