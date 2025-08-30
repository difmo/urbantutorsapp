import 'package:get/get.dart';
import 'package:urbantutorsapp/screens/controllers/masterdata_modal.dart';
import 'package:urbantutorsapp/services/get_masterdata_service.dart';

class MasterDataController extends GetxController {
  var isLoading = false.obs;
  var masterData = Rxn<MasterDataResponse>();
  var errorMessage = ''.obs;

  final GetMasterdataService _service = GetMasterdataService();

  Future<void> fetchMasterData() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      final data = await _service.getMasterData();
      masterData.value = data;
    } catch (e) {
      errorMessage.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }
}
