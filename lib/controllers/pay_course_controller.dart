import 'dart:async';
import 'dart:io';

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
      print("Loaded ho gya  :$payload");
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

  Future<PurchaseResult> buy(PayCourse course) async {
    if (purchasingCourseId.value != 0) {
      // already buying something
      return PurchaseResult(false, 'A purchase is already in progress.');
    }

    purchasingCourseId.value = course.id;
    try {
      final uidStr = await StorageService.getUserId();
      final userId = int.tryParse(uidStr ?? '') ?? 0;
      if (userId <= 0) {
        return PurchaseResult(
            false, 'User not logged in. Please login and try again.');
      }

      // call the service with timeout
      final res = await _svc
          .purchaseCourse(userId: userId, courseId: course.id)
          .timeout(const Duration(seconds: 15));

      // handle service-level failure
      if (!res.success) {
        // optionally, detect specific API error codes/messages
        final msg = (res.message ?? '').toString();
        if (msg.toLowerCase().contains('insufficient')) {
          throw InsufficientBalanceException(msg);
        }
        throw ApiException(msg.isEmpty ? 'Purchase failed' : msg);
      }

      // success
      final successMessage = (res.message?.isNotEmpty ?? false)
          ? res.message!
          : 'Course purchased successfully';
      Get.snackbar('Success', successMessage,
          snackPosition: SnackPosition.BOTTOM);
      return PurchaseResult(true, successMessage);
    } on InsufficientBalanceException catch (e) {
      Get.snackbar('Insufficient balance', e.message,
          snackPosition: SnackPosition.BOTTOM);
      return PurchaseResult(false, e.message);
    } on SocketException catch (_) {
      const msg =
          'Network error. Please check your internet connection and try again.';
      Get.snackbar('Network error', msg, snackPosition: SnackPosition.BOTTOM);
      return PurchaseResult(false, msg);
    } on TimeoutException catch (_) {
      const msg = 'Request timed out. Please try again.';
      Get.snackbar('Timeout', msg, snackPosition: SnackPosition.BOTTOM);
      return PurchaseResult(false, msg);
    } on ApiException catch (e) {
      Get.snackbar('Error', e.message, snackPosition: SnackPosition.BOTTOM);
      return PurchaseResult(false, e.message);
    } on FormatException catch (_) {
      const msg = 'Unexpected response from server. Please try again later.';
      Get.snackbar('Error', msg, snackPosition: SnackPosition.BOTTOM);
      return PurchaseResult(false, msg);
    } catch (e, st) {
      // last-resort fallback
      final msg = e?.toString() ?? 'An unknown error occurred';
      print('buy() unknown error: $e\n$st');
      Get.snackbar('Error', msg, snackPosition: SnackPosition.BOTTOM);
      return PurchaseResult(false, msg);
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

/// small result type so callers can react accordingly
class PurchaseResult {
  final bool success;
  final String message;
  PurchaseResult(this.success, this.message);
}

class InsufficientBalanceException implements Exception {
  final String message;
  InsufficientBalanceException(
      [this.message = 'Insufficient balance. Please purchase more coins.']);
  @override
  String toString() => message;
}

class ApiException implements Exception {
  final String message;
  ApiException([this.message = 'API error']);
  @override
  String toString() => message;
}
