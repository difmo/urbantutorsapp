import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:urbantutorsapp/models/lead__model.dart';
import 'package:urbantutorsapp/services/lead_service.dart';

class LeadController extends GetxController {
  final LeadService leadService = LeadService();

  var isLoading = false.obs;
  var studentLeads = <StudentLead>[].obs;

  Future<void> fetchLeads() async {
    isLoading.value = true;

    try {
      final response = await leadService.getLeads();
   
      studentLeads.assignAll(response.data);
      
      print("fromLeadcontroller");
   print(studentLeads);
    }catch (e){
      print("ErrorFromLeadController");
      print(e.toString());
      Get.snackbar('Error', e.toString());
    }
    finally{
      isLoading.value = false;
    }
  }
}