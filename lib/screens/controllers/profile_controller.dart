import 'package:get/get.dart';
import 'package:urbantutorsapp/models/user_model.dart';
import 'package:urbantutorsapp/services/profile_services.dart';

class ProfileController extends GetxController {
  final ProfileService _profileService = ProfileService();
  
Future<StudentProfileModel> fetchUserProfile(String token) async {
    final response = await _profileService.getUserProfile(token);
 
    if (response.success) {
        print("Fromprofilecontroller");
         print(response.data!.studentName ?? "asda");
      return response;
    } else {
      throw Exception('Failed to load user profile: ${response.message}');
    }
    }
    
}

