import 'package:get/get.dart';
import 'package:urbantutorsapp/models/get_classes_model.dart';
import 'package:urbantutorsapp/services/get_classes_services.dart';

class GetClassesController extends GetxController {
  final GetClassesService getClassesService = GetClassesService();

  var isLoading = false.obs;
  var classList = <ClassData>[].obs;

  

  /// Call this method with a valid boardId (e.g. 1, 2, etc.)
  Future<void> fetchClasses({required int boardId}) async {
    isLoading.value = true;

    try {
      print('📡 Fetching class data for boardId: $boardId');

      final response = await getClassesService.fetchClasses(boardId: boardId);

      if (response.success) {
        classList.value = response.data;

        // ✅ Debug output
        print("✅ Class data fetched successfully:");
        for (var cls in classList) {
          print("Class ID: ${cls.id}, Class Name: ${cls.name}");
        }

      } else {
        Get.snackbar('Failed', response.message);
        print("❌ Failed: ${response.message}");
      }
    } catch (e) {
      print("❌ Error in GetClassesController:");
      print(e.toString());
      Get.snackbar('Error', e.toString());
    } finally {
      isLoading.value = false;
    }
  }
}
