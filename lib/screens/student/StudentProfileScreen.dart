import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:urbantutorsapp/controllers/AuthController.dart';

class StudentProfileScreen extends StatelessWidget {
  final AuthController authController = Get.find<AuthController>();

  StudentProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    authController.fetchProfile();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Student Profile'),
      ),
      body: Obx(() {
        final profile = authController.studentProfile.value;
        if (authController.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        } else if (profile == null) {
          return const Center(child: Text('No profile data found.'));
        } else {
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Card(
              elevation: 4,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  _buildRow('Name', profile.studentName),
                  _buildRow('Mobile', profile.mobile),
                  _buildRow('Course', profile.courseName),
                  _buildRow('Subject', profile.subjectName),
                  _buildRow('Price', '₹${profile.price}'),
                  if (profile.location != null)
                    _buildRow('Location', profile.location ?? ''),
                  _buildRow('Lead ID', profile.leadId.toString()),
                ],
              ),
            ),
          );
        }
      }),
    );
  }

  Widget _buildRow(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Text(
            '$title: ',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(color: Colors.black87),
            ),
          ),
        ],
      ),
    );
  }
}
