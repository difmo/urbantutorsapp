import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';
import 'package:urbantutorsapp/controllers/auth_controller.dart';
import 'package:url_launcher/url_launcher.dart';

import 'otp_screen.dart'; // ✅ FIX: Import your OTP screen here
import '../../theme/theme_constants.dart';

class LoginScreen extends StatefulWidget {
  final String role;
  final int roleId;

  const LoginScreen({super.key, required this.role, required this.roleId});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _phoneController = TextEditingController();

  final AuthController auth = Get.put(AuthController());

  bool _isChecked = false;

  // Show loading dialog
  void showLoadingDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => Dialog(
        backgroundColor: Colors.transparent,
        child: SizedBox(
          height: 150,
          width: 150,
          child: Lottie.asset(
            'assets/icons/animation/Insider-loading-new.json',
            fit: BoxFit.contain,
            repeat: true,
            animate: true,
            errorBuilder: (context, error, stackTrace) {
              return const Center(
                child: CircularProgressIndicator(color: AppColors.primaryColor),
              );
            },
          ),
        ),
      ),
    );
  }

  // Open Terms & Conditions URL
  Future<void> _openTerms() async {
    final Uri url = Uri.parse('https://urbantutors.pro/privacy-policy');
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not open Terms & Conditions')),
      );
    }
  }

  // Send OTP
  void _sendOtp() async {
    final phone = _phoneController.text.trim();

    if (!_isChecked) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please agree to the Terms & Conditions')),
      );
      return;
    }

    if (phone.length == 10 && RegExp(r'^[1-9]\d{9}$').hasMatch(phone)) {
      showLoadingDialog();

      try {
        Future.delayed(const Duration(seconds: 2), () async {
          final otp = await auth.sendOtp(phone);
          Navigator.of(context).pop();
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => OTPScreen(
                // ✅ This will now work because we imported otp_screen.dart
                phone: phone,
                role: widget.role,
                roleId: widget.roleId,
                otp: otp ?? "0000",
              ),
            ),
          );
        });
      } catch (e) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString())),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Please enter a valid 10-digit mobile number')),
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
        child: SingleChildScrollView(
          child: Column(
            children: [
              TweenAnimationBuilder<double>(
                tween: Tween(begin: 0, end: 1),
                duration: const Duration(milliseconds: 1000),
                builder: (_, op, ch) => Opacity(opacity: op, child: ch),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withOpacity(0.3),
                  ),
                  child: CircleAvatar(
                    radius: 40,
                    backgroundColor: Colors.transparent,
                    child: ClipOval(
                      child: Image.asset(
                        'assets/icons/urban.png',
                        width: 80,
                        height: 80,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 20),
              const Text(
                'Login with Mobile Number',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 16),

              // Phone field
              TextFormField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                maxLength: 10,
                buildCounter: (_,
                        {required int currentLength,
                        required bool isFocused,
                        required int? maxLength}) =>
                    null,
                decoration: InputDecoration(
                  labelText: 'Mobile Number',
                  labelStyle: const TextStyle(color: Color(0xFF9B9B9B)),
                  prefixIcon: const Icon(Icons.phone),
                  filled: true,
                  fillColor: Colors.transparent,
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(
                        color: const Color(0xFF9B9B9B).withOpacity(0.1)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(
                        color: AppColors.primaryColor, width: 1.5),
                  ),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10)),
                ),
              ),

              const SizedBox(height: 16),

              // Terms & Conditions checkbox
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Checkbox(
                    value: _isChecked,
                    activeColor: AppColors.primaryColor,
                    onChanged: (val) {
                      setState(() => _isChecked = val ?? false);
                    },
                  ),
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        _openTerms();
                        setState(() => _isChecked = true);
                      },
                      child: const Text.rich(
                        TextSpan(
                          children: [
                            TextSpan(
                              text: "I agree to the ",
                              style: TextStyle(color: Colors.black87),
                            ),
                            TextSpan(
                              text: "Terms & Conditions",
                              style: TextStyle(
                                color: Colors.blue,
                                decoration: TextDecoration.underline,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              ElevatedButton(
                onPressed: _sendOtp,
                child: const Text('Send OTP'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
