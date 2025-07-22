import 'package:get/get.dart';
import 'package:urbantutorsapp/models/get_chapter_model.dart';
import 'package:urbantutorsapp/services/get_chapter_services.dart';

class GetChapterController extends GetxController {
  final GetChapterServices getChapterServices = GetChapterServices();

  var isLoading = false.obs;
  var chapterList = <ChapterData>[].obs;

  @override
  void onInit() {
    super.onInit();
    fetchChapterData(); // call the method when controller is initialized
  }

  Future<void> fetchChapterData() async {
    isLoading.value = true;

    try {
      print('Fetching chapter data from controller...');
      final response = await getChapterServices.fetchChapters();

      if (response.success) {
        chapterList.value = response.data;
        Get.snackbar('Success', response.message);
        print(response.data);
      } else {
        Get.snackbar('Failed', response.message);
        print("Failed to fetch chapter data");
        print(response.message);
      }
    } catch (e) {
      print("ErrorFromChapterController");
      print(e.toString());
      Get.snackbar('Error', e.toString());
    } finally {
      isLoading.value = false;
    }
  }
}
