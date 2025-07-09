import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:urbantutors_app/screens/admin/admin_dashboard..dart';
import 'package:urbantutors_app/screens/student/student_dashboard.dart';
import 'package:urbantutors_app/screens/tutor/tutor_dashboard.dart';
import 'package:urbantutors_app/shared/default_dashboard.dart';


import '../../theme/theme_constants.dart';

class OTPScreen extends StatefulWidget {
  final String phone;
  final String role;

  const OTPScreen({super.key, required this.phone, required this.role});

  @override
  State<OTPScreen> createState() => _OTPScreenState();
}

class _OTPScreenState extends State<OTPScreen> {
  final TextEditingController _otpController = TextEditingController();

  void _verifyOtp() async {
    if (_otpController.text == '123456') {
      final prefs = await SharedPreferences.getInstance();
      final name = prefs.getString('reg_name') ?? 'User';
      await prefs.setBool('isLoggedIn', true);
      await prefs.setString('user_name', name);
      await prefs.setString('user_phone', widget.phone);
      await prefs.setString('user_role', widget.role);

      // Navigate to correct dashboard
      Widget dashboard;
      switch (widget.role.toLowerCase()) {
        case 'admin':
          dashboard = const AdminDashboardScreen();
          break;
        case 'tutor':
          dashboard = const TutorDashboardScreen();
          break;
        case 'student':
          dashboard =  StudentDashboardScreen();
          break;
        default:
          dashboard = const DefaultDashboardScreen();
      }

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => dashboard),
        (route) => false,
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Invalid OTP. Try using 123456')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Verify OTP')),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Enter OTP sent to +91-${widget.phone}'),
            const SizedBox(height: 20),

            TextField(
              controller: _otpController,
              keyboardType: TextInputType.number,
              maxLength: 6,
              decoration: const InputDecoration(
                labelText: 'Enter 6-digit OTP',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),

            ElevatedButton(
              onPressed: _verifyOtp,
              child: const Text('Verify OTP'),
            ),
          ],
        ),
      ),
    );
  }
}
