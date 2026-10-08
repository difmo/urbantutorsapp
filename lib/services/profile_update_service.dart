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
import 'package:urbantutorsapp/utils/app_log.dart';
import 'package:urbantutorsapp/utils/storage_helper.dart';

class ProfileUpdateService {
  Future<MasterData> getMaterData() async {
    try {
      final response = await ApiService.get(
        ApiConstants.MASTERDATE,
      );
      AppLog.s('Master data fetched', name: 'PROFILE');
      return MasterData.fromJson(response.data);
    } catch (e, st) {
      AppLog.e('getMasterData failed', name: 'PROFILE', error: e, st: st);
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
      AppLog.s('Student profile fetched', name: 'PROFILE');
      return StudentProfileResponsdModal.fromJson(response.data);
    } catch (e, st) {
      AppLog.e('getProfileForStudent failed', name: 'PROFILE', error: e, st: st);
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
      AppLog.s('Admin profile fetched', name: 'PROFILE');
      return AdminProfileResponseModel.fromJson(response.data);
    } catch (e, st) {
      AppLog.e('getProfileForAdmin failed', name: 'PROFILE', error: e, st: st);
      rethrow;
    }
  }

  Future<TutorProfileResponse> getProfileForTutor({String? token}) async {
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
      AppLog.s('Tutor profile fetched', name: 'PROFILE');
      return TutorProfileResponse.fromJson(response.data);
    } catch (e, st) {
      AppLog.e('getProfileForTutor failed', name: 'PROFILE', error: e, st: st);
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
      AppLog.s('Student profile updated', name: 'PROFILE');
      return StudentUpdateResponse.fromJson(response.data);
    } catch (e, st) {
      AppLog.e('updateProfileForStudent failed', name: 'PROFILE', error: e, st: st);
      rethrow;
    }
  }

  Future<StudentUpdateResponse> updateStudentProfile(updateData) async {
    try {
      final response = await ApiService.post(
        ApiConfig.studentProfileUpdate,
        updateData,
      );
      AppLog.s('Student profile updated', name: 'PROFILE');
      return StudentUpdateResponse.fromJson(response.data);
    } catch (e, st) {
      AppLog.e('updateStudentProfile failed', name: 'PROFILE', error: e, st: st);
      rethrow;
    }
  }

  Future<TutorProfileResponse> updateProfileForTutor(
      TutorProfileUpdateRequest updateData) async {
    try {
      final response = await ApiService.post(
        ApiConfig.teacherProfileUpdate,
        updateData,
      );
      AppLog.s('Tutor profile updated', name: 'PROFILE');
      return TutorProfileResponse.fromJson(response.data);
    } catch (e, st) {
      AppLog.e('updateProfileForTutor failed', name: 'PROFILE', error: e, st: st);
      rethrow;
    }
  }

  Future<TutorProfileResponse> updateTutorProfile(updateData) async {
    try {
      final response = await ApiService.postt(
          ApiConfig.teacherProfileUpdate, updateData,
          isJson: true);
      AppLog.s('Tutor profile updated', name: 'PROFILE');

      return TutorProfileResponse.fromJson(response.data);
    } catch (e, st) {
      AppLog.e('updateTutorProfile failed', name: 'PROFILE', error: e, st: st);
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
    try {
      final response = await ApiService.post(
        ApiConfig.tutorburoProfileVerify,
        updateData,
      );
      AppLog.s('Admin profile verified', name: 'PROFILE');
      return TutorProfileResponse.fromJson(response.data);
    } catch (e, st) {
      AppLog.e('updateAdminProfileVerifiy failed', name: 'PROFILE', error: e, st: st);
      rethrow;
    }
  }
}
