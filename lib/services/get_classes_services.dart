import 'package:dio/dio.dart';
import 'package:urbantutorsapp/models/get_classes_model.dart';
import 'package:urbantutorsapp/services/ApiService.dart';
import 'package:urbantutorsapp/utils/api_constants.dart';

class GetClassesService {
  Future<GetClassesModel> fetchClasses({
    required int boardId,
    int? classId,
    String? className,
    String? type,
  }) async {
    try {
      final Map<String, dynamic> body = {
        "board_id": boardId,
        if (classId != null) "class_id": classId,
        if (className != null) "ClassName": className,
        if (type != null) "type": type,
      };

      Response response = await ApiService.post(ApiConstants.GETCLASS_URL, body);

      if (response.statusCode == 200) {
        print("✅ Classes fetched successfully:");
        print(response.data);
        return GetClassesModel.fromJson(response.data);
      } else {
        throw Exception('❌ Failed to load class data. Status: ${response.statusCode}');
      }
    } on DioException catch (e) {
      print("❌ DioError while fetching classes:");
      print(e.toString());

      if (e.response != null) {
        throw Exception('Server Error: ${e.response?.data}');
      } else {
        throw Exception('Network Error: ${e.message}');
      }
    }
  }
}
