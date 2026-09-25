import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:urbantutorsapp/controllers/auth_controller.dart';
import 'package:urbantutorsapp/models/user_new_modal.dart';

import 'package:urbantutorsapp/utils/home_router.dart';
import 'package:urbantutorsapp/utils/session.dart';
import '../../theme/theme_constants.dart';

class OTPScreen extends StatefulWidget {
  final String phone;
  final String role;
  final int roleId;
  final String otp;
  final String name;

  const OTPScreen({
    super.key,
    required this.phone,
    required this.role,
    required this.roleId,
    required this.otp,
    required this.name,
  });

  @override
  State<OTPScreen> createState() => _OTPScreenState();
}

class _OTPScreenState extends State<OTPScreen> {
  String otp = '';
  bool isResending = false;
  bool isVerifying = false;
  final TextEditingController _otpController = TextEditingController();
  final AuthController auth = Get.find<AuthController>();
  
  @override
  void dispose() {
    _otpController.dispose();
    super.dispose();
  }
  Future<void> _verifyOtp() async {
    if (isVerifying) return;
    setState(() => isVerifying = true);
    final prefs = await SharedPreferences.getInstance();
    final name = widget.name.isNotEmpty
        ? widget.name
        : (prefs.getString('reg_name') ?? 'User');
    final firebaseToken = 'dummy_token';
    try {
      LoginResponse loginResponse = await auth.verifyOtp(
          widget.phone, otp, name, widget.roleId.toString(), firebaseToken);
      if (!mounted) return;

      // Check if the response is successful and data is not null
      if (loginResponse.success && loginResponse.data != null) {
        await prefs.setString(
            "userData", jsonEncode(loginResponse.data!.toJson()));
        final roleId = loginResponse.data!.userData!.roles[0].roleId;
        final profileStatus = loginResponse.data!.userData!.profileStatus ?? 0;
        // Start the new session with fresh controllers (no cached data from
        // before login).
        await Session.resetControllers();
        if (!mounted) return;
        
        final dashboard = homeScreenFor(roleId, profileStatus);

        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => dashboard),
          (route) => false,
        );
      } else {
        // Handle error cases (expired OTP, invalid OTP, etc.)
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(loginResponse.message),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
        
        // Clear the OTP field
        _otpController.clear();
        setState(() {
          otp = '';
          isVerifying = false;
        });
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString()),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 3),
        ),
      );
      
      // Clear the OTP field
      _otpController.clear();
      setState(() {
        otp = '';
        isVerifying = false;
      });
    }
  }

  Future<void> _resendCode() async {
    if (isResending) return;
    setState(() => isResending = true);
    final sent = widget.name.isNotEmpty
        ? await auth.sendOtp(widget.phone,
            name: widget.name, roleId: widget.roleId)
        : await auth.sendOtpForLogin(widget.phone, roleId: widget.roleId);
    if (!mounted) return;
    setState(() => isResending = false);
    if (sent) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('OTP resent')),
      );
    }
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
                      text: '+91${widget.phone}',
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
                controller: _otpController,
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
                onPressed:
                    otp.length == 6 && !isVerifying ? _verifyOtp : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      otp.length == 6 ? primary : primary.withValues(alpha: 0.4),
                  minimumSize: const Size.fromHeight(50),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                ),
                child: isVerifying
                    ? const SizedBox(
                        height: 22,
                        width: 22,
                        child: CircularProgressIndicator(
                            strokeWidth: 2.5, color: Colors.white),
                      )
                    : const Text('Verify OTP', style: TextStyle(fontSize: 16)),
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
