// services/my_course_service.dart

import 'package:dio/dio.dart';
import 'package:urbantutorsapp/models/my_course_models.dart';
import 'package:urbantutorsapp/services/ApiService.dart';

class MyCourseService {
  /// POST /mycourse
  Future<MyCoursePayload> fetchMyCourses(int userId) async {
    final res = await ApiService.post(
      '/mycourse',
      FormData.fromMap({'user_id': userId.toString()}),
    );
    // res.data expected to be Map<String, dynamic>
    final data = res.data;
    if (data is Map<String, dynamic>) {
      return MyCoursePayload.fromJson(data);
    }
    // try to convert
    return MyCoursePayload.fromJson(Map<String, dynamic>.from(data as Map));
  }

  /// GET /viewpdf/{course_id} → returns type + url
  Future<ViewInfo> getViewInfo(int courseId) async {
    final res = await ApiService.get('/viewpdf/$courseId');
    final data = res.data;
    if (data is Map<String, dynamic>) {
      return ViewInfo.fromJson(data);
    }
    return ViewInfo.fromJson(Map<String, dynamic>.from(data as Map));
  }
}
