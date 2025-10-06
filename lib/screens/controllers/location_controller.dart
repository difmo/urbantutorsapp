import 'package:get/get.dart';
import 'package:urbantutorsapp/services/location_service.dart';
import 'package:urbantutorsapp/utils/app_log.dart';

class LocationController extends GetxController {
  final _svc = LocationService();

  final isSearching = false.obs;
  final error = ''.obs;
  final suggestions = <String>[].obs;
  final keyword = ''.obs;

  // NEW: reactive location data
  final latitude = 0.0.obs;
  final longitude = 0.0.obs;
  final placeId = ''.obs;
  final address = ''.obs;

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
      final list = await _svc.searchLocations(q);
      suggestions.assignAll(list);
      AppLog.i('[LOC] results=${list.length}');
    } catch (e, st) {
      error.value = e.toString();
      AppLog.e('[LOC] search error', error: e, st: st);
    } finally {
      isSearching.value = false;
    }
  }

  /// ✅ Get current lat/lng + place_id
  Future<void> getCurrentLocation() async {
    try {
      error.value = '';
      AppLog.i('[LOC] Getting current location...');
      // final loc = await _svc.getCurrentPosition(); // {lat, lng}
      // latitude.value = loc.latitude;
      // longitude.value = loc.longitude;
      latitude.value = 26.8604607;
      longitude.value = 81.02013;

      AppLog.i('[LOC] Coordinates: ${latitude.value}, ${longitude.value}');

      // final place = await _svc.reverseGeocode(
      //   latitude.value,
      //   longitude.value,
      // );

      // placeId.value = place['place_id'] ?? '';
      // address.value = place['formatted_address'] ?? '';

      placeId.value = "ChIJD9zE2Z2P4zsRzZtZLxQw8Yg";

      AppLog.i('[LOC] Place → id=${placeId.value}, address=${address.value}');
    } catch (e, st) {
      error.value = e.toString();
      AppLog.e('[LOC] getCurrentLocation error', error: e, st: st);
    }
  }

  @override
  void onClose() {
    _debounce?.dispose();
    super.onClose();
  }
}
