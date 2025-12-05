import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:urbantutorsapp/models/profile_modals/admin_profile_response_modal.dart';
import 'package:urbantutorsapp/models/profile_modals/student_profile_request_modal.dart';
import 'package:urbantutorsapp/models/profile_modals/student_profile_response_modal.dart';
import 'package:urbantutorsapp/models/profile_modals/tutor_profile_request_modal.dart';
import 'package:urbantutorsapp/models/profile_modals/tutor_response_modal.dart';
import 'package:urbantutorsapp/screens/controllers/masterdata_modal.dart';
import 'package:urbantutorsapp/screens/student/student_dashboard.dart';
import 'package:urbantutorsapp/services/profile_update_service.dart';
import 'package:urbantutorsapp/utils/storage_helper.dart';

class ProfileUpdateController extends GetxController {
  final ProfileUpdateService _profileUpdateService = ProfileUpdateService();

  var isLoading = false.obs;
  var studentprofileData = Rxn<StudentProfileDataNew>();
  var adminProfileData = Rxn<AdminProfileData>();
  var masterData = Rxn<MasterData>();
  var tutorprofileData = Rxn<TutorProfileData>();

  Future<void> fetchProfileForAdmin() async {
    isLoading.value = true;
    try {
      final response = await _profileUpdateService.getProfileForAdmin();
      isLoading.value = false;
      debugPrint("✅ Admin Profile fetched successfully:  ${response.data}");
      if (response.data == []) {
        setAdminProfile(null);
      } else {
        final leadStatus = response.data!.tutorburoProfileStatus;
        await StorageService.saveUserLeadStatus(leadStatus.toString());
        setAdminProfile(response.data);
      }
    } catch (e) {
      debugPrint("❌ Error in fetchProfileUpdate: $e");
      isLoading.value = false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchMasterData() async {
    isLoading.value = true;
    try {
      final response = await _profileUpdateService.getMaterData();
      masterData.value = response;
      debugPrint("✅ Master data fetched successfully:");
    } catch (e) {
      debugPrint("❌ Error in fetchMasterData: $e");
      Get.snackbar(
        'Error',
        e.toString(),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchProfileForStudent() async {
    isLoading.value = true;
    try {
      final response = await _profileUpdateService.getProfileForStudent();
      isLoading.value = false;
      debugPrint("✅ Profile fetched successfully:  ${response.data}");
      if (response.data == []) {
        setProfile(null);
      } else {
        final leadStatus = response.data!.leadStatus;
        await StorageService.saveUserLeadStatus(leadStatus.toString());
        setProfile(response.data);
      }
    } catch (e) {
      debugPrint("❌ Error in fetchProfileUpdate: $e");
      isLoading.value = false;
    } finally {
      isLoading.value = false;
    }
  }

  void setProfile(StudentProfileDataNew? p) {
    studentprofileData.value = p;
  }

  void setAdminProfile(AdminProfileData? p) {
    adminProfileData.value = p;
  }

  Future<void> fetchProfileForTutor() async {
    isLoading.value = true;
    try {
      final response = await _profileUpdateService.getProfileForTutor();
      tutorprofileData.value = response.data;
      if (tutorprofileData.value?.profileStatus != null) {
        StorageService.saveIsProfileStatus(
            tutorprofileData.value!.profileStatus!);
      } else {
        StorageService.saveIsProfileStatus(0);
      }
      debugPrint("✅ Profile fetched successfully:");
    } catch (e) {
      debugPrint("❌ Error in fetchProfileUpdate: $e");
      // Get.snackbar(
      //   'Error',
      //   e.toString(),
      //   snackPosition: SnackPosition.BOTTOM,
      //   backgroundColor: Colors.redAccent,
      //   colorText: Colors.white,
      // );
    } finally {
      isLoading.value = false;
    }
  }

  /// ✅ Update profile with given data
  Future<bool> updateProfileForTutor(
      TutorProfileUpdateRequest updateData) async {
    isLoading.value = true;
    try {
      final response =
          await _profileUpdateService.updateProfileForTutor(updateData);
      tutorprofileData.value = response.data;
      debugPrint("✅ Profile updated successfully");
      Get.snackbar(
        'Success',
        response.message,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
      return true;
    } catch (e) {
      debugPrint("❌ Error in updateProfile: $e");
      Get.snackbar(
        'Error',
        e.toString(),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
      return false;
    } finally {
      isLoading.value = false;
      return false;
    }
  }

  Future<bool> updateTutorProfile(updateData) async {
    print(updateData);
    isLoading.value = true;
    try {
      final response =
          await _profileUpdateService.updateTutorProfile(updateData);
      tutorprofileData.value = response.data;
      debugPrint("✅ Profile updated successfully");
      if (response.success) {
        Get.snackbar(
          'Success',
          response.message,
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
        isLoading.value = false;
        return true;
      } else {
          Get.snackbar(
          'Failed',
          response.message,
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        return false;
      }
    } catch (e) {
      debugPrint("❌ Error in updateProfile: $e");
      Get.snackbar(
        'Error',
        e.toString(),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
      return false;
    } finally {
      isLoading.value = false; // 👈 no return here
    }
  }

  Future<bool> updateProfileForStudent(
      StudentProfileUpdateRequest updateData) async {
    isLoading.value = true;
    try {
      final response =
          await _profileUpdateService.updateProfileForStudent(updateData);
      debugPrint("✅ Profile updated successfully");
      final int? profileStatus = await StorageService.getIsProfileStatus();
      print("profilstatuse");
      print(profileStatus);
      Get.offAll(() => const StudentDashboardScreen());
      Get.snackbar(
        'Success',
        response.message,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
      return true;
    } catch (e) {
      debugPrint("❌ Error in updateProfile: $e");
      Get.snackbar(
        'Error',
        e.toString(),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
      return false;
    } finally {
      isLoading.value = false;
      return false;
    }
  }

  Future<bool> updateStudentProfile(dynamic data) async {
    isLoading.value = true;
    try {
      final response = await _profileUpdateService.updateStudentProfile(data);
      
      if (response.success) {
        // Optimistically update local state if we have the data map
        if (studentprofileData.value != null && data is Map) {
          final map = data as Map;
          // Extract values safely
          final String? newName = map['student_name']?.toString();
          final String? newMobile = map['mobile']?.toString();
          final String? newPic = map['profile_picture']?.toString();
          final String? newLoc = map['location']?.toString();
          final int? newBoardId = int.tryParse(map['board_id']?.toString() ?? '');
          final int? newCourseId = int.tryParse(map['course_id']?.toString() ?? '');
          final int? newPincode = int.tryParse(map['pincode']?.toString() ?? '');
          
          final updated = studentprofileData.value!.copyWith(
            studentName: newName,
            mobile: newMobile,
            // If profile_picture is empty string (no change/no image), don't wipe it unless intended.
            // But usually base64 is sent if changed. If empty, maybe it means no change?
            // In StudentProfileScreen, it sends '' if profileBase64 is null.
            // If it sends '', does it mean delete? Or ignore?
            // Assuming if it's a base64 string, we update it.
            profile_picture: (newPic != null && newPic.isNotEmpty) ? newPic : studentprofileData.value!.profile_picture,
            location: newLoc,
            boardId: newBoardId,
            courseId: newCourseId,
            pincode: newPincode,
          );
          studentprofileData.value = updated;
        }
      }

      Get.snackbar(
        'Success',
        response.message,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
      return true;
    } catch (e) {
      Get.snackbar(
        'Error',
        e.toString(),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
      return false;
    } finally {
      isLoading.value = false; // ✅ no return here
    }
  }

  /// ✅ Update profile with given data
  Future<bool> updateProfileForAdmin(
      TutorProfileUpdateRequest updateData) async {
    isLoading.value = true;
    try {
      final response =
          await _profileUpdateService.updateProfileForTutor(updateData);
      tutorprofileData.value = response.data;
      debugPrint("✅ Profile updated successfully");
      Get.snackbar(
        'Success',
        response.message,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
      return true;
    } catch (e) {
      debugPrint("❌ Error in updateProfile: $e");
      Get.snackbar(
        'Error',
        e.toString(),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
      return false;
    } finally {
      isLoading.value = false;
      return false;
    }
  }

  // in your ProfileUpdateController (or appropriate controller)
  // In ProfileUpdateController
  Future<bool> updateAdminProfile(Map<String, dynamic> updateData) async {
    isLoading.value = true;
    try {
      final msg = await _profileUpdateService.updateAdminProfile(updateData);

      // If service returned null, treat as failure
      if (msg == null) {
        Get.snackbar(
          'Error',
          'No response from server',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.redAccent,
          colorText: Colors.white,
        );
        return false;
      }
      Get.snackbar(
        'Success',
        msg,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );

      // Optionally update local profile data by re-fetching
      await fetchProfileForAdmin();

      return true;
    } catch (e, st) {
      debugPrint("❌ Error in updateAdminProfile controller: $e\n$st");
      Get.snackbar(
        'Error',
        e.toString(),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> updateAdminProfileVerify(Map<String, dynamic> updateData) async {
    isLoading.value = true;
    try {
      final response =
          await _profileUpdateService.updateAdminProfileVerifiy(updateData);

      // Assuming response.success is a boolean on the returned model
      if (response.success != true) {
        Get.snackbar(
          'Error',
          response.message ?? 'Failed to update profile',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.redAccent,
          colorText: Colors.white,
        );
        return false;
      }

      // Success path
      tutorprofileData.value = response.data;
      debugPrint("✅ Profile updated successfully");
      Get.snackbar(
        'Success',
        response.message ?? 'Profile updated successfully',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
      return true;
    } on TimeoutException catch (te) {
      debugPrint("⏱ Timeout: $te");
      Get.snackbar('Timeout', 'Request timed out. Please try again.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.orange,
          colorText: Colors.white);
      return false;
    } catch (e, st) {
      debugPrint("❌ Error in updateProfile: $e\n$st");
      Get.snackbar(
        'Error',
        e.toString(),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
      return false;
    } finally {
      // only cleanup here — do NOT return from finally
      isLoading.value = false;
    }
  }
}
