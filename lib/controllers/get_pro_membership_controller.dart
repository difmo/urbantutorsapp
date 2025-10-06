import 'package:get/get.dart';
import 'package:urbantutorsapp/services/pro_membership_service.dart';
import 'package:urbantutorsapp/utils/storage_helper.dart';

class GetProMembershipController extends GetxController {
  final ProMembershipService _svc = ProMembershipService();

  final isLoading = false.obs;
  final isPurchasing = false.obs;
  final error = ''.obs;

  final hasPro = false.obs;
  final details = <String, dynamic>{}.obs;

  int _userId = 0;

  Future<void> load() async {
    isLoading.value = true;
    error.value = '';
    try {
      final uidStr = await StorageService.getUserId();
      _userId = int.tryParse('${uidStr ?? ''}') ?? 0;
      if (_userId <= 0) throw Exception('No user id found');

      final status = await _svc.view(_userId);
      hasPro.value = status.active;
      details.assignAll(status.data);
    } catch (e) {
      error.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> buy({int subscriptionPlanId = 1}) async {
    if (_userId <= 0) return;
    isPurchasing.value = true;
    try {
      await _svc.purchase(userId: _userId, subscriptionPlanId: subscriptionPlanId);
      await load(); // refresh after purchase
    } catch (e) {
      error.value = e.toString();
    } finally {
      isPurchasing.value = false;
    }
  }
}
