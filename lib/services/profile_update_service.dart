import 'package:urbantutorsapp/models/profile_modals/student_profile_request_modal.dart';
import 'package:urbantutorsapp/models/profile_modals/student_profile_response_modal.dart';
import 'package:urbantutorsapp/models/profile_modals/student_update_response.dart';
import 'package:urbantutorsapp/models/profile_modals/tutor_profile_request_modal.dart';
import 'package:urbantutorsapp/models/profile_modals/tutor_response_modal.dart';
import 'package:urbantutorsapp/screens/controllers/masterdata_modal.dart';
import 'package:urbantutorsapp/services/ApiService.dart';
import 'package:urbantutorsapp/utils/api_constants.dart';

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

  Future<StudentProfileResponsdModal> getProfileForStudent() async {
    try {
      final response = await ApiService.post(
        ApiConstants.USER_PROFIEL_FETCH,
        null,
      );

      print("✅ Response from getProfileUpdate ser: ${response.data}");

      return StudentProfileResponsdModal.fromJson(response.data);
    } catch (e) {
      print("❌ Error in getProfileUpdate (from ProfileUpdateService):");
      print(e.toString());
      rethrow;
    }
  }

  Future<TutorProfileResponse> getProfileForTutor() async {
    print("Comes to get profile for tutor");
    try {
      final response = await ApiService.post(
        ApiConstants.USER_PROFIEL_FETCH,
        null,
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
        "/student_profile_update",
        updateData.toJson(),
      );

      print("✅ Response from updateProfile: ${response.data}");

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
        "/student_profile_update",
        updateData,
      );
      print("✅ Response from updateProfile: ${response.data}");
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
        "/teacher_profile_update",
        updateData.toJson(),
      );

      print("✅ Response from updateProfile: ${response.data}");

      return TutorProfileResponse.fromJson(response.data);
    } catch (e) {
      print("❌ Error in updateProfile (from ProfileUpdateService):");
      print(e.toString());
      rethrow;
    }
  }
}
