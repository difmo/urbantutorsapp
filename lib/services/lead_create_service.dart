import 'package:dio/dio.dart';
import 'package:urbantutorsapp/services/ApiService.dart';
import 'package:urbantutorsapp/utils/api_constants.dart';
import 'package:urbantutorsapp/utils/storage_helper.dart';

class LeadCreateService {
  final Dio _dio = Dio();

  Future<Response> createOrUpdateLead({
    required String name,
    required String mobile,
    required String boardId,
    required String classId,
    required String location,
    required String state,
    required String mode,
    required String fee,
    required String leadId,
    required String subjectId,
    required String userId,
  }) async {
    try {
      final token = await StorageService.getToken();
      final userId = await StorageService.getUserId();
      print("📤 Sending lead with:");
      print("📦 class_id: $classId (${classId.runtimeType})");
      FormData formData = FormData.fromMap({
        'name': name,
        'mobile': mobile,
        'board_id': boardId,
        'class_id': classId, // ✅ make sure it's a string
        'location': location,
        'state': state,
        'mode': mode,
        'fee': fee,
        'lead_id': leadId, // Uncomment if needed
        'subject_id': subjectId,
        'user_id': userId,
      });
      final res = await ApiService.post(ApiConstants.LEAD_CREATE_URL, formData,
          token: token);
      return res;
    } on DioException catch (e) {
      // 🔴 Handle error response
      if (e.response != null) {
        print("❌ API Error Response:");
        print(e.response!.data);
        return e.response!;
      } else {
        print("❌ Network error: ${e.message}");
        throw Exception('Network error: ${e.message}');
      }
    }
  }
}
