import 'package:urbantutorsapp/screens/controllers/masterdata_modal.dart';
import 'package:urbantutorsapp/services/ApiService.dart';

class GetMasterdataService {
  Future<MasterDataResponse> getMasterData() async {
    try {
      final response = await ApiService.post('/master_data', null);
      return MasterDataResponse.fromJson(response.data);
    } catch (e) {
      throw Exception("Failed to fetch master data: $e");
    }
  }
}
