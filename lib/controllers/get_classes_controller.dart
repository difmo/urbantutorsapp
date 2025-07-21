import 'package:get/get.dart';
import 'package:urbantutorsapp/models/get_classes_model.dart';
import 'package:urbantutorsapp/services/get_classes_services.dart';

class GetClassesController extends GetxController {
  final GetClassesService getClassesService = GetClassesService();

  var isLoading = false.obs;
  var classList = <ClassData>[].obs;

  Future<void> fetchClasses() async {
    isLoading.value = true;

    try {
      print('Fetching class data from controller...');
      final response = await getClassesService.fetchClasses();

      if (response.success) {
        classList.value = response.data;
        Get.snackbar('Success', response.message);
        print("Class data fetched successfully:");
        print(response.data);
      } else {
        Get.snackbar('Failed', response.message);
        print("Failed to fetch class data:");
        print(response.message);
      }
    } catch (e) {
      print("ErrorFromGetClassesController");
      print(e.toString());
      Get.snackbar('Error', e.toString());
    } finally {
      isLoading.value = false;
    }
  }
}
