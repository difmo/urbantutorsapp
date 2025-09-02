import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:urbantutorsapp/services/auth_service.dart';
import 'package:urbantutorsapp/utils/storage_helper.dart';

class AuthController extends GetxController {
  final AuthService _authService = AuthService();

  var isLoading = false.obs;
  var token = ''.obs;
  var roleId = 0.obs;

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

  Future<int> verifyOtp(String mobile, String otp, String name, String roleId,
      String fbToken) async {
    print("verifyotpfunction from verifyotp $roleId");
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

      await StorageService.saveToken(token.value);

      int roleIdd = res.data.userData.roles[0].roleId;
      int userId = res.data.userData.id;
      print("User idididididididd $userId");

      await StorageService.saveRoleId(roleIdd);
      await StorageService.saveUserId(userId);
      print(await StorageService.getUserId());
      return roleIdd;
    } catch (e) {
      print("Error while otp verification: $e");
      Get.snackbar('Error', e.toString());
      return 0;
    } finally {
      isLoading.value = false;
    }
  }

  /// ✅ Logout clears everything
  Future<void> logout() async {
    try {
      token.value = '';
      roleId.value = 0; // reset to default
      await StorageService.clear();
      Get.offAllNamed('/role-intro');
      Get.snackbar("sdlkfjdsf", "Logout Successfully");
    } catch (e) {
      Get.snackbar('Logout Error', e.toString());
    }
  }
}
