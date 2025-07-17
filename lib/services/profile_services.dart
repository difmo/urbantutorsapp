import 'package:dio/dio.dart';
import 'package:urbantutorsapp/models/user_model.dart';
import 'package:urbantutorsapp/services/ApiService.dart';

class ProfileService {
  Future<StudentProfileModel> getUserProfile(String token) async {
    final response = await ApiService.post(
      'https://urbantutors.pro/api/user_profile', // full URL still works
      null,
      token: token,
    );
    return StudentProfileModel.fromJson(response.data);
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
