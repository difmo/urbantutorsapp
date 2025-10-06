import 'package:get/get.dart';
import 'package:urbantutorsapp/models/nearby_student.dart';
import 'package:urbantutorsapp/services/pro_membership_service.dart';
import 'package:urbantutorsapp/utils/storage_helper.dart';

class TutorProController extends GetxController {
  final ProMembershipService _svc = ProMembershipService();

  final isLoading = false.obs;
  final isPurchasing = false.obs;
  final error = ''.obs;

  final hasPro = false.obs;
  final students = <NearbyStudent>[].obs;

  int _userId = 0;

  Future<void> load({
    required double latitude,
    required double longitude,
    int radiusKm = 10,
  }) async {
    isLoading.value = true;
    error.value = '';
    try {
      final uidStr = await StorageService.getUserId();
      _userId = int.tryParse('${uidStr ?? ''}') ?? 0;
      if (_userId <= 0) throw Exception('No user id found');

      hasPro.value = await _svc.hasActivePro(_userId);

      if (hasPro.value) {
        final data = await _svc.fetchNearby(
          latitude: latitude,
          longitude: longitude,
          radiusKm: radiusKm,
        );
        students.assignAll(data);
      } else {
        students.clear();
      }
    } catch (e) {
      error.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> buyProAndReload({
    required int subscriptionPlanId,
    required double latitude,
    required double longitude,
    int radiusKm = 10,
  }) async {
    if (_userId <= 0) return;
    isPurchasing.value = true;
    try {
      await _svc.purchasePro(userId: _userId, subscriptionPlanId: subscriptionPlanId);
      hasPro.value = true;
      await load(latitude: latitude, longitude: longitude, radiusKm: radiusKm);
    } catch (e) {
      error.value = e.toString();
    } finally {
      isPurchasing.value = false;
    }
  }
}
