  import 'package:dio/dio.dart';
  import 'package:urbantutorsapp/models/lead__model.dart';
  import 'package:urbantutorsapp/services/ApiService.dart';
import 'package:urbantutorsapp/utils/api_constants.dart';


  class LeadService {
    Future<StudentLeadResponse> getLeads() async {
      try {
        final response = await ApiService.post(
          ApiConstants.LEAD_SERVICE_URL,
          null
          // FormData(),
        );
print("✅ Response from getLeads11: ${response.data}"); // ✅
        return StudentLeadResponse.fromJson(response.data);
      }catch(e){
      print("Error in getLeads (from LeadService):");
      print(e.toString());
      throw e;
    }
    

    }
    
  }

  class StrorageHelper {
    static Future getToken() async {}
  }