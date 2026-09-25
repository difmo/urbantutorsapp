import 'dart:convert';

import 'package:get/get.dart';
import 'package:urbantutorsapp/models/user_new_modal.dart';
import 'package:urbantutorsapp/services/api_exception.dart';
import 'package:urbantutorsapp/services/auth_service.dart';
import 'package:urbantutorsapp/utils/session.dart';
import 'package:urbantutorsapp/utils/storage_helper.dart';

class AuthController extends GetxController {
  final AuthService _authService = AuthService();

  var isLoading = false.obs;
  var token = ''.obs;
  var roleId = 0.obs;

  /// Requests an OTP. Returns true when the server accepted the request;
  /// on failure the error is shown to the user and false is returned.
  Future<bool> sendOtp(String mobile,
      {required String name, required int roleId}) async {
    isLoading.value = true;
    try {
      final res =
          await _authService.sendOtp(mobile, name: name, roleId: roleId);
      final body = res.data;
      if (body is Map && body['success'] == true) return true;
      Get.snackbar(
        'Error',
        (body is Map ? body['message']?.toString() : null) ??
            'Could not send OTP. Please try again.',
      );
      return false;
    } catch (e) {
      Get.snackbar('Error', e.toString());
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> sendOtpForLogin(String mobile, {required int roleId}) =>
      sendOtp(mobile, name: '', roleId: roleId);

  void printJson(dynamic data) {
    const JsonEncoder encoder = JsonEncoder.withIndent('  ');
    final prettyJson = encoder.convert(data);
    print(prettyJson);
  }

  Future<LoginResponse> verifyOtp(String mobile, String otp, String name,
      String roleId, String fbToken) async {
    isLoading.value = true;
    try {
      final res = await _authService.verifyOtp(
        mobile: mobile,
        otp: otp,               
        name: name,
        roleId: roleId,
        firebaseToken: fbToken,
      );
      if (res.success) {
        if (res.data?.token == null ||
            res.data?.userData == null ||
            res.data!.userData!.roles.isEmpty) {
          throw const ApiException(
              'Login failed: incomplete account data. Please contact support.');
        }
        token.value = res.data!.token!;
        int roleIdd = res.data!.userData!.roles[0].roleId;
        int userId = res.data!.userData!.id;
        final profileStatus = res.data!.userData!.profileStatus ?? 0;
        String userName = res.data!.userData!.name;
        String phone = res.data!.userData!.mobile;

        await StorageService.saveToken(token.value);
        await StorageService.saveIsProfileStatus(profileStatus);
        await StorageService.saveRoleId(roleIdd);
        await StorageService.saveUserId(userId);

        await StorageService.saveUserName(userName);
        await StorageService.saveUserPhone(phone);
      }

      return res;
    } finally {
      isLoading.value = false;
    }
  }

  /// ✅ Logout clears everything
  Future<void> logout() => Session.logout();
}
