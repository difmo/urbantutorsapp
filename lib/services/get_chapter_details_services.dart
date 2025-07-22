import 'package:dio/dio.dart';
import 'package:urbantutorsapp/models/get_chapter_details_model.dart';
import 'package:urbantutorsapp/services/ApiService.dart';
import 'package:urbantutorsapp/utils/api_constants.dart';

class GetChapterDetailsServices {
  Future<GetChapterDetailsModel> fetchChaptersDetails() async {
    try {
      Response response = await ApiService.post(
          ApiConstants.GET_CHAPTER_DETAILS, {'chapter_id': "3", 'type': "Note"});

      if (response.statusCode == 200) {
        print("response from if get Chapter Details");
        print(response.data);
        return GetChapterDetailsModel.fromJson(response.data);
      } else {
        throw Exception('Failed to load Chapter details');
      }
    } on DioError catch (e) {
      print("response from catch get Chapter deatils");
      print(e.toString());
      if (e.response != null) {
        throw Exception('Error from server: ${e.response?.data}');
      } else {
        throw Exception('Network error: ${e.message}');
      }
    }
  }
}
