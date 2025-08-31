import 'package:get/get.dart';
import 'package:urbantutorsapp/services/location_service.dart';
import 'package:urbantutorsapp/utils/app_log.dart';

class LocationController extends GetxController {
  final _svc = LocationService();

  final isSearching = false.obs;
  final error = ''.obs;
  final suggestions = <String>[].obs;
  final keyword = ''.obs;

  Worker? _debounce;

  @override
  void onInit() {
    super.onInit();
    _debounce = debounce<String>(keyword, (q) async {
      await _search(q);
    }, time: const Duration(milliseconds: 400));
  }

  void onQueryChanged(String q) => keyword.value = q.trim();

  Future<void> _search(String q) async {
    if (q.isEmpty) {
      suggestions.clear();
      return;
    }
    isSearching.value = true;
    error.value = '';
    try {
      AppLog.i('[LOC] POST search → "$q"');
      final list = await _svc.searchLocations(q); // or .searchLocationsMultipart(q)
      suggestions.assignAll(list);
      AppLog.i('[LOC] results=${list.length}');
    } catch (e, st) {
      error.value = e.toString();
      AppLog.e('[LOC] search error', error: e, st: st);
    } finally {
      isSearching.value = false;
    }
  }

  @override
  void onClose() {
    _debounce?.dispose();
    super.onClose();
  }
}
