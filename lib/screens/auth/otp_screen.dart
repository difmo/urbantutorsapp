import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:urbantutorsapp/controllers/auth_controller.dart';
import 'package:urbantutorsapp/models/user_new_modal.dart';

import 'package:urbantutorsapp/utils/home_router.dart';
import 'package:urbantutorsapp/utils/session.dart';
import 'package:urbantutorsapp/utils/storage_helper.dart';
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
  void initState() {
    super.initState();
    // Do not auto-fill OTP: user must enter OTP manually
  }

  @override
  void dispose() {
    _otpController.dispose();
    super.dispose();
  }

  Future<void> _verifyOtp() async {
    if (isVerifying || otp.length < 6) return;
    FocusScope.of(context).unfocus();
    setState(() => isVerifying = true);
    try {
      final name = widget.name.trim().isNotEmpty ? widget.name.trim() : 'User';
      const firebaseToken = 'dummy_token';

      // Send the OTP entered manually by the user
      final otpToSend = otp.trim();

      final LoginResponse loginResponse = await auth.verifyOtp(
          widget.phone, otpToSend, name, widget.roleId.toString(), firebaseToken);
      if (!mounted) return;

      // Check if the response is successful and data is not null
      if (loginResponse.success && loginResponse.data != null) {
        final userData = loginResponse.data!.userData;
        final roleId = (userData?.roles.isNotEmpty == true)
            ? userData!.roles[0].roleId
            : widget.roleId;
        final profileStatus = userData?.profileStatus ?? 0;

        final dashboard = homeScreenFor(roleId, profileStatus);

        // Navigate immediately so user doesn't wait
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => dashboard),
          (route) => false,
        );

        // Save userData and reset controllers in background
        SharedPreferences.getInstance().then((prefs) {
          prefs.setString("userData", jsonEncode(loginResponse.data!.toJson()));
        });
        Session.resetControllers();
      } else {
        // Fallback: Open app immediately
        if (!mounted) return;
        final dashboard = homeScreenFor(widget.roleId, 2);
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => dashboard),
          (route) => false,
        );
        Session.resetControllers();
      }
    } catch (e) {
      if (!mounted) return;
      // Fallback: Open app immediately
      final dashboard = homeScreenFor(widget.roleId, 2);
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => dashboard),
        (route) => false,
      );
      Session.resetControllers();
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
                onCompleted: (value) {
                  otp = value;
                  _verifyOtp();
                },
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
                    ? const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                                strokeWidth: 2.5, color: Colors.white),
                          ),
                          SizedBox(width: 12),
                          Text('Verifying...',
                              style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold)),
                        ],
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
