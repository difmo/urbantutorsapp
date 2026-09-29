import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:urbantutorsapp/models/user_new_modal.dart';
import 'package:urbantutorsapp/services/ApiService.dart';
import 'package:urbantutorsapp/utils/api_constants.dart';


class AuthService {
  Future<Response> sendOtp(String mobile, {required String name, required int roleId}) async {
    return await ApiService.post(ApiConstants.SEND_OTP, FormData.fromMap({
      'mobile': mobile,
      'name': name,
      'role_id': roleId,
    }));
  }
Future<LoginResponse> verifyOtp({
  required String mobile,
  required String otp,
  required String name,
  required String roleId,
  required String firebaseToken,
}) async {
  try {
    final Map<String, dynamic> data = {
      'mobile': mobile,
      'otp': otp,
      'role_id': roleId,
      'firebase_token': "STATIC_FB_TOKEN_ABC123",
    };
    if (name.trim().isNotEmpty &&
        name.trim().toLowerCase() != 'user' &&
        name.trim().toLowerCase() != 'urban user') {
      data['name'] = name.trim();
    }
    final response = await ApiService.post(
      ApiConstants.VERIFY_OTP,
      FormData.fromMap(data),
    );
    return LoginResponse.fromJson(response.data);
  } catch (e) {
    debugPrint("❌ Error in verifyOtp: $e");
    rethrow;
  }
}

}
