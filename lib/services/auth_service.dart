import 'package:dio/dio.dart';
import 'package:urbantutorsapp/services/ApiService.dart';


class AuthService {
  Future<Response> sendOtp(String mobile) async {
    return await ApiService.post('send_otp', FormData.fromMap({
      'mobile': mobile,
    }));
  }

  Future<Response> verifyOtp({
    required String mobile,
    required String otp,
    required String name,
    required String roleId,
    required String firebaseToken,
  }) async {
    return await ApiService.post('/verify_otp', FormData.fromMap({
      'mobile': mobile,
      'otp': otp,
      'name': name,
      'role_id': 1,
      'fairbasetoken': firebaseToken,
    }));
  }
}
