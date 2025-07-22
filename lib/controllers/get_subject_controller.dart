import 'package:get/get.dart';
import 'package:urbantutorsapp/models/get_subject_model.dart';
import 'package:urbantutorsapp/services/get_subject_services.dart';

class GetSubjectController extends GetxController {
  final GetSubjectServices
  getSubjectServices = GetSubjectServices();

  var isLoading = false.obs;
  var subjectList = <SubjectData>[].obs;

  Future<void> fetchSubjects() async {
    isLoading.value = true;

    try {
      print('Fetching class data from controller...');
      final response = await
      getSubjectServices.fetchSubjects();

      if (response.success) {
        subjectList.value = response.data;
        Get.snackbar('Success', response.message);
        print(response.data);
      } else {
        Get.snackbar('Failed', response.message);
        print("Failed to fetch subject data");
        print(response.message);
      }
    } catch (e){
      print("ErrorFromGetSubjectController");
      print(e.toString());
      Get.snackbar('Error', e.toString());
    } finally {
      isLoading.value = false;  
    }
  }
}