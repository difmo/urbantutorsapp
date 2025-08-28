import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:urbantutorsapp/models/profile_update_request_model.dart';
import 'package:urbantutorsapp/models/profile_update_response_model.dart';
import 'package:urbantutorsapp/services/profile_update_service.dart';

class ProfileUpdateController extends GetxController {
  final ProfileUpdateService _profileUpdateService = ProfileUpdateService();

  var isLoading = false.obs;
  var profileData = Rxn<ProfileData>(); // single profile object

  /// ✅ Fetch profile details
  Future<void> fetchProfileUpdate() async {
    isLoading.value = true;

    try {
      final response = await _profileUpdateService.getProfileUpdate();
      profileData.value = response.data;

      debugPrint("✅ Profile fetched successfully:");
    } catch (e) {
      debugPrint("❌ Error in fetchProfileUpdate: $e");
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

  /// ✅ Update profile with given data
  Future<bool> updateProfile(ProfileUpdateRequest updateData) async {
    isLoading.value = true;

    try {
      final response = await _profileUpdateService.updateProfile(updateData);
      profileData.value = response.data;

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
}
