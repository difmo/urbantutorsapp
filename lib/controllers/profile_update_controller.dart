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
    final token = await StorageService.getToken();
    if (token == null || token.trim().isEmpty) return;

    isLoading.value = true;
    try {
      final response =
          await _profileUpdateService.getProfileForAdmin(token: token);
      if (response.data == null) {
        setAdminProfile(null);
      } else {
        final leadStatus = response.data!.tutorburoProfileStatus;
        await StorageService.saveUserLeadStatus(leadStatus.toString());
        setAdminProfile(response.data);
      }
    } catch (e) {
      debugPrint("❌ Error in fetchProfileUpdate: $e");
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
    final token = await StorageService.getToken();
    if (token == null || token.trim().isEmpty) return;

    isLoading.value = true;
    try {
      final response =
          await _profileUpdateService.getProfileForStudent(token: token);
      if (response.data == null) {
        setProfile(null);
      } else {
        final leadStatus = response.data!.leadStatus;
        await StorageService.saveUserLeadStatus(leadStatus.toString());
        await StorageService.saveIsProfileStatus(2);

        final studentData = response.data!;
        // Auto-verify student on the server so the website reflects 'verified' instead of 'under verification'
        if (studentData.profile_status != 2 && studentData.id > 0) {
          try {
            _profileUpdateService.updateStudentProfile({
              'user_id': studentData.id,
              'profile_status': 2,
              'status': 1,
              'is_verify': 1,
              'is_verified': 1,
              'verify': 1,
            });
          } catch (err) {
            debugPrint("⚠️ Auto-verify student server sync error: $err");
          }
        }

        setProfile(studentData.copyWith(profile_status: 2));
      }
    } catch (e) {
      debugPrint("❌ Error in fetchProfileUpdate: $e");
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
    final token = await StorageService.getToken();
    if (token == null || token.trim().isEmpty) return;

    isLoading.value = true;
    try {
      final response =
          await _profileUpdateService.getProfileForTutor(token: token);
      if (response.data != null) {
        final serverName = response.data!.teacherName?.trim();
        final cached = await StorageService.getUserName();
        final finalName = (serverName != null && serverName.isNotEmpty)
            ? serverName
            : (cached?.trim() ?? '');

        if (finalName.isNotEmpty) {
          await StorageService.saveUserName(finalName);
          final json = response.data!.toJson();
          json['teacher_name'] = finalName;
          tutorprofileData.value = TutorProfileData.fromJson(json);
        } else {
          tutorprofileData.value = response.data;
        }
      } else {
        tutorprofileData.value = response.data;
      }
      if (tutorprofileData.value?.profileStatus != null) {
        StorageService.saveIsProfileStatus(
            tutorprofileData.value!.profileStatus!);
      } else {
        StorageService.saveIsProfileStatus(0);
      }
      debugPrint("✅ Profile fetched successfully:");
    } catch (e) {
      debugPrint("❌ Error in fetchProfileUpdate: $e");
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
      if (!response.success) return _failed(response.message);
      tutorprofileData.value = response.data;
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
    }
  }

  Future<bool> updateTutorProfile(updateData) async {
    isLoading.value = true;
    try {
      final response =
          await _profileUpdateService.updateTutorProfile(updateData);
      if (response.success) {
        final submittedName = (updateData is Map)
            ? (updateData['teacher_name'] ?? updateData['name'] ?? updateData['full_name'])
                ?.toString()
                .trim()
            : null;
        final respName = response.data?.teacherName?.trim();
        final finalName = (submittedName != null && submittedName.isNotEmpty)
            ? submittedName
            : (respName != null && respName.isNotEmpty ? respName : '');

        if (finalName.isNotEmpty) {
          await StorageService.saveUserName(finalName);
        }

        if (response.data != null) {
          final json = response.data!.toJson();
          if (finalName.isNotEmpty) {
            json['teacher_name'] = finalName;
          }
          tutorprofileData.value = TutorProfileData.fromJson(json);
        }
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
      if (!response.success) return _failed(response.message);
      // Student is directly verified - always navigate to dashboard!
      await StorageService.saveIsProfileStatus(2);
      await fetchProfileForStudent();
      Get.offAll(() => StudentDashboardScreen());
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
    }
  }

  Future<bool> updateStudentProfile(dynamic data) async {
    isLoading.value = true;
    try {
      final response = await _profileUpdateService.updateStudentProfile(data);
      if (!response.success) return _failed(response.message);

      {
        // Optimistically update local state if we have the data map
        if (studentprofileData.value != null && data is Map) {
          final map = data;
          // Extract values safely
          final String? newName = (map['student_name'] ?? map['name'])?.toString();
          final String? newMobile = (map['mobile'] ?? map['phone'])?.toString();
          final String? newPic = map['profile_picture']?.toString();
          final String? newLoc = map['location']?.toString();
          final int? newBoardId = int.tryParse(map['board_id']?.toString() ?? '');
          final int? newCourseId = int.tryParse((map['course_id'] ?? map['class_id'])?.toString() ?? '');
          final int? newPincode = int.tryParse(map['pincode']?.toString() ?? '');
          final String? newBoardName = map['board_name']?.toString();
          final String? newCourseName = (map['course_name'] ?? map['class_name'])?.toString();
          final String? newPrice = map['price']?.toString();
          
          final updated = studentprofileData.value!.copyWith(
            studentName: (newName != null && newName.isNotEmpty) ? newName : studentprofileData.value!.studentName,
            mobile: (newMobile != null && newMobile.isNotEmpty) ? newMobile : studentprofileData.value!.mobile,
            profile_picture: (newPic != null && newPic.isNotEmpty) ? newPic : studentprofileData.value!.profile_picture,
            location: newLoc ?? studentprofileData.value!.location,
            boardId: newBoardId ?? studentprofileData.value!.boardId,
            courseId: newCourseId ?? studentprofileData.value!.courseId,
            boardName: (newBoardName != null && newBoardName.isNotEmpty) ? newBoardName : studentprofileData.value!.boardName,
            courseName: (newCourseName != null && newCourseName.isNotEmpty) ? newCourseName : studentprofileData.value!.courseName,
            pincode: newPincode ?? studentprofileData.value!.pincode,
            price: newPrice ?? studentprofileData.value!.price,
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
      if (!response.success) return _failed(response.message);
      tutorprofileData.value = response.data;
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
          response.message.isNotEmpty ? response.message : 'Failed to update profile',
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
        response.message.isNotEmpty ? response.message : 'Profile updated successfully',
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

  bool _failed(String message) {
    Get.snackbar(
      'Failed',
      message.isNotEmpty ? message : 'Could not update profile. Please try again.',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.redAccent,
      colorText: Colors.white,
    );
    return false;
  }
}
