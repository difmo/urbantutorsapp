import 'package:dio/dio.dart';
import 'package:get/get.dart' hide Response, FormData;
import 'package:flutter/foundation.dart';

class ApiService extends GetxService {
  late final Dio _dio;

  ApiService() {
    _dio = Dio(BaseOptions(
      baseUrl: 'https://urbantutors.pro/api/',
      connectTimeout: const Duration(seconds: 10), // ⬅️ Fixed here
      receiveTimeout: const Duration(seconds: 10), // ⬅️ And here
    ));

    // Optional: add logging interceptor for debugging
    if (kDebugMode) {
      _dio.interceptors.add(
        LogInterceptor(
          requestBody: true,
          responseBody: true,
        ),
      );
    }
  }
// Send OTP
  Future<Response> sendOtp(
    String mobile,
    String name,
    String roleId,
  ) async {
    return _post(
        '/send_otp',
        FormData.fromMap({
          'mobile': mobile,
          'name': name,
          'role_id': roleId,
        }));
  }

// Verify OTP
  Future<Response> verifyOtp({
    required String mobile,
    required String otp,
    required String name,
    required int roleId, // 🔄 Changed to int
    required String firebaseToken,
  }) async {
    return _post(
        '/verify_otp',
        FormData.fromMap({
          'mobile': mobile,
          'otp': otp,
          'name': name,
          'role_id': roleId, // 👈 Now a number, not string
          'firebase_token': firebaseToken,
        }));
  }

// Get Profile
  Future<Response> getUserProfile(String token) async {
    return _post('/user_profile', null, token: token);
  }

// Update Profile
  Future<Response> updateProfile(
      String token, Map<String, dynamic> body) async {
    return _post('/profileupdate', body, token: token, isJson: true);
  }

  // 🔹 Get Classes
Future<List<dynamic>> getClasses({required String boardId, required String type}) async {
  final response = await _dio.post(
    '/getclasses',
    data: FormData.fromMap({
      'board_id': boardId,
      'type': type,
    }),
  );
  return response.data['data'];
}


  // 🔹 Get Subjects
  Future<List<dynamic>> getSubjects(
      {required String classId, required String type}) async {
    final response = await _dio.post(
      '/getsubjects',
      data: FormData.fromMap({'class_id': classId, 'type': type}),
    );
    return response.data['data'];
  }

  // 🔹 Get Chapters
  Future<List<dynamic>> getChapters(
      {required String subjectId, required String type}) async {
    final response = await _dio.post(
      '/getchapter',
      data: FormData.fromMap({'subject_id': subjectId, 'type': type}),
    );
    return response.data['data'];
  }

  // 🔹 Get Chapter Details
  Future<Map<String, dynamic>> getChapterDetails(
      {required String chapterId, required String type}) async {
    final response = await _dio.post(
      '/getchapter_details',
      data: FormData.fromMap({'chapter_id': chapterId, 'type': type}),
    );
    return response.data['data'];
  }

  // 🔐 Internal POST Handler
  Future<Response> _post(
    String path,
    dynamic data, {
    String? token,
    bool isJson = false,
  }) async {
    try {
      final Options opts = Options(
        headers: {
          if (token != null) 'Authorization': 'Bearer $token',
          'Content-Type': isJson ? 'application/json' : 'multipart/form-data',
        },
      );

      return await _dio.post(path, data: data, options: opts);
    } on DioException catch (e) {
      if (e.response != null) {
        debugPrint('❌ API error: ${e.response?.data}');
        throw Exception(e.response?.data ?? 'API Error');
      }
      debugPrint('❌ Network error: ${e.message}');
      throw Exception('Network error: ${e.message}');
    }
  }
}
