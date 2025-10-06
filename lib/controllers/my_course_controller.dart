import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:urbantutorsapp/models/my_course_models.dart';
import 'package:urbantutorsapp/services/my_course_service.dart';
import 'package:urbantutorsapp/utils/storage_helper.dart';

class MyCourseController extends GetxController {
  final MyCourseService _svc = MyCourseService();

  final isLoading = false.obs;
  final error = ''.obs;
  final courses = <MyCourseItem>[].obs;

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
      final uidStr = await StorageService.getUserId();
      final userId = int.tryParse('${uidStr ?? ''}') ?? 0;
      if (userId <= 0) throw Exception('No user id found');

      final payload = await _svc.fetchMyCourses(userId);
      courses.assignAll(payload.items);
    } catch (e) {
      error.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> refreshNow() => load();

  String buildImageUrl(String raw) {
    if (raw.isEmpty) return '';
    if (raw.startsWith('http')) return raw;
    return 'https://urbantutors.pro/public/admin/uploads/paycourse/$raw';
  }

  Future<void> openCourse(MyCourseItem item) async {
    if (openingCourseId.value != 0) return;
    openingCourseId.value = item.courseId;
    try {
      final view = await _svc.getViewInfo(item.courseId);
      var url = (view['url'] ?? '').trim();
      if (url.isEmpty) throw Exception('No preview available for this course');

      if (!url.contains('://')) {
        // guess relative path
        url = 'https://urbantutors.pro/public/admin/uploads/paycourse/$url';
      }
      final uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        Get.snackbar('Error', 'Cannot open: $url');
      }
    } catch (e) {
      Get.snackbar('Error', e.toString());
    } finally {
      openingCourseId.value = 0;
    }
  }
}
