import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:urbantutorsapp/services/api_exception.dart';
import 'package:urbantutorsapp/utils/api_constants.dart';
import 'package:urbantutorsapp/utils/session.dart';
import 'package:urbantutorsapp/utils/storage_helper.dart';

export 'package:urbantutorsapp/services/api_exception.dart';

class ApiService {
  static final Dio _dio = Dio(
    BaseOptions(
      baseUrl: ApiConstants.BASE_URL,
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 30),
      // Profile forms upload photos; allow slow mobile connections.
      sendTimeout: const Duration(seconds: 60),
      headers: {'Accept': 'application/json'},
      // Let 4xx still return to us for message parsing
      validateStatus: (code) => code != null && code < 500,
    ),
  );

  /// The underlying client; exposed so tests can install a fake adapter.
  @visibleForTesting
  static Dio get dio => _dio;

  /// `data` should be:
  /// - `FormData()` (recommended for your APIs) OR
  /// - plain Map<String, dynamic> (we'll wrap to FormData)
  static Future<Response> post(
    String path,
    dynamic data, {
    String? token,
    bool isJson = false, // keep for future JSON endpoints
  }) {
    final payload = (data is FormData)
        ? data
        : (isJson ? data : _toFormData(data));
    return _send('POST', path, data: payload, token: token, isJson: isJson);
  }

  /// Same as [post], but with `isJson: true` a Map is sent as JSON even when
  /// it is not already encoded.
  static Future<Response> postt(
    String path,
    dynamic data, {
    String? token,
    bool isJson = false,
  }) {
    final payload = isJson
        ? data
        : (data is FormData ? data : _toFormData(data));
    return _send('POST', path, data: payload, token: token, isJson: isJson);
  }

  static Future<Response> get(String path, {String? token}) =>
      _send('GET', path, token: token);

  static Future<Response> put(String path, dynamic data, {String? token}) =>
      _send('PUT', path, data: data, token: token, isJson: true);

  static Future<Response> delete(String path, {String? token}) =>
      _send('DELETE', path, token: token);

  static FormData _toFormData(dynamic data) =>
      FormData.fromMap(((data as Map?)?.cast<String, dynamic>()) ?? const {});

  static Future<Response> _send(
    String method,
    String path, {
    dynamic data,
    String? token,
    bool isJson = false,
  }) async {
    // Resolve Bearer token (explicit arg wins)
    final authToken = token ?? await StorageService.getToken();
    final hasToken = authToken != null && authToken.isNotEmpty;

    final headers = <String, String>{
      if (hasToken) 'Authorization': 'Bearer $authToken',
      if (isJson) 'Content-Type': 'application/json',
    };

    final Response res;
    try {
      res = await _dio.request(
        path,
        data: data,
        options: Options(method: method, headers: headers),
      );
    } on DioException catch (e) {
      debugPrint('[API] $method $path failed: ${e.type} ${e.message}');
      throw ApiException(_messageFor(e), statusCode: e.response?.statusCode);
    }

    final status = res.statusCode ?? 0;
    final body = res.data;

    // A logged-in request rejected as unauthorized means the session is gone.
    if (status == 401 && hasToken) {
      await Session.expire();
      throw ApiException(
        _serverMessage(body) ?? 'Your session has expired. Please log in again.',
        statusCode: status,
      );
    }

    // Anything that is not JSON (e.g. an HTML 404 page) can't be parsed by
    // the models, so fail here with a readable message instead of a cast error.
    if (body is! Map && body is! List) {
      throw ApiException(
        status >= 400
            ? 'Server error ($status). Please try again later.'
            : 'Unexpected response from server. Please try again later.',
        statusCode: status,
      );
    }

    return res;
  }

  static String? _serverMessage(dynamic body) {
    if (body is Map && body['message'] != null) {
      final msg = body['message'].toString().trim();
      if (msg.isNotEmpty) return msg;
    }
    return null;
  }

  static String _messageFor(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return 'The server is taking too long to respond. Please try again.';
      case DioExceptionType.connectionError:
        return 'No internet connection. Please check your network and try again.';
      case DioExceptionType.cancel:
        return 'Request was cancelled.';
      case DioExceptionType.badCertificate:
        return 'Secure connection failed. Please try again later.';
      case DioExceptionType.badResponse:
        return _serverMessage(e.response?.data) ??
            'Server error (${e.response?.statusCode}). Please try again later.';
      case DioExceptionType.unknown:
        return 'Something went wrong. Please check your connection and try again.';
    }
  }
}
