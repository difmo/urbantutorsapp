import 'package:get/get.dart';
import 'package:urbantutorsapp/models/lead_create_model_request.dart';
import 'package:urbantutorsapp/services/api_exception.dart';
import 'package:urbantutorsapp/services/lead_create_service.dart';

class LeadCreateController extends GetxController {
  final LeadCreateService leadCreateService = LeadCreateService();

  var isSubmitting = false.obs;

  /// Creates or updates a lead and returns the server's success message.
  /// Throws [ApiException] when the server rejects the request.
  Future<String> createOrUpdateLead(LeadCreateRequest request) async {
    isSubmitting.value = true;
    try {
      final response = await leadCreateService.createOrUpdateLead(
        name: request.name,
        mobile: request.mobile,
        boardId: request.boardId,
        classId: request.classId,
        location: request.location,
        mode: request.mode,
        fee: request.fee,
        leadId: request.leadId,
        subjectId: request.subjectId,
        userId: request.userId,
        place_id: request.place_id,
        pincode: request.pincode,
        latitude: request.latitude,
        longitude: request.longitude,
        leadCount: request.maxHits,
        coins: request.coins,
        remark: request.remark,
        state: request.state,
      );
      final body = response.data;
      final message = body is Map ? body['message']?.toString() : null;
      if (response.statusCode == 200 && body is Map && body['success'] == true) {
        return message ?? 'Lead saved successfully';
      }
      throw ApiException(message ?? 'Could not save the lead. Please try again.',
          statusCode: response.statusCode);
    } finally {
      isSubmitting.value = false;
    }
  }
}
