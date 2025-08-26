import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:urbantutorsapp/services/ApiService.dart';
import 'package:urbantutorsapp/services/auth_service.dart';
import 'package:urbantutorsapp/services/profile_services.dart';
import 'package:urbantutorsapp/utils/storage_helper.dart';

class AuthController extends GetxController {
  final AuthService _authService = AuthService();

  var isLoading = false.obs;
  var token = ''.obs;

  Future<String?> sendOtp(String mobile) async {
    isLoading.value = true;
    try {
      final res = await _authService.sendOtp(mobile);
      final otp = res.data?['data']?['otp_data']?['mobile_otp']?.toString();
      debugPrint('OTP sent: $otp');

      return otp;
    } catch (e) {
      Get.snackbar('Error', e.toString());
      return null;
    } finally {
      isLoading.value = false;
    }
  }

  void printJson(dynamic data) {
    const JsonEncoder encoder = JsonEncoder.withIndent('  ');
    final prettyJson = encoder.convert(data);
    print(prettyJson);
  }

  Future<void> verifyOtp(String mobile, String otp, String name, String roleId,
      String fbToken) async {
    isLoading.value = true;
    try {
      final res = await _authService.verifyOtp(
        mobile: mobile,
        otp: otp,
        name: name,
        roleId: roleId,
        firebaseToken: fbToken,
      );
      token.value = res.data.token;
      print(res.data.userData.roles);
      printJson(res.data);
      print("Tokenvalue");
      print(token.value);
      await TokenStorage.saveToken(token.value);
      await TokenStorage.saveRoleId(res.data.userData.roles[0].roleId);
      await TokenStorage.saveRole("Admin");
    } catch (e) {
      print("Error while otp verification");
      print(e.toString());
      Get.snackbar('Error', e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  /// ✅ Add this logout method
  Future<void> logout() async {
    try {
      token.value = '';
      await TokenStorage
          .clear(); // or use TokenStorage.removeToken() if available
      Get.offAllNamed('/role-intro'); // or your login screen
    } catch (e) {
      Get.snackbar('Logout Error', e.toString());
    }
  }
}
