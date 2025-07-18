import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:urbantutorsapp/models/StudentProfile.dart';
import 'package:urbantutorsapp/services/ApiService.dart';

class AuthController extends GetxController {
  final ApiService api = Get.find<ApiService>();

  var isLoading = false.obs;
  var token = ''.obs;

  // Student profile observable
  var studentProfile = Rxn<StudentProfile>();

  /// Send OTP API Call
  Future<String?> sendOtp(String mobile) async {
    isLoading.value = true;
    try {
      final res = await api.sendOtp(mobile, "Raj Verma", "1");
      final otp = res.data?['data']?['otp_data']?['mobile_otp']?.toString();
      debugPrint('OTP sent: $otp');

      if (Get.context != null) {
        Get.snackbar('Success', 'OTP sent. [Dev: $otp]');
      }
      return otp;
    } catch (e) {
      debugPrint('❌ Error in sendOtp: $e');
      if (Get.context != null) {
        Get.snackbar('Error', 'Failed to send OTP');
      }
      return null;
    } finally {
      isLoading.value = false;
    }
  }

  /// Verify OTP and store token
  Future<void> verifyOtp(
    String mobile,
    String otp,
    String name,
    int roleId,
    String fbToken,
  ) async {
    isLoading.value = true;
    try {
      final res = await api.verifyOtp(
        mobile: mobile,
        otp: otp,
        name: name,
        roleId: roleId,
        firebaseToken: fbToken,
      );

      final receivedToken = res.data?['data']?['token'];
      if (receivedToken == null) throw Exception('Token not found in response');

      token.value = receivedToken;

      // Save token and login status
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('auth_token', receivedToken);
      await prefs.setBool('isLoggedIn', true);

      final roleName = getRoleNameFromId(roleId);
      await prefs.setString('user_role', roleName);

      debugPrint('✅ Logged in as $roleName, token saved.');
    } catch (e) {
      debugPrint('❌ Error in verifyOtp: $e');
      if (Get.context != null) {
        Get.snackbar('Error', 'Failed to verify OTP');
      }
    } finally {
      isLoading.value = false;
    }
  }

  /// Map Role ID to Role Name
  String getRoleNameFromId(int roleId) {
    switch (roleId) {
      case 1:
        return 'admin';
      case 2:
        return 'tutor';
      case 3:
        return 'student';
      default:
        return 'default';
    }
  }

  /// Fetch Student Profile
  Future<void> fetchProfile() async {
    final prefs = await SharedPreferences.getInstance();
    final savedToken = prefs.getString('auth_token');
      
      print(savedToken);
    if (savedToken == null || savedToken.isEmpty) {
      throw Exception('No token saved!');
    }

    token.value = savedToken;

    try {
      final res = await api.getUserProfile(savedToken);
      debugPrint('👤 User profile: ${res.data}');

      final data = res.data?['data'];
      if (data != null) {
        studentProfile.value = StudentProfile.fromJson(data);
      }
    } catch (e) {
      debugPrint('❌ Error in fetchProfile: $e');
    }
  }

  /// Update Profile API Call
  Future<void> updateProfile(Map<String, dynamic> body) async {
    final prefs = await SharedPreferences.getInstance();
    final savedToken = prefs.getString('auth_token');

    if (savedToken == null || savedToken.isEmpty) {
      throw Exception('No token saved!');
    }

    try {
      await api.updateProfile(savedToken, body);
      if (Get.context != null) {
        Get.snackbar('Success', 'Profile updated.');
      }
    } catch (e) {
      debugPrint('❌ Error in updateProfile: $e');
      if (Get.context != null) {
        Get.snackbar('Error', 'Failed to update profile');
      }
    }
  }

  /// Clear Token and Logout
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
    await prefs.setBool('isLoggedIn', false);
    token.value = '';
    studentProfile.value = null;
  }
}
