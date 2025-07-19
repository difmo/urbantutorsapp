import 'package:dio/dio.dart';
import 'package:urbantutorsapp/models/user_model.dart';
import 'package:urbantutorsapp/services/ApiService.dart';

class ProfileService {
  Future<StudentProfileModel> getUserProfile(String token) async {
     print('whynotrunnig');
     print('tokenfromwhynotrunnig'+token);
    try{
      print('tryerrocomes');
      final response = await ApiService.post(
      '/user_profile', 
      null,
      token: token,
    );

    print('ResponsefromProfileservices'+response.data);
    return StudentProfileModel.fromJson(response.data);
    }catch (e){
      print('thsiscomefromprofileservices'+e.toString());
      throw(e);
    }
    
  }

  Future<Response> updateProfile(
    String token,
    Map<String, dynamic> data,
  ) async {
    return await ApiService.post(
      'profileupdate',
      data,
      token: token,
      isJson: true,
    );
  }
}
