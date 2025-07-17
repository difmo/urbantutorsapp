import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:urbantutorsapp/controllers/AuthController.dart';
import 'otp_screen.dart';
import '../../theme/theme_constants.dart';

class LoginScreen extends StatefulWidget {
  final String role;

  const LoginScreen({super.key, required this.role});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _phoneController = TextEditingController();
 final AuthController auth = Get.put(AuthController());
// inside _sendOtp method
void _sendOtp() async {
  final phone = _phoneController.text.trim();
  if (phone.length == 10 && RegExp(r'^[6-9]\d{9}$').hasMatch(phone)) {
    try {
     
      
      await auth.sendOtp(phone);

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => OTPScreen(phone: phone, role: widget.role, receivedOtp: '0000',),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(e.toString())));
    }
  } else {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Please enter a valid 10-digit mobile number')),
    );
  }
}


  @override
  Widget build(BuildContext context) {
    final roleTitle = widget.role[0].toUpperCase() + widget.role.substring(1);

    return Scaffold(
      appBar: AppBar(title: Text('$roleTitle Login')),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.phone_android, size: 60, color: AppColors.primaryColor),
            const SizedBox(height: 20),

            const Text(
              'Login with Mobile Number',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 16),

            TextFormField(
              controller: _phoneController,
              keyboardType: TextInputType.phone,
              maxLength: 10,
              decoration: const InputDecoration(
                labelText: 'Mobile Number',
                prefixIcon: Icon(Icons.phone),
              ),
            ),
            const SizedBox(height: 24),

            ElevatedButton(
              onPressed: _sendOtp,
              child: const Text('Send OTP'),
            ),
          ],
        ),
      ),
    );
  }
}
