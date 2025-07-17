import 'package:dio/dio.dart';


class ApiService {
  static final Dio _dio = Dio(
    BaseOptions(
      baseUrl: 'https://urbantutors.pro/api/',
      connectTimeout: Duration(seconds: 10),
      receiveTimeout: Duration(seconds: 15),
      sendTimeout: Duration(seconds: 10),
    ),
  );

  static Future<Response> post(
    String path,
    dynamic data, {
    String? token,
    bool isJson = false,
  }) async {
    try {
      Options options = Options(
        headers: {
          'Authorization': token != null ? 'Bearer $token' : null,
          'Content-Type': isJson ? 'application/json' : 'multipart/form-data',
        },
      );
      return await _dio.post(path, data: data, options: options);
    } on DioError catch (e) {
      throw Exception(e.response?.data ?? 'Network error: ${e.message}');
    }
  }

  static Future<Response> get(
    String path, {
    String? token,
  }) async {
    try {
      Options options = Options(
        headers: {
          'Authorization': token != null ? 'Bearer $token' : null,
        },
      );
      return await _dio.get(path, options: options);
    } on DioError catch (e) {
      throw Exception(e.response?.data ?? 'Network error: ${e.message}');
    }
  }

  static Future<Response> put(
    String path,
    dynamic data, {
    String? token,
  }) async {
    try {
      Options options = Options(
        headers: {
          'Authorization': token != null ? 'Bearer $token' : null,
          'Content-Type': 'application/json',
        },
      );
      return await _dio.put(path, data: data, options: options);
    } on DioError catch (e) {
      throw Exception(e.response?.data ?? 'Network error: ${e.message}');
    }
  }

  static Future<Response> delete(
    String path, {
    String? token,
  }) async {
    try {
      Options options = Options(
        headers: {
          'Authorization': token != null ? 'Bearer $token' : null,
        },
      );
      return await _dio.delete(path, options: options);
    } on DioError catch (e) {
      throw Exception(e.response?.data ?? 'Network error: ${e.message}');
    }
  }

}
