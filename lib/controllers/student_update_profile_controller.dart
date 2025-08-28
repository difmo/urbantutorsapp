import 'package:get/get.dart';
import 'package:urbantutorsapp/models/student_update_profile_model.dart';
import 'package:urbantutorsapp/services/student_update_profile_service.dart';

class StudentProfileController extends GetxController {
  final StudentProfileService _service = StudentProfileService();

  /// Observables
  var isLoading = false.obs;
  var profile = Rxn<StudentProfileData>(); // Holds profile data
  var errorMessage = "".obs;

  /// ==========================
  /// Fetch Student Profile (Response)
  /// ==========================
  Future<void> fetchProfile(int userId) async {
    try {
      isLoading.value = true;
      errorMessage.value = "";

      final response = await _service.fetchProfile();

      if (response.success && response.data != null) {
        profile.value = response.data;
      } else {
        errorMessage.value = response.message;
        Get.snackbar("Error", response.message);
      }
    } catch (e) {
      errorMessage.value = e.toString();
      Get.snackbar("Error", e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  /// ==========================
  /// Update Student Profile (Request)
  /// ==========================
  Future<void> updateProfile( StudentProfileUpdateRequest request) async {
    try {
      isLoading.value = true;
      errorMessage.value = "";

      final response = await _service.updateStudentProfile(request);

      if (response.success && response.data != null) {
        profile.value = response.data; // Update local data
        Get.snackbar("Success", response.message);
      } else {
        errorMessage.value = response.message;
        Get.snackbar("Error", response.message);
      }
    } catch (e) {
      errorMessage.value = e.toString();
      Get.snackbar("Error", e.toString());
    } finally {
      isLoading.value = false;
    }
  }
}
