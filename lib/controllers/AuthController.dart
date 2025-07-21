import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:urbantutorsapp/services/ApiService.dart';
import 'package:urbantutorsapp/services/auth_service.dart';
import 'package:urbantutorsapp/services/profile_services.dart';
import 'package:urbantutorsapp/utils/storage_helper.dart';

class AuthController extends GetxController {
  final AuthService authService = Get.find<AuthService>();
  final ProfileService profileService = Get.find<ProfileService>();

  var isLoading = false.obs;
  var token = ''.obs;

  Future<String?> sendOtp(String mobile) async {
    print("mobile");
    print(mobile);
    isLoading.value = true;
    try {
      final res = await authService.sendOtp(mobile);
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
      print("sdfdsfsdfsddfg" + e.toString());
      return null;
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> verifyOtp(String mobile, String otp, String name, String roleId,
      String fbToken) async {
        print('kml');
    isLoading.value = true;
    try {
      print("mobile"+mobile);
      print("name"+name);
      print("otp"+otp);
      print("roleId"+roleId);
      print('pgl');
      final res = await authService.verifyOtp(
          mobile: mobile,
          otp: otp,
          name: name,
          roleId: roleId,
          firebaseToken: fbToken);
      token.value = res.data.token;
      debugPrint('OTP sent456789: $otp');
      print(token.value);
      print('main bhi');

      TokenStorage.saveToken(token.value);
      TokenStorage.saveRole("Admin");

      print(res);
      // Get.snackbar('Success', 'Logged in.');
      if (Get.context != null) {
        // Get.snackbar('Success', 'OTP sent. [Dev only: $otp]');
      } else {
        debugPrint('OTP sent: $otp');
      }
    } catch (e) {

      print("errorfromcontroller"+e.toString());
      Get.snackbar('Error', e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchProfile() async {
    if (token.value.isEmpty) throw Exception('No token!');
    final res = await profileService.getUserProfile(token.value);
    // parse user data from res.data
  }

  Future<void> updateProfile(Map<String, dynamic> body) async {
    if (token.value.isEmpty) throw Exception('No token!');
    await profileService.updateProfile(token.value, body);
    Get.snackbar('Success', 'Profile updated.');
  }
}
