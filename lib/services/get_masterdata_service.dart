import 'package:urbantutorsapp/screens/controllers/masterdata_modal.dart';
import 'package:urbantutorsapp/services/ApiService.dart';
import 'package:urbantutorsapp/utils/api_config.dart';

class GetMasterdataService {
  Future<MasterDataResponse> getMasterData() async {
    try {
      final response = await ApiService.get(ApiConfig.masterData);
      print("Master Data: ${response.data}");
      return MasterDataResponse.fromJson(response.data);
    } catch (e) {
      throw ApiException("Failed to fetch master data: $e");
    }
  }
}
