import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:urbantutorsapp/controllers/auth_controller.dart';
import 'package:urbantutorsapp/controllers/coins_controller.dart';
import 'package:urbantutorsapp/controllers/get_pro_membership_controller.dart';
import 'package:urbantutorsapp/controllers/lead_controller.dart';
import 'package:urbantutorsapp/controllers/lead_create_controller.dart';
import 'package:urbantutorsapp/controllers/my_course_controller.dart';
import 'package:urbantutorsapp/controllers/notes_controller.dart';
import 'package:urbantutorsapp/controllers/notification_controller.dart';
import 'package:urbantutorsapp/controllers/pay_course_controller.dart';
import 'package:urbantutorsapp/controllers/profile_update_controller.dart';
import 'package:urbantutorsapp/controllers/transaction_controller.dart';
import 'package:urbantutorsapp/controllers/tutor_leads_controller.dart';
import 'package:urbantutorsapp/controllers/tutor_pro_controller.dart';
import 'package:urbantutorsapp/screens/controllers/lead_meta_controller.dart';
import 'package:urbantutorsapp/screens/controllers/location_controller.dart';
import 'package:urbantutorsapp/screens/controllers/masterdata_controller.dart';
import 'package:urbantutorsapp/screens/welcome/welcome_screen.dart';
import 'package:urbantutorsapp/utils/storage_helper.dart';

/// Owns the logged-in session: app-wide controllers, logout and expiry.
class Session {
  static bool _ending = false;

  /// Registers the controllers the whole app relies on.
  static void registerControllers() {
    Get.put(AuthController(), permanent: true);
    Get.put(MasterDataController(), permanent: true);
    Get.put(LeadMetaController(), permanent: true);
    Get.put(LocationController(), permanent: true);
    Get.put(PayCourseController(), permanent: true);
    Get.put(CoinsController(), permanent: true);
    Get.put(ProfileUpdateController(), permanent: true);
  }

  /// Drops the app's controllers (and the previous user's data they cache)
  /// and registers fresh ones. Call after login and logout.
  ///
  /// Deletes by type rather than `Get.deleteAll`, which would also remove
  /// GetX's own internal controllers.
  static Future<void> resetControllers() async {
    _delete<AuthController>();
    _delete<CoinsController>();
    _delete<GetProMembershipController>();
    _delete<LeadController>();
    _delete<LeadCreateController>();
    _delete<LeadMetaController>();
    _delete<LocationController>();
    _delete<MasterDataController>();
    _delete<MyCourseController>();
    _delete<NotesController>();
    _delete<NotificationController>();
    _delete<PayCourseController>();
    _delete<ProfileUpdateController>();
    _delete<TransactionController>();
    _delete<TutorLeadsController>();
    _delete<TutorProController>();
    registerControllers();
  }

  static void _delete<T>() {
    if (Get.isRegistered<T>()) Get.delete<T>(force: true);
  }

  /// Clears the stored session and returns to the welcome screen.
  static Future<void> logout({String message = 'Logged out successfully'}) =>
      _end(message);

  /// Called by the network layer when the server rejects the token.
  static Future<void> expire() =>
      _end('Your session has expired. Please log in again.');

  static Future<void> _end(String message) async {
    if (_ending) return;
    _ending = true;
    try {
      await StorageService.clear();
      Get.offAll(() => const WelcomeScreen());
      // Let the old screens unmount before their controllers are removed.
      await Future<void>.delayed(const Duration(milliseconds: 300));
      await resetControllers();
      // Show the notice once the welcome screen has rendered, so it has an
      // overlay to attach to.
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Get.snackbar('Urban Tutors', message,
            snackPosition: SnackPosition.BOTTOM,
            margin: const EdgeInsets.all(12));
      });
      WidgetsBinding.instance.scheduleFrame();
    } finally {
      _ending = false;
    }
  }
}
