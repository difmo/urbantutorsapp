import 'package:dio/dio.dart';
import 'package:urbantutorsapp/services/ApiService.dart';
import 'package:urbantutorsapp/utils/api_constants.dart';
import 'package:urbantutorsapp/utils/storage_helper.dart';

class LeadCreateService {
  Future<Response> createOrUpdateLead({
    required String name,
    required String mobile,
    required String boardId,
    required String classId,
    required String location,
    required String mode,
    required String fee,
    required String leadId,
    required String subjectId,
    required String userId,
     required String place_id,
      required String pincode, 
      required String latitude,
       required String longitude,
    // Optional lead settings; keys match the fields the API returns on leads.
    String? leadCount,
    String? coins,
    String? remark,
    String? state,
  }) async {
    final token = await StorageService.getToken();
    final storedUserId = await StorageService.getUserId();
    final cleanLeadId = leadId.trim();
    final isUpdate = cleanLeadId.isNotEmpty && cleanLeadId != '0';
    final formData = FormData.fromMap({
      'name': name,
      'student_name': name,
      'mobile': mobile,
      'board_id': boardId,
      'class_id': classId,
      'course_id': classId,
      'location': location,
      'locality': location,
      'mode': mode,
      'fee': fee,
      'price': fee,
      if (isUpdate) ...{
        'lead_id': cleanLeadId,
        'id': cleanLeadId,
      },
      'subject_id': subjectId,
      'user_id': storedUserId ?? userId,
      'place_id': place_id,
      'latitude': latitude,
      'longitude': longitude,
      'pincode': pincode,
      if (leadCount != null && leadCount.isNotEmpty) ...{
        'lead_count': leadCount,
        'max_hits': leadCount,
      },
      if (coins != null && coins.isNotEmpty) 'coins': coins,
      if (remark != null && remark.isNotEmpty) ...{
        'remark': remark,
        'note': remark,
      },
      if (state != null && state.isNotEmpty) 'state': state,
    });
    return ApiService.post(ApiConstants.LEAD_CREATE_URL, formData,
        token: token);
  }
  
}
