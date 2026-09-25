import 'package:get/get.dart';
import 'package:urbantutorsapp/models/grabbed_lead_model.dart';
import 'package:urbantutorsapp/models/lead_create_model_response.dart';
import 'package:urbantutorsapp/models/tutor_lead.dart';
import 'package:urbantutorsapp/services/api_exception.dart';
import 'package:urbantutorsapp/services/leads_view_service.dart';
import 'package:urbantutorsapp/utils/storage_helper.dart';

class TutorLeadsController extends GetxController {
  final LeadsViewService _service = LeadsViewService();

  // State
  final isLoading = false.obs;
  final error = ''.obs;

  // Data
  final leads = <TutorLead>[].obs; // available (leads_vew)
    final studentLead = <StudentLead>[].obs; // available (leads_vew)
  final grabbedLeads = <GrabLead>[].obs; // grablead_veiw
  final declinedLeads = <TutorLead>[].obs; // grablead_decllin_veiw

  @override
  void onInit() {
    super.onInit();
    refreshAll();
  }

  // Several loads run in parallel; stay "loading" until all have finished.
  int _pending = 0;
  void _begin() {
    _pending++;
    isLoading.value = true;
  }

  void _end() {
    if (_pending > 0) _pending--;
    isLoading.value = _pending > 0;
  }

  Future<void> refreshAll() async {
    await Future.wait([loadAvailable(), loadGrabbed(), loadDeclined()]);
  }

  Future<void> loadAvailable() async {
    try {
      error.value = '';
      _begin();
      final data = await _service.fetchLeads();
      data.sort((a, b) =>
          (b.createdAt ?? DateTime(0)).compareTo(a.createdAt ?? DateTime(0)));
      leads.assignAll(data);
    } catch (e) {
      error.value = e.toString();
    } finally {
      _end();
    }
  }

  Future<void> loadGrabbed() async {
    try {
      error.value = '';
      _begin();
      final uid = await StorageService.getUserId();
      if (uid == null) throw ApiException('User not logged in');
      final data = await _service.grabLeadList(uid);
   
      grabbedLeads.assignAll(data);
    } catch (e) {
      error.value = e.toString();
    } finally {
      _end();
    }
  }

  Future<void> loadDeclined() async {
    try {
      error.value = '';
      _begin();
      final uid = await StorageService.getUserId();
      if (uid == null) throw ApiException('User not logged in');
      final data = await _service.declinedLeadList(uid);
      data.sort((a, b) =>
          (b.createdAt ?? DateTime(0)).compareTo(a.createdAt ?? DateTime(0)));
      declinedLeads.assignAll(data);
    } catch (e) {
      error.value = e.toString();
    } finally {
      _end();
    }
  }

  /// Call when user taps “Grab” on a lead
  Future<String?> grabLead(String leadId) async {
    try {
      final uid = await StorageService.getUserId();
      if (uid == null) throw ApiException('User not logged in');

      final msg = await _service.grabLead(userId: uid, leadId: leadId);
      await Future.wait([loadGrabbed(), loadAvailable()]);
      return msg;
    } catch (e) {
      error.value = e.toString();
      return null;
    }
  }

  /// Decline a grabbed lead. Throws if the server rejects it, so callers can
  /// show the failure.
  Future<String> declineLead({
    required String grabLeadId,
    required String remark,
  }) async {
    final uid = await StorageService.getUserId();
    if (uid == null) throw const ApiException('User not logged in');

    final msg = await _service.declineLead(
      userId: uid,
      grabLeadId: grabLeadId,
      remark: remark,
    );
    await Future.wait([loadDeclined(), loadGrabbed()]);
    return msg;
  }

  /// The grab record for [leadId] if this tutor has already grabbed it.
  GrabLead? grabbedFor(int leadId) =>
      grabbedLeads.firstWhereOrNull((g) => g.leadId == leadId);

  // Convenience getters for tabs
  List<TutorLead> get enquiries => leads;
  List<TutorLead> get nearby =>
      leads.where((l) => (l.mode ?? '').toLowerCase() == 'offline').toList();
}
