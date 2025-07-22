import 'package:dio/dio.dart';
import 'package:urbantutorsapp/utils/api_constants.dart';

class LeadCreateService{
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
  })async {
    try{
      FormData formData = FormData.fromMap({
        'name': name,
        'mobile': mobile,
        'board_id': boardId,
        'class_id': classId,
        'location': location,
        'state': state,
        'mode': mode,
        'fee': fee,
        // 'lead_id': leadId,
        'subject_id': subjectId,
        'user_id': userId,
      });

      Response response = await _dio.post(
        ApiConstants.LEAD_CREATE_URL,
        data: formData,
      );
      return response;
    }on DioError catch (e) {
      //Handle error and return the response with error info
      if (e.response != null){
        return e.response!;
      }else{
        throw Exception('Network error: ${e.message}');
      }
    }
  }
}