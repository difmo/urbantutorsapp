import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:urbantutorsapp/controllers/auth_controller.dart';
import 'package:urbantutorsapp/controllers/profile_update_controller.dart';

import 'package:urbantutorsapp/screens/admin/admin_dashboard.dart';
import 'package:urbantutorsapp/screens/student/student_dashboard.dart';
import 'package:urbantutorsapp/screens/student/student_profile_form.dart';
import 'package:urbantutorsapp/screens/tutor/pending_page.dart';
import 'package:urbantutorsapp/screens/tutor/tutor_profile_form.dart';
import 'package:urbantutorsapp/screens/tutor/tutor_dashboard.dart';
import 'package:urbantutorsapp/shared/default_dashboard.dart';
import 'package:urbantutorsapp/utils/storage_helper.dart';
import '../../theme/theme_constants.dart';

class OTPScreen extends StatefulWidget {
  final String phone;
  final String role;
  final int roleId;
  final String otp;

  const OTPScreen({
    super.key,
    required this.phone,
    required this.role,
    required this.roleId,
    required this.otp,
  });

  @override
  State<OTPScreen> createState() => _OTPScreenState();
}

class _OTPScreenState extends State<OTPScreen> {
  String otp = '';
  bool isResending = false;
  final ProfileUpdateController _profileUpdateController =
      Get.put(ProfileUpdateController());

  Future<void> _initProfile() async {
    await _profileUpdateController.fetchProfileForTutor();

    if (_profileUpdateController
            .tutorprofileData.value?.mostExperienceSubjectName !=
        null) {
      StorageService.saveIsProfileStatus("completed");
    }
  }

  Future<bool> isProfiledataEmpty() async {
    await _profileUpdateController.fetchProfileForStudent();
    if (_profileUpdateController.studentprofileData.value!.boardName!.isEmpty) {
      return true;
    } else {
      return false;
    }
  }

  Future<void> _verifyOtp() async {
    final prefs = await SharedPreferences.getInstance();
    final name = prefs.getString('reg_name') ?? 'User';
    final role = widget.roleId;
    final firebaseToken = 'dummy_token';
    print("otp screen");
    print(widget.role);
    // print(r)
    final bool isTeacherFormFilled = false;
    final bool isStudentFormFilled = false;
    final bool isVerified = false;

    try {
      final auth = Get.find<AuthController>();

      int roleId = await auth.verifyOtp(
          widget.phone, otp, name, widget.roleId.toString(), firebaseToken);

      final userData = {
        "phone": widget.phone,
        "role": role,
        "name": name,
      };
      if (roleId == 2) {
        _initProfile();
      }
      prefs.setString("userData", jsonEncode(userData));

      final String? profileStatus = await StorageService.getIsProfileStatus();

      Widget dashboard;
      print("rolieddddddd otp time $roleId");
      print("profilestatusssss otp time $profileStatus");

      switch (roleId) {
        case 3:
          if (profileStatus == "pending") {
            dashboard = PendingPage();
          } else if (profileStatus == "completed") {
            dashboard = StudentDashboardScreen();
          } else {
            dashboard = StudentProfileFormScreen();
          }
          break;
        case 2:
          dashboard = profileStatus == null || profileStatus == "pending"
              ? profileStatus == "pending"
                  ? PendingPage()
                  : TutorProfileFormScreen()
              : TutorDashboard();
          break;

        case 5:
          dashboard = const AdminDashboard();
          break;
        default:
          dashboard = const DefaultDashboardScreen();
      }

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => dashboard),
        (route) => false,
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("OTP verification failed: $e")),
      );
    }
  }

  void _resendCode() {
    setState(() => isResending = true);
    Future.delayed(const Duration(seconds: 2), () {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('OTP resent')),
      );
      setState(() => isResending = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    final primary = AppColors.primaryColor;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Verify OTP'),
        backgroundColor: primary,
        elevation: 1,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 36),
        child: SingleChildScrollView(
          child: Column(
            children: [
              const Text(
                'Verification Code',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              RichText(
                text: TextSpan(
                  text: 'Enter the code sent to ',
                  style: const TextStyle(color: Colors.black87, fontSize: 16),
                  children: [
                    TextSpan(
                      text: '+91-${widget.phone}',
                      style: TextStyle(
                        color: primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),

              /// OTP Input
              PinCodeTextField(
                appContext: context,
                length: 6,
                keyboardType: TextInputType.number,
                animationType: AnimationType.fade,
                autoFocus: true,
                cursorColor: primary,
                enableActiveFill: true,
                onChanged: (value) => setState(() => otp = value),
                pinTheme: PinTheme(
                  shape: PinCodeFieldShape.box,
                  borderRadius: BorderRadius.circular(10),
                  fieldHeight: 50,
                  fieldWidth: 45,
                  activeColor: primary,
                  selectedColor: primary,
                  inactiveColor: Colors.grey.shade300,
                  activeFillColor: Colors.white,
                  selectedFillColor: Colors.white,
                  inactiveFillColor: Colors.grey.shade100,
                ),
              ),
              const SizedBox(height: 30),

              /// Verify Button
              ElevatedButton(
                onPressed: otp.length == 6 ? _verifyOtp : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      otp.length == 6 ? primary : primary.withOpacity(0.4),
                  minimumSize: const Size.fromHeight(50),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                ),
                child: const Text('Verify OTP', style: TextStyle(fontSize: 16)),
              ),
              const SizedBox(height: 16),

              /// Resend OTP
              isResending
                  ? const CircularProgressIndicator()
                  : TextButton(
                      onPressed: _resendCode,
                      child: Text(
                        'Resend Code',
                        style: TextStyle(
                            color: primary, fontWeight: FontWeight.w600),
                      ),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
