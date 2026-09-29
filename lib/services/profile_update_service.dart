import 'package:urbantutorsapp/models/profile_modals/admin_profile_response_modal.dart';
import 'package:urbantutorsapp/models/profile_modals/student_profile_request_modal.dart';
import 'package:urbantutorsapp/models/profile_modals/student_profile_response_modal.dart';
import 'package:urbantutorsapp/models/profile_modals/student_update_response.dart';
import 'package:urbantutorsapp/models/profile_modals/tutor_profile_request_modal.dart';
import 'package:urbantutorsapp/models/profile_modals/tutor_response_modal.dart';
import 'package:urbantutorsapp/screens/controllers/masterdata_modal.dart';
import 'package:urbantutorsapp/services/ApiService.dart';
import 'package:urbantutorsapp/utils/api_config.dart';
import 'package:urbantutorsapp/utils/api_constants.dart';

import 'package:urbantutorsapp/utils/storage_helper.dart';

class ProfileUpdateService {
  Future<MasterData> getMaterData() async {
    try {
      final response = await ApiService.get(
        ApiConstants.MASTERDATE,
      );

      print("✅ Response from get master data: ${response.data}");

      return MasterData.fromJson(response.data);
    } catch (e) {
      print("❌ Error in getMasterData (from ProfileUpdateService):");
      print(e.toString());
      rethrow;
    }
  }

  Future<StudentProfileResponsdModal> getProfileForStudent({String? token}) async {
    try {
      final authToken = token ?? await StorageService.getToken();
      if (authToken == null || authToken.trim().isEmpty) {
        throw const ApiException('Auth token missing. Please log in.');
      }
      final response = await ApiService.post(
        ApiConstants.USER_PROFIEL_FETCH,
        null,
        token: authToken.trim(),
      );
      print("✅ Response from getProfileForStudent :: ${response.data}");
      return StudentProfileResponsdModal.fromJson(response.data);
    } catch (e) {
      print("❌ Error in getProfileForStudent :");
      print(e.toString());
      rethrow;
    }
  }

  Future<AdminProfileResponseModel> getProfileForAdmin({String? token}) async {
    try {
      final authToken = token ?? await StorageService.getToken();
      if (authToken == null || authToken.trim().isEmpty) {
        throw const ApiException('Auth token missing. Please log in.');
      }
      final response = await ApiService.post(
        ApiConstants.USER_PROFIEL_FETCH,
        null,
        token: authToken.trim(),
      );
      print("✅ Response from getProfileForAdmin :: ${response.data}");
      return AdminProfileResponseModel.fromJson(response.data);
    } catch (e) {
      print("❌ Error in getProfileForAdmin :");
      print(e.toString());
      rethrow;
    }
  }

  Future<TutorProfileResponse> getProfileForTutor({String? token}) async {
    print("Comes to get profile for tutor");
    try {
      final authToken = token ?? await StorageService.getToken();
      if (authToken == null || authToken.trim().isEmpty) {
        throw const ApiException('Auth token missing. Please log in.');
      }
      final response = await ApiService.post(
        ApiConstants.USER_PROFIEL_FETCH,
        null,
        token: authToken.trim(),
      );

      print("✅ Response from getProfileUpdate: ${response.data}");

      return TutorProfileResponse.fromJson(response.data);
    } catch (e) {
      print("❌ Error in getProfileUpdate (from ProfileUpdateService):");
      print(e.toString());
      rethrow;
    }
  }

  /// ✅ Update profile (send data as FormData or JSON depending on API)
  Future<StudentUpdateResponse> updateProfileForStudent(
      StudentProfileUpdateRequest updateData) async {
    try {
      final response = await ApiService.post(
        ApiConfig.studentProfileUpdate,
        updateData.toJson(),
      );

      print("✅ Response from updateProfiles: ${response.data}");

      return StudentUpdateResponse.fromJson(response.data);
    } catch (e) {
      print("❌ Error in updateProfile (from ProfileUpdateService):");
      print(e.toString());
      rethrow;
    }
  }

  Future<StudentUpdateResponse> updateStudentProfile(updateData) async {
    print(updateData);
    try {
      final response = await ApiService.post(
        ApiConfig.studentProfileUpdate,
        updateData,
      );
      print("✅ Response from updateProfiled: ${response.data}");
      return StudentUpdateResponse.fromJson(response.data);
    } catch (e) {
      print("❌ Error in updateProfile (from ProfileUpdateService):");
      print(e.toString());
      rethrow;
    }
  }

  Future<TutorProfileResponse> updateProfileForTutor(
      TutorProfileUpdateRequest updateData) async {
    print("update profile called for tutor ");
    try {
      final response = await ApiService.post(
        ApiConfig.teacherProfileUpdate,
        updateData,
      );

      print("✅ Response from updateProfilel: ${response.data}");

      return TutorProfileResponse.fromJson(response.data);
    } catch (e) {
      print("❌ Error in updateProfile For Tutor :");
      print(e.toString());
      rethrow;
    }
  }

  Future<TutorProfileResponse> updateTutorProfile(updateData) async {
    print("diineskumar : ${updateData.toString()}");
    print("update profile called for tutor ");
    try {
      final response = await ApiService.postt(
          ApiConfig.teacherProfileUpdate, updateData,
          isJson: true);
      print("✅ Response from updateProfileb: $response");
      return TutorProfileResponse.fromJson(response.data);
    } catch (e) {
      print("❌ Error in updateTutorProfile");
      print(e.toString());
      rethrow;
    }
  }

// in ProfileUpdateService (or whatever service class you use)
// ProfileUpdateService (or wherever you call ApiService.post)
  Future<String?> updateAdminProfile(Map<String, dynamic> updateData) async {
    print("update profile called for tutor");
    try {
      final response =
          await ApiService.post(ApiConfig.tutorburoProfileUpdate, updateData);

      // Normalize response object:
      // - If ApiService.post returns a Map already, use it.
      // - If it returns a Response-like object (e.g., Dio), try .data
      dynamic raw = response;
      if (raw == null) {
        print("⚠️ updateAdminProfile: empty response");
        return null;
      }
      if (raw is! Map<String, dynamic>) {
        // try .data
        if (raw is Map) {
          raw = Map<String, dynamic>.from(raw);
        } else if ((raw).data != null) {
          raw = raw.data;
        }
      }

      if (raw is! Map<String, dynamic>) {
        print(
            "updateAdminProfile: unexpected response type: ${raw.runtimeType}");
        return null;
      }

      // Expected shape: { "success": true, "data": 1, "message": "Tutor Buro Profile Updated Successfully." }
      final bool success = raw['success'] == true ||
          raw['success'] == 200 ||
          raw['success'] == 'true';
      final String? message = raw['message']?.toString();

      print("updateAdminProfile: success=$success message=$message");

      if (!success) throw ApiException(message ?? 'Update failed');
      return message ?? 'Updated successfully';
    } catch (e, st) {
      print(
          "❌ Error in updateAdminProfile (from ProfileUpdateService): $e\n$st");
      rethrow;
    }
  }

  Future<TutorProfileResponse> updateAdminProfileVerifiy(updateData) async {
    print("updateAdminProfileVerifiy");
    try {
      final response = await ApiService.post(
        ApiConfig.tutorburoProfileVerify,
        updateData,
      );
      print("✅ Response from updateAdminProfile: ${response.data}");
      return TutorProfileResponse.fromJson(response.data);
    } catch (e) {
      print("❌ Error in updateProfile (from ProfileUpdateService):");
      print(e.toString());
      rethrow;
    }
  }
}
