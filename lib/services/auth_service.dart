import 'package:dio/dio.dart';
import 'package:urbantutorsapp/models/user_new_modal.dart';
import 'package:urbantutorsapp/services/ApiService.dart';
import 'package:urbantutorsapp/utils/api_constants.dart';


class AuthService {
  Future<Response> sendOtp(String mobile, {required String name, required int roleId}) async {
    return await ApiService.post('send_otp', FormData.fromMap({
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
    print('mynameiskhan: $otp');

    final response = await ApiService.post(
      ApiConstants.VERIFY_OTP,
      FormData.fromMap({
        'mobile': mobile,           
        'otp': otp,              
        'name': name,              
        'role_id': roleId,                   
        'firebase_token': "STATIC_FB_TOKEN_ABC123", 
      }),
    );
    print("✅ Response from verifyOtp:");
    print(response.data);
    return LoginResponse.fromJson(response.data);
  } catch (e) {
    print("❌ Error in verifyOtp (from AuthService):");
    print(e.toString());
    rethrow;
  }
}

}
