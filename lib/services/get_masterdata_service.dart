import 'package:urbantutorsapp/screens/controllers/masterdata_modal.dart';
import 'package:urbantutorsapp/services/ApiService.dart';
import 'package:urbantutorsapp/utils/api_config.dart';
import 'package:urbantutorsapp/utils/app_log.dart';

class GetMasterdataService {
  Future<MasterDataResponse> getMasterData() async {
    try {
      final response = await ApiService.get(ApiConfig.masterData);
      AppLog.s('Master Data loaded successfully', name: 'MD');
      return MasterDataResponse.fromJson(response.data);
    } catch (e) {
      throw ApiException("Failed to fetch master data: $e");
    }
  }
}
