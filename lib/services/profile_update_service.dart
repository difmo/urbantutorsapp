import 'package:dio/dio.dart';
import 'package:urbantutorsapp/models/profile_update_request_model.dart';
import 'package:urbantutorsapp/models/profile_update_response_model.dart';
import 'package:urbantutorsapp/services/ApiService.dart';
import 'package:urbantutorsapp/utils/api_constants.dart';

class ProfileUpdateService {
  /// ✅ Fetch profile (GET/POST depending on API design)
  Future<UserProfileResponse> getProfileUpdate() async {
    try {
      final response = await ApiService.post(
        ApiConstants.PROFILE_UPDATE,
        null, // no body for fetching
      );

      print("✅ Response from getProfileUpdate: ${response.data}");

      return UserProfileResponse.fromJson(response.data);
    } catch (e) {
      print("❌ Error in getProfileUpdate (from ProfileUpdateService):");
      print(e.toString());
      throw e;
    }
  }

  /// ✅ Update profile (send data as FormData or JSON depending on API)
  Future<UserProfileResponse> updateProfile(ProfileUpdateRequest updateData) async {
    try {

      final response = await ApiService.post(
        ApiConstants.PROFILE_UPDATE,
        updateData.toJson(),
      );

      print("✅ Response from updateProfile: ${response.data}");

      return UserProfileResponse.fromJson(response.data);
    } catch (e) {
      print("❌ Error in updateProfile (from ProfileUpdateService):");
      print(e.toString());
      throw e;
    }
  }
}
