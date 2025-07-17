import 'package:get/get.dart';
import 'package:urbantutorsapp/models/user_model.dart';
import 'package:urbantutorsapp/services/profile_services.dart';

class ProfileController extends GetxController {
  
Future<StudentProfileModel> fetchUserProfile(String token) async {
    final response = await ProfileService().getUserProfile(token);
    if (response.success) {
      return response;
    } else {
      throw Exception('Failed to load user profile: ${response.message}');
    }
    }
    
}

