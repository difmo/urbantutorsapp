// lib/screens/controllers/pay_course_controller.dart
import 'package:get/get.dart';
import 'package:urbantutorsapp/models/pay_course_models.dart';
import 'package:urbantutorsapp/services/pay_course_service.dart';
import 'package:urbantutorsapp/utils/app_log.dart';
import 'package:urbantutorsapp/utils/storage_helper.dart'; // <-- where you store token

class PayCourseController extends GetxController {
  final _svc = PayCourseService();

  final isLoading = false.obs;
  final error = ''.obs;
  final courses = <PayCourse>[].obs;

  @override
  void onInit() {
    super.onInit();
    load();
  }

  Future<void> load() async {
    try {
      isLoading.value = true;
      error.value = '';
      final token = await StorageService.getToken(); // implement getToken() if not present
      print("Token: $token");
      if (token == null || token.isEmpty) {
        throw Exception('Token is missing');
      }
      AppLog.i('[COURSE] fetching with token…');
      final data = await _svc.fetchCourses(token: token);
      courses.assignAll(data);
      AppLog.i('[COURSE] loaded ${data.length}');
    } catch (e, st) {
      error.value = e.toString();
      AppLog.e('[COURSE] error', error: e, st: st);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> refreshNow() => load();
}
