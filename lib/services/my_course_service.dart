import 'package:dio/dio.dart';
import 'package:urbantutorsapp/models/my_course_models.dart';
import 'package:urbantutorsapp/services/ApiService.dart';

class MyCourseService {
  /// POST /mycourse  (form-data: user_id)
  Future<MyCoursePayload> fetchMyCourses(int userId) async {
    final res = await ApiService.post(
      '/mycourse',
      FormData.fromMap({'user_id': userId.toString()}),
    );
    return MyCoursePayload.fromJson(res.data as Map<String, dynamic>);
  }

  /// GET /viewpdf/{course_id} → returns type + url (same as your pay-course flow)
  Future<Map<String, String>> getViewInfo(int courseId) async {
    final res = await ApiService.get('/viewpdf/$courseId');
    final data = (res.data as Map<String, dynamic>);
    final d = (data['data'] is Map<String, dynamic>) ? data['data'] as Map<String, dynamic> : {};
    final url = (d['url'] ?? d['file'] ?? d['pdf'] ?? '').toString();
    final type = (d['type'] ?? d['Type'] ?? '').toString();
    return {'url': url, 'type': type};
  }
}
