import 'package:get/get.dart';
import 'package:urbantutorsapp/models/tutor_lead.dart';
import 'package:urbantutorsapp/services/leads_view_service.dart';

class TutorLeadsController extends GetxController {
  final LeadsViewService _service = LeadsViewService();

  final leads = <TutorLead>[].obs;
  final isLoading = false.obs;
  final error = ''.obs;

  // Local "contacted" marker (toggle in UI). Wire to backend later if needed.
  final contactedIds = <int>{}.obs;

  @override
  void onInit() {
    super.onInit();
    load();
  }

  Future<void> load() async {
    try {
      error.value = '';
      isLoading.value = true;
      final data = await _service.fetchLeads();
      // newest first
      data.sort((a, b) => (b.createdAt ?? DateTime(0)).compareTo(a.createdAt ?? DateTime(0)));
      leads.assignAll(data);
    } catch (e) {
      error.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> refreshNow() => load();

  // Tabs data
  List<TutorLead> get enquiries => leads; // all
  List<TutorLead> get nearby =>
      leads.where((l) => l.mode.toLowerCase() == 'offline').toList();
  List<TutorLead> get contacted =>
      leads.where((l) => contactedIds.contains(l.id)).toList();

  void toggleContacted(int id) {
    if (contactedIds.contains(id)) {
      contactedIds.remove(id);
    } else {
      contactedIds.add(id);
    }
  }
}
