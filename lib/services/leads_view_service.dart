import 'package:dio/dio.dart';
import 'package:urbantutorsapp/models/tutor_lead.dart';
import 'package:urbantutorsapp/services/ApiService.dart';
import 'package:urbantutorsapp/utils/api_constants.dart';
import 'package:urbantutorsapp/utils/storage_helper.dart';

class LeadsViewService {
  Future<List<TutorLead>> fetchLeads() async {
    // If your ApiService already injects token, this is enough:
    print("Fetching leads...");
    try {
      final resp = await ApiService.post(ApiConstants.LEADS_VIEW_URL, null);
      print(resp.data);
      final data = resp.data;
      if (data is Map && data['success'] == true) {
        final List list = data['data'] ?? [];
        return list.map((e) => TutorLead.fromJson(e)).toList();
      }
      throw Exception(data?['message'] ?? 'Failed to fetch leads');
    } catch (_) {
      // Fallback with manual Dio + Bearer token (if needed)
      final dio = Dio();
      final token = await StorageService.getToken(); // your helper
      final resp = await dio.post(
        ApiConstants.LEADS_VIEW_URL,
        options: Options(headers: token != null ? {'Authorization': 'Bearer $token'} : null),
      );
      final data = resp.data;
      if (data is Map && data['success'] == true) {
        final List list = data['data'] ?? [];
        return list.map((e) => TutorLead.fromJson(e)).toList();
      }
      throw Exception(data?['message'] ?? 'Failed to fetch leads');
    }
  }
}
