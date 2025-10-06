import 'package:dio/dio.dart';
import 'package:urbantutorsapp/models/nearby_student.dart';
import 'package:urbantutorsapp/services/ApiService.dart';

class ProStatus {
  final bool active;
  final Map<String, dynamic> data;

  ProStatus({required this.active, required this.data});
}

class ProMembershipService {
  /// Helper to interpret "active" from a variety of server fields.
  bool _isActive(Map<String, dynamic>? d) {
    if (d == null) return false;

    final status = d['status'];
    final isPro = d['is_pro'] ?? d['active'] ?? d['is_active'] ?? d['pro_active'];
    final code = d['code'];
    final state = (d['state'] ?? d['membership_status'])?.toString().toLowerCase();

    return (status == 1 || status == '1' || status == true) ||
           (isPro == 1 || isPro == '1' || isPro == true) ||
           (code == 'active') ||
           (state == 'active' || state == 'enabled' || state == 'valid');
  }

  /// POST /get_pro_membership_view  (form-data: user_id)
  /// Returns full details + computed "active".
  Future<ProStatus> view(int userId) async {
    final res = await ApiService.post(
      '/get_pro_membership_view',
      FormData.fromMap({'user_id': userId.toString()}),
    );

    final m = res.data as Map<String, dynamic>;
    final raw = m['data'];
    final d = (raw is Map<String, dynamic>) ? raw : <String, dynamic>{};

    return ProStatus(active: _isActive(d), data: d);
  }

  /// Convenience wrapper if you only need a boolean.
  Future<bool> hasActivePro(int userId) async {
    final v = await view(userId);
    return v.active;
  }

  /// POST /get_pro_membership  (form-data: user_id, subscription_plan_id)
  /// Purchases Pro membership (Plan ID provided by caller).
  Future<void> purchase({
    required int userId,
    required int subscriptionPlanId,
  }) async {
    final res = await ApiService.post(
      '/get_pro_membership',
      FormData.fromMap({
        'user_id': userId.toString(),
        'subscription_plan_id': subscriptionPlanId.toString(),
      }),
    );
    final m = res.data as Map<String, dynamic>;
    if (m['success'] != true) {
      throw Exception(m['message']?.toString() ?? 'Failed to purchase membership');
    }
  }

  /// Backwards-compat alias (same as purchase()).
  Future<void> purchasePro({
    required int userId,
    required int subscriptionPlanId,
  }) =>
      purchase(userId: userId, subscriptionPlanId: subscriptionPlanId);

  /// POST /getNearbystudent  (form-data: latitude, longitude, radius)
  Future<List<NearbyStudent>> fetchNearby({
    required double latitude,
    required double longitude,
    required int radiusKm,
  }) async {
    final res = await ApiService.post(
      '/getNearbystudent',
      FormData.fromMap({
        'latitude': latitude.toString(),
        'longitude': longitude.toString(),
        'radius': radiusKm.toString(),
      }),
    );

    final body = res.data as Map<String, dynamic>;
    final data = body['data'];
    final list = (data is List) ? data : const [];

    return list
        .whereType<Map<String, dynamic>>()
        .map(NearbyStudent.fromJson)
        .toList();
  }
}
