import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:urbantutorsapp/models/lead_create_model_request.dart';
import 'package:urbantutorsapp/services/lead_create_service.dart';

class LeadCreateController extends GetxController {
  final LeadCreateService leadCreateService = LeadCreateService();

  var isSubmitting = false.obs;

  Future<void> createOrUpdateLead(leadCreateRequest request) async {
    isSubmitting.value = true;

    print('📤 Submitting Lead with data:');
      print('name: ${request.name}');
      print('mobile: ${request.mobile}');
      print('boardId: ${request.boardId}');
      print('classId: ${request.classId}');
      print('subjectId: ${request.subjectId}');
      print('location: ${request.location}');
      print('state: ${request.state}');
      print('mode: ${request.mode}');
      print('fee: ${request.fee}');
      print('userId: ${request.userId}');
      print('leadId: ${request.leadId}');

    try {
      print('request from controller try section');
      print('classId: ${request.classId}');
      final response = await leadCreateService.createOrUpdateLead(
        name: request.name,
        mobile: request.mobile,
        boardId: '8',
        classId: '6',
        location: request.location,
        state: request.state,
        mode: request.mode,
        fee: request.fee,
        leadId:'1',
        subjectId: request.subjectId,
        userId: request.userId,
      );

      if (response.statusCode == 200 && response.data['success'] == true) {
        Get.snackbar('Success', response.data['message'] ?? 'Lead created successfully');
        print("Lead created successfully:");
        print(response.data);
      } else {
        Get.snackbar('Failed', response.data['message'] ?? 'Something went wrong');
        print("Lead creation failed:");
        print(response.data);
      }
    } catch (e) {
      print("ErrorFromLeadCreateController");
      print(e.toString());
      Get.snackbar('Error', e.toString());
    } finally {
      isSubmitting.value = false;
    }
  }
}
