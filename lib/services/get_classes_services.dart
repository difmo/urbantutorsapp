import 'package:dio/dio.dart';
import 'package:urbantutorsapp/models/get_classes_model.dart';
import 'package:urbantutorsapp/services/ApiService.dart';

class GetClassesService {
  Future<GetClassesModel> fetchClasses() async {
    try {
     Response response = await ApiService.post('/getclasses', {
        'board_id': '1',
        'type': 'pyq',
      });

      if (response.statusCode == 200) {
        print("response from if get classes services");
        print(response.data);
        return GetClassesModel.fromJson(response.data);
      } else {
        throw Exception('Failed to load class data');
      }
    } on DioError catch (e) {
      print("response from catch get classesservice");
      print(e.toString());
      if (e.response != null) {
        throw Exception('Error from server: ${e.response?.data}');
      } else {
        throw Exception('Network error: ${e.message}');
      }
    }
  }
}
