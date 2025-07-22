import 'package:dio/dio.dart';
import 'package:urbantutorsapp/models/user_new_modal.dart';
import 'package:urbantutorsapp/services/ApiService.dart';
import 'package:urbantutorsapp/utils/api_constants.dart';
import 'package:urbantutorsapp/utils/storage_helper.dart';


class AuthService {
  Future<Response> sendOtp(String mobile) async {
    return await ApiService.post('send_otp', FormData.fromMap({
      'mobile': mobile,
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
    print('mynameiskhan: $otp');

    final response = await ApiService.post(
      ApiConstants.VERIFY_OTP,
      FormData.fromMap({
        'mobile': mobile,           // static mobile
        'otp': otp,                  // static OTP
        'name': name,               // static name
        'role_id': roleId,                   // static role_id as String
        'firebase_token': "STATIC_FB_TOKEN_ABC123", // static Firebase token
      }),
    );

    print("✅ Response from verifyOtp:");
    print(response.data); // or response.toString()

    return LoginResponse.fromJson(response.data);
  } catch (e) {
    print("❌ Error in verifyOtp (from AuthService):");
    print(e.toString());
    throw e;
  }
}

}
