import 'package:get/get.dart';
import 'package:urbantutorsapp/models/get_chapter_details_model.dart';
import 'package:urbantutorsapp/services/get_chapter_details_services.dart';

class GetChapterDetailsController extends GetxController {
  final GetChapterDetailsServices getChapterDetailsServices = GetChapterDetailsServices();

  var isLoading = false.obs;
  var chapterDetailData = Rxn<ChapterDetailsData>(); // updated type

  @override
  void onInit() {
    super.onInit();
    fetchChapterDetailsData();
  }

  Future<void> fetchChapterDetailsData() async {
    isLoading.value = true;

    try {
      print('Fetching chapter details from controller...');
      final response = await getChapterDetailsServices.fetchChaptersDetails();

      if (response.success) {
        chapterDetailData.value = response.data;
        Get.snackbar('Success', response.message);
        print(response.data);
      } else {
        Get.snackbar('Failed', response.message);
        print('Failed to fetch chapter details data');
        print(response.message);
      }
    } catch (e) {
      print("ErrorFromChapterDetailsController");
      print(e.toString());
      Get.snackbar('Error', e.toString());
    } finally {
      isLoading.value = false;
    }
  }
}
