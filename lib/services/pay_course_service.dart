import 'package:dio/dio.dart';
import 'package:urbantutorsapp/models/pay_course_models.dart';
import 'package:urbantutorsapp/services/ApiService.dart';

class PayCourseService {
  /// POST /getpaycourse  (no params)
  Future<PayCoursesPayload> fetchCourses() async {
    final res = await ApiService.post('/getpaycourse', FormData.fromMap({}));
    return PayCoursesPayload.fromJson(res.data as Map<String, dynamic>);
  }

  /// POST /purchagecourse  form-data: user_id, course_id
  Future<PurchaseResponse> purchaseCourse({
    required int userId,
    required int courseId,
  }) async {
    final form = FormData.fromMap({
      'user_id': userId.toString(),
      'course_id': courseId.toString(),
    });

    final res = await ApiService.post('/purchagecourse', form);
    return PurchaseResponse.fromJson(res.data as Map<String, dynamic>);
  }

  /// GET /viewpdf/{course_id}   (returns type + file/url)
  Future<ViewCourseResponse> getViewInfo(int courseId) async {
    final res = await ApiService.get('/viewpdf/$courseId');
    return ViewCourseResponse.fromJson(res.data as Map<String, dynamic>);
  }
}
