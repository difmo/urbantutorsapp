import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:urbantutorsapp/models/user_new_modal.dart';
import 'package:urbantutorsapp/services/auth_service.dart';
import 'package:urbantutorsapp/utils/storage_helper.dart';

class AuthController extends GetxController {
  final AuthService _authService = AuthService();

  var isLoading = false.obs;
  var token = ''.obs;
  var roleId = 0.obs;

  Future<String?> sendOtp(String mobile,
      {required String name, required int roleId}) async {
    isLoading.value = true;
    try {
      final res =
          await _authService.sendOtp(mobile, name: name, roleId: roleId);
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

  Future<String?> sendOtpForLogin(String mobile, {required int roleId}) async {
    isLoading.value = true;
    try {
      final res = await _authService.sendOtp(mobile, name: "", roleId: roleId);
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

  Future<LoginResponse> verifyOtp(String mobile, String otp, String name,
      String roleId, String fbToken) async {
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
      print("Response from verify otp: ${res.data}");
      token.value = res.data.token!;
      int roleIdd = res.data.userData!.roles[0].roleId;
      int userId = res.data.userData!.id;
      final profileStatus = res.data.userData!.profileStatus ?? 0;
      await StorageService.saveToken(token.value);
      await StorageService.saveIsProfileStatus(profileStatus);
      await StorageService.saveRoleId(roleIdd);
      await StorageService.saveUserId(userId);
      return res;
    } catch (e) {
      Get.snackbar('Error', e.toString());
      rethrow;
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
