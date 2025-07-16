import 'package:dio/dio.dart';
import 'package:get/get.dart' hide Response, FormData;

class ApiService extends GetxService {
  late final Dio _dio;

  ApiService() {
    _dio = Dio(BaseOptions(baseUrl: 'https://urbantutors.pro/api/', connectTimeout:Duration(microseconds: 500), receiveTimeout:Duration(microseconds: 100)));
  }

  Future<Response> sendOtp(String mobile) async {
    return _post('/send_otp', FormData.fromMap({'mobile': mobile}));
  }

  Future<Response> verifyOtp({
    required String mobile,
    required String otp,
    required String name,
    required String roleId,
    required String firebaseToken,
  }) async {
    return _post('/verify_otp', FormData.fromMap({
      'mobile': mobile,
      'otp': otp,
      'name': name,
      'role_id': roleId,
      'fairbasetoken': firebaseToken,
    }));
  }

  Future<Response> getUserProfile(String token) async {
    return _post('/user_profile', null, token: token);
  }

  Future<Response> updateProfile(
    String token, Map<String, dynamic> body) async {
    return _post('/profileupdate', body, token: token, isJson: true);
  }

  Future<Response> _post(String path, dynamic data,
      {String? token, bool isJson = false}) async {
    try {
      Options opts = Options(
        headers: {
          'Authorization': token != null ? 'Bearer $token' : null,
          'Content-Type': isJson ? 'application/json' : 'multipart/form-data',
        },
      );
      return await _dio.post(path, data: data, options: opts);
    } on DioError catch (e) {
      if (e.response != null) throw Exception(e.response?.data);
      throw Exception('Network error: ${e.message}');
    }
  }
}
