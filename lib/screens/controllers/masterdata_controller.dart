// masterdata_controller.dart
import 'package:get/get.dart';
import 'package:urbantutorsapp/screens/controllers/masterdata_modal.dart';
import 'package:urbantutorsapp/services/get_masterdata_service.dart';
import 'package:urbantutorsapp/utils/app_log.dart';

class MasterDataController extends GetxController {
  final isLoading = false.obs;
  final masterData = Rxn<MasterDataResponse>();
  final errorMessage = ''.obs;

  final GetMasterdataService _service = GetMasterdataService();

  @override
  void onInit() {
    super.onInit();
    AppLog.i('[MD] onInit');
    fetchMasterData();                      // <-- auto-fetch
    ever(masterData, (val) {
      AppLog.i('[MD] masterData updated: boards=${val?.data?.boardLead?.length ?? 0}');
    });
  }

  Future<void> fetchMasterData() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';
      AppLog.i('[MD] Fetching master data…');

      final data = await _service.getMasterData();
      masterData.value = data;

      AppLog.i('[MD] Fetch success. boards=${data.data?.boardLead?.length ?? 0}');
    } catch (e, st) {
      errorMessage.value = e.toString();
      AppLog.e('[MD] Fetch failed', error: e, st: st);
    } finally {
      isLoading.value = false;
      AppLog.i('[MD] isLoading=false');
    }
  }
}
