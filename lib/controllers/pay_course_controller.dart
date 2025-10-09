import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:urbantutorsapp/models/pay_course_models.dart';
import 'package:urbantutorsapp/services/pay_course_service.dart';
import 'package:urbantutorsapp/utils/storage_helper.dart';

class PayCourseController extends GetxController {
  final PayCourseService _svc = PayCourseService();

  final isLoading = false.obs;
  final error = ''.obs;
  final courses = <PayCourse>[].obs;

  // Per-item operations
  final purchasingCourseId = 0.obs;
  final openingCourseId = 0.obs;

  @override
  void onInit() {
    super.onInit();
    load();
  }

  Future<void> load() async {
    isLoading.value = true;
    error.value = '';
    try {
      final payload = await _svc.fetchCourses();
      courses.assignAll(payload.items);
    } catch (e) {
      error.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> refreshNow() async {
    try {
      final payload = await _svc.fetchCourses();
      courses.assignAll(payload.items);
    } catch (e) {
      error.value = e.toString();
    }
  }

  Future<void> buy(PayCourse course) async {
    if (purchasingCourseId.value != 0) return;
    purchasingCourseId.value = course.id;
    try {
      final uidStr = await StorageService.getUserId();
      final userId = int.tryParse(uidStr ?? '') ?? 0;
      if (userId <= 0) throw Exception('No user id found');

      final res = await _svc.purchaseCourse(userId: userId, courseId: course.id);
      if (!res.success) throw Exception(res.message.isEmpty ? 'Purchase failed' : res.message);

      Get.snackbar('Success', res.message.isEmpty ? 'Course purchased' : res.message);
    } catch (e) {
      Get.snackbar('Error', e.toString());
      rethrow;
    } finally {
      purchasingCourseId.value = 0;
    }
  }

  Future<String?> getPreviewUrl(PayCourse course) async {
    if (openingCourseId.value != 0) return null;
    openingCourseId.value = course.id;
    try {
      // Prefer endpoint; fallback to course.pdf if backend returns empty
      final v = await _svc.getViewInfo(course.id);
      String url = v.url.trim();
      if (url.isEmpty) {
        url = (course.pdf ?? '').trim();
      }

      if (url.isEmpty) throw Exception('No preview available');

      // If relative, guess base path used in admin uploads
      if (!url.contains('://')) {
        url = 'https://urbantutors.pro/public/admin/uploads/paycourse/$url';
      }
      return url;
    } catch (e) {
      Get.snackbar('Error', e.toString());
      return null;
    } finally {
      openingCourseId.value = 0;
    }
  }

  Future<void> launchUrlExternal(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      Get.snackbar('Error', 'Cannot open: $url');
    }
  }
}
