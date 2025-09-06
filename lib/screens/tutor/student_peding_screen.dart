import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:urbantutorsapp/controllers/profile_update_controller.dart';
import 'package:urbantutorsapp/screens/student/student_dashboard.dart';
import 'package:urbantutorsapp/theme/theme_constants.dart';
import 'package:urbantutorsapp/utils/storage_helper.dart';

class StudentPendingScreen extends StatelessWidget {
  const StudentPendingScreen({super.key});
  Future<void> _refreshProfile(BuildContext context) async {
    final controller = Get.find<ProfileUpdateController>();
    await controller.fetchProfileForStudent();
    final status = controller.studentprofileData.value?.profile_status;
    
    if (status != null && status == 2) {
      await StorageService.saveIsProfileStatus(status);
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => StudentDashboardScreen()),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Your profile is still under verification."),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.access_time,
                size: 80,
                color: AppColors.primaryColor,
              ),
              const SizedBox(height: 20),

              Text(
                "Your profile is under verification",
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textColor,
                ),
              ),
              const SizedBox(height: 10),

              Text(
                "Kindly Wait",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: AppColors.accentColor,
                ),
              ),
              const SizedBox(height: 20),

              Text(
                "Our team will verify your account within 24 hours,\nthen you can start exploring all opportunities",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.textColor.withOpacity(0.7),
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 40),

              // ✅ Refresh Button
              ElevatedButton.icon(
                onPressed: () => _refreshProfile(context),
                icon: const Icon(Icons.refresh),
                label: const Text("Refresh Status"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryColor,
                  foregroundColor: Colors.white,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
