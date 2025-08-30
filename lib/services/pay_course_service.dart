// lib/services/pay_course_service.dart
import 'dart:convert';
import 'dart:developer' as developer;
import 'package:http/http.dart' as http;
import 'package:urbantutorsapp/models/pay_course_models.dart';
 import 'dart:developer' as developer;
class PayCourseService {
  static const _api = 'https://urbantutors.pro/api/getpaycourse';

// PayCourseService.buildImageUrl
static const _imageBase =
    'https://urbantutors.pro/public/admin/uploads/paycourse/';

static String buildImageUrl(String? image) {
  if (image == null || image.isEmpty) return '';
  // If server already returns a full URL, just return it
  final hasScheme = Uri.tryParse(image)?.hasScheme ?? false;
  if (hasScheme) return image;

  // Encode the filename (handles spaces etc.)
  final encodedFile = Uri.encodeComponent(image);
  final uri = Uri.parse('$_imageBase$encodedFile');
  return uri.toString();
}

  /// REQUIRED: [token] is your JWT/bearer token.
  /// Optional: [filters] if backend later supports form fields.
  Future<List<PayCourse>> fetchCourses({
    required String token,
    Map<String, String>? filters,
  }) async {
    final headers = {
      'Accept': 'application/json',
      'Content-Type': 'application/x-www-form-urlencoded',
      'Authorization': 'Bearer $token',
    };

    final res = await http.post(
      Uri.parse(_api),
      headers: headers,
      body: filters,
    );

    if (res.statusCode == 401) {
      throw Exception('Unauthorized (401). Token missing/expired.');
    }
    if (res.statusCode < 200 || res.statusCode >= 300) {
      throw Exception('getpaycourse failed: ${res.statusCode} ${res.reasonPhrase}');
    }
    final body = jsonDecode(res.body) as Map<String, dynamic>;
    final list = (body['data'] as List<dynamic>? ?? []);
    developer.log("[PAYCOURSE] fetched ${list.length} items");
    return list.map((e) => PayCourse.fromJson(e as Map<String, dynamic>)).toList();
  }

  /// If your server needs **multipart/form-data** instead:
  Future<List<PayCourse>> fetchCoursesMultipart({
    required String token,
    Map<String, String>? fields,
  }) async {
    final req = http.MultipartRequest('POST', Uri.parse(_api))
      ..headers['Accept'] = 'application/json'
      ..headers['Authorization'] = 'Bearer $token'
      ..fields.addAll(fields ?? const {});
    final streamed = await req.send();
    final res = await http.Response.fromStream(streamed);

    if (res.statusCode == 401) {
      throw Exception('Unauthorized (401). Token missing/expired.');
    }
    if (res.statusCode < 200 || res.statusCode >= 300) {
      throw Exception('getpaycourse failed: ${res.statusCode} ${res.reasonPhrase}');
    }

    final body = jsonDecode(res.body) as Map<String, dynamic>;
    final list = (body['data'] as List<dynamic>? ?? []);
    return list.map((e) => PayCourse.fromJson(e as Map<String, dynamic>)).toList();
  }
}
