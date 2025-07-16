import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:urbantutorsapp/services/ApiService.dart';

class AuthController extends GetxController {
  final ApiService api = Get.find<ApiService>();
  var isLoading = false.obs;
  var token = ''.obs;

  Future<String?> sendOtp(String mobile) async {
    isLoading.value = true;
    try {
      final res = await api.sendOtp(mobile);
      final otp = res.data?['data']?['otp_data']?['mobile_otp']?.toString();
         debugPrint('OTP sent: $otp');
      // Get.snackbar('Success', 'Logged in.');
      if (Get.context != null) {
        // Get.snackbar('Success', 'OTP sent. [Dev only: $otp]');
      } else {
        debugPrint('OTP sent: $otp');
      }
      // Get.snackbar('Success', 'OTP sent. [Dev only: $otp]');
      return otp;
    } catch (e) {
      Get.snackbar('Error', e.toString());
      return null;
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> verifyOtp(String mobile, String otp, String name, String roleId,
      String fbToken) async {
        
    isLoading.value = true;
    try {
      final res = await api.verifyOtp(
          mobile: mobile,
          otp: otp,
          name: name,
          roleId: roleId,
          firebaseToken: fbToken);
      token.value = res.data['token'];
          debugPrint('OTP sent: $otp');
      // Get.snackbar('Success', 'Logged in.');
      if (Get.context != null) {
        // Get.snackbar('Success', 'OTP sent. [Dev only: $otp]');
      } else {
        debugPrint('OTP sent: $otp');
      }
    } catch (e) {
      Get.snackbar('Error', e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchProfile() async {
    if (token.value.isEmpty) throw Exception('No token!');
    final res = await api.getUserProfile(token.value);
    // parse user data from res.data
  }

  Future<void> updateProfile(Map<String, dynamic> body) async {
    if (token.value.isEmpty) throw Exception('No token!');
    await api.updateProfile(token.value, body);
    Get.snackbar('Success', 'Profile updated.');
  }
}
