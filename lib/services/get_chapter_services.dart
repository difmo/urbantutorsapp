import 'package:dio/dio.dart';
import 'package:urbantutorsapp/models/get_chapter_model.dart';
import 'package:urbantutorsapp/services/ApiService.dart';
import 'package:urbantutorsapp/utils/api_constants.dart';

class GetChapterServices {
  Future<GetChapterModel> fetchChapters() async {
    try {
      Response response = await ApiService.post(
          ApiConstants.GET_CHAPTER_URL, {'subject_id': "1", 'type': "Note"});

      if (response.statusCode == 200) {
        print("response from if get chapter ");
        print(response.data);
        return GetChapterModel.fromJson(response.data);
      } else {
        throw Exception('Failed to load Chapter data');
      }
    } on DioError catch (e) {
      print("response from catch get chaptersrvices");
      print(e.toString());
      if (e.response != null) {
        throw Exception('Error from server: ${e.response?.data}');
      } else {
        throw Exception('Network error: ${e.message}');
      }
    }
  }
}
