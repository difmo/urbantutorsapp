import 'package:urbantutorsapp/models/lead__model.dart';
import 'package:urbantutorsapp/services/ApiService.dart';
import 'package:urbantutorsapp/utils/api_constants.dart';
import 'package:urbantutorsapp/utils/app_log.dart';

class LeadService {
  Future<StudentLeadResponse> getLeads() async {
    try {
      final response = await ApiService.post(ApiConstants.LEAD_SERVICE_URL, null);
      AppLog.s('Leads fetched successfully', name: 'LEAD');
      return StudentLeadResponse.fromJson(response.data);
    } catch (e, st) {
      AppLog.e('Failed to fetch leads', name: 'LEAD', error: e, st: st);
      rethrow;
    }
  }
}

class StrorageHelper {
  static Future getToken() async {}
}
