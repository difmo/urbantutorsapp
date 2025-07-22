import 'package:dio/dio.dart';
import 'package:urbantutorsapp/models/get_subject_model.dart';
import 'package:urbantutorsapp/services/ApiService.dart';
import 'package:urbantutorsapp/utils/api_constants.dart';

class GetSubjectServices {
  Future<GetSubjectModel> fetchSubjects
  () async {
    try {
      Response response = await 
      ApiService.post(ApiConstants.GET_SUBJECT_URL, {'class_id': "1",
       'type': "Note",
      });

      if(response.statusCode == 200) {
        print("response from if get subject services");
        print(response.data);
        return GetSubjectModel.fromJson(response.data);
      }else {
        throw Exception('Failed to load subject data');
      }
  } on DioError catch (e) {
    print("response from catch get subjectservies");
    print(e.toString());
    if (e.response != null) {
      throw Exception('Erro from server: ${e.response?.data}');
    }else {
      throw Exception('Network error: ${e.message}');
    }
  }
}
}