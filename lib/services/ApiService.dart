import 'package:dio/dio.dart';
import 'package:urbantutorsapp/utils/api_constants.dart';
import 'package:urbantutorsapp/utils/storage_helper.dart';

class ApiService {
  static final Dio _dio = Dio(
    BaseOptions(
      baseUrl: ApiConstants.BASE_URL,
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 20),
      sendTimeout: const Duration(seconds: 15),
      // Let 4xx still return to us for message parsing
      validateStatus: (code) => code != null && code < 500,
    ),
  );

  /// `data` should be:
  /// - `FormData()` (recommended for your APIs) OR
  /// - plain Map<String, dynamic> (we'll wrap to FormData)
  static Future<Response> post(
    String path,
    dynamic data, {
    String? token,
    bool isJson = false, // keep for future JSON endpoints
  }) async {
    // Resolve Bearer token (explicit arg wins)
    final authToken = token ?? await StorageService.getToken();

    // Build headers safely
    final headers = <String, String>{};
    if (authToken != null && authToken.isNotEmpty) {
      headers['Authorization'] = 'Bearer $authToken';
    }
    if (isJson) headers['Content-Type'] = 'application/json';

    // Full URL or relative path – Dio handles both
    final payload = (data is FormData)
        ? data
        : (isJson ? data : FormData.fromMap(((data as Map?)?.cast<String, dynamic>()) ?? const {}));

    try {
      final res = await _dio.post(path, data: payload, options: Options(headers: headers));
      return res;
    } on DioException catch (e) {
      final server = e.response?.data;
      final msg = (server is Map && server['message'] != null)
          ? server['message'].toString()
          : e.message ?? 'Network error';
      throw Exception(msg);
    }
  }

static Future<Response> postt(
  String path,
  dynamic data, {
  String? token,
  bool isJson = false,
}) async {
   // Resolve Bearer token (explicit arg wins)
    final authToken = token ?? await StorageService.getToken();

    // Build headers safely
    final headers = <String, String>{};
    if (authToken != null && authToken.isNotEmpty) {
      headers['Authorization'] = 'Bearer $authToken';
    }
    if (isJson) headers['Content-Type'] = 'application/json';
 

  final payload = isJson
      ? data // 👈 pass Map directly; Dio will JSON-encode
      : (data is FormData
          ? data
          : FormData.fromMap(((data as Map?)?.cast<String, dynamic>()) ?? const {}));

  try {
    final res = await _dio.post(path, data: payload, options: Options(headers: headers));
    return res;
  } on DioException catch (e) {
    final server = e.response?.data;
    final msg = (server is Map && server['message'] != null)
        ? server['message'].toString()
        : e.message ?? 'Network error';
    throw Exception(msg);
  }
}

  static Future<Response> get(String path, {String? token}) async {
    final authToken = token ?? await StorageService.getToken();
    final headers = <String, String>{};
    if (authToken != null && authToken.isNotEmpty) {
      headers['Authorization'] = 'Bearer $authToken';
    }
    try {
      return await _dio.get(path, options: Options(headers: headers));
    } on DioException catch (e) {
      final server = e.response?.data;
      final msg = (server is Map && server['message'] != null)
          ? server['message'].toString()
          : e.message ?? 'Network error';
      throw Exception(msg);
    }
  }

  static Future<Response> put(String path, dynamic data, {String? token}) async {
    final authToken = token ?? await StorageService.getToken();
    final headers = <String, String>{'Content-Type': 'application/json'};
    if (authToken != null && authToken.isNotEmpty) {
      headers['Authorization'] = 'Bearer $authToken';
    }
    try {
      return await _dio.put(path, data: data, options: Options(headers: headers));
    } on DioException catch (e) {
      final server = e.response?.data;
      final msg = (server is Map && server['message'] != null)
          ? server['message'].toString()
          : e.message ?? 'Network error';
      throw Exception(msg);
    }
  }

  static Future<Response> delete(String path, {String? token}) async {
    final authToken = token ?? await StorageService.getToken();
    final headers = <String, String>{};
    if (authToken != null && authToken.isNotEmpty) {
      headers['Authorization'] = 'Bearer $authToken';
    }
    try {
      return await _dio.delete(path, options: Options(headers: headers));
    } on DioException catch (e) {
      final server = e.response?.data;
      final msg = (server is Map && server['message'] != null)
          ? server['message'].toString()
          : e.message ?? 'Network error';
      throw Exception(msg);
    }
  }
}
