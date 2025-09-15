import 'package:dio/dio.dart';
import 'package:urbantutorsapp/models/grabbed_lead_model.dart';
import 'package:urbantutorsapp/models/tutor_lead.dart';
import 'package:urbantutorsapp/services/ApiService.dart';
import 'package:urbantutorsapp/utils/api_constants.dart';

class LeadsViewService {
  Future<List<TutorLead>> fetchLeads() async {
    final res = await ApiService.post(ApiConstants.LEADS_VIEW_URL, FormData());
    print("Fetching leads...${res.data}");
    final data = res.data;
    if (data is Map && data['success'] == true) {
      final List list = data['data'] ?? [];

      return list.map((e) => TutorLead.fromJson(e)).toList();
    }
    throw Exception(
        (data is Map ? data['message'] : null) ?? 'Failed to fetch leads');
  }

  /// Returns message from server (use it in a snackbar/toast)
  Future<String> grabLead({
    required String userId,
    required String leadId,
  }) async {
    final res = await ApiService.post(
      ApiConstants.GRAB_LEAD,
      FormData.fromMap({'user_id': userId, 'lead_id': leadId}),
    );
    print("Grabbing lead...${res.data}");
    final data = res.data;
    if (data is Map && data['success'] == true) {
      return (data['message'] ?? 'Lead grabbed successfully').toString();
    }
    throw Exception(
        (data is Map ? data['message'] : null) ?? 'Failed to grab lead');
  }

  Future<List<GrabLead>> grabLeadList(String userId) async {
    final res = await ApiService.post(
      ApiConstants.GRABLEAD_VIEW,
      FormData.fromMap({'user_id': userId}),
    );
    final data = res.data;
    if (data is Map && data['success'] == true) {
      final List list = data['data'] ?? [];
      return list.map((e) => GrabLead.fromJson(e)).toList();
    }
    throw Exception((data is Map ? data['message'] : null) ??
        'Failed to fetch grabbed leads');
  }

  Future<List<TutorLead>> declinedLeadList(String userId) async {
    final res = await ApiService.post(
      ApiConstants.GRABLEAD_DECLINE_VIEW,
      FormData.fromMap({'user_id': userId}),
    );
    final data = res.data;
    if (data is Map && data['success'] == true) {
      final List list = data['data'] ?? [];
      return list.map((e) => TutorLead.fromJson(e)).toList();
    }
    throw Exception((data is Map ? data['message'] : null) ??
        'Failed to fetch declined leads');
  }

  /// Decline a grabbed lead – returns message
  Future<String> declineLead({
    required String userId,
    required String grabLeadId,
    required String remark,
  }) async {
    print("Declining lead...$userId, $grabLeadId, $remark");
    final res = await ApiService.post(
      ApiConstants.GRABLEAD_DECLINE,
      FormData.fromMap({
        'user_id': userId,
        'grab_lead_id': grabLeadId,
        'remark': remark,
      }),
    );
    print("Declining lead...${res.data}");
    final data = res.data;
    if (data is Map && data['success'] == true) {
      return (data['message'] ?? 'Lead declined').toString();
    }
    throw Exception(
        (data is Map ? data['message'] : null) ?? 'Failed to decline lead');
  }
}
