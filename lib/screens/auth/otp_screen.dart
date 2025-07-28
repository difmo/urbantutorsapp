import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:urbantutorsapp/controllers/AuthController.dart';

import 'package:urbantutorsapp/screens/admin/admin_dashboard..dart';
import 'package:urbantutorsapp/screens/student/student_dashboard.dart';
import 'package:urbantutorsapp/screens/tutor/tutor_dashboard.dart';
import 'package:urbantutorsapp/shared/default_dashboard.dart';
import '../../theme/theme_constants.dart';

class OTPScreen extends StatefulWidget {
  final String phone;
  final String role;
  final String otp;

  const OTPScreen({super.key, required this.phone, required this.role, required this.otp});

  @override
  State<OTPScreen> createState() => _OTPScreenState();
}

class _OTPScreenState extends State<OTPScreen> {
  String otp = '';
  bool isResending = false;

 Future<void> _verifyOtp() async {
  final prefs = await SharedPreferences.getInstance();
  final name = prefs.getString('reg_name') ?? 'User';
  final role = widget.role.toLowerCase();
  final firebaseToken = 'dummy_token'; // Replace with actual FCM token
  final roleId = role == 'student' ? '3' : role == 'tutor' ? '2' : '1';

  try {
    final auth = Get.find<AuthController>();
    print('skdlu');
    await auth.verifyOtp(widget.phone, otp, name, roleId, firebaseToken);
    print('mera');
    Widget dashboard;
    switch (role) {
      case 'admin':
        dashboard = const AdminDashboard();
        break;
      case 'tutor':
        dashboard = const TutorDashboard();
        break;
      case 'student':
        dashboard = const StudentDashboardScreen();
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
      SnackBar(content: Text(e.toString())),
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
                    //   TextSpan(
                    //   text: '+91-${widget.otp}',
                    //   style: TextStyle(
                    //     color: primary,
                    //     fontWeight: FontWeight.bold,
                    //   ),
                    // )
                  ],
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
          
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
              ElevatedButton(
                onPressed: otp.length == 6 ? _verifyOtp : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: otp.length == 6 ? primary : primary.withOpacity(0.4),
                  minimumSize: const Size.fromHeight(50),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                child: const Text('Verify OTP', style: TextStyle(fontSize: 16)),
              ),
          
              const SizedBox(height: 16),
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
