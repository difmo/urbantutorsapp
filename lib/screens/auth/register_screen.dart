import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart'; // ⬅️ Added for opening link
import 'package:urbantutorsapp/controllers/AuthController.dart';
import 'package:urbantutorsapp/widgets/custom_button.dart';
import 'package:urbantutorsapp/widgets/custom_input_field.dart';
import '../../theme/theme_constants.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'otp_screen.dart';

class RegisterScreen extends StatefulWidget {
  final String role;

  const RegisterScreen({super.key, required this.role});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final AuthController auth = Get.find<AuthController>();

  bool _agreed = false; // ⬅️ New checkbox state

  Future<void> _sendOtp() async {
    if (!_agreed) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please agree to Terms & Conditions')),
      );
      return;
    }

    if (_formKey.currentState!.validate()) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('reg_name', _nameController.text.trim());
      await prefs.setString('reg_phone', _phoneController.text.trim());

      try {
        final otp = await auth.sendOtp(_phoneController.text.trim());
        if (otp != null) {
          debugPrint('🔐 OTP for testing: $otp');

          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => OTPScreen(
                role: widget.role,
                phone: _phoneController.text.trim(),
                otp: otp,
              ),
            ),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString())),
        );
      }
    }
  }

  Future<void> _openTerms() async {
    const url = 'https://urbantutors.pro/privacy-policy';
    if (await canLaunch(url)) {
      await launch(url, forceSafariVC: false, forceWebView: false);
    } else {
      throw 'Could not launch $url';
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final formattedRole =
        '${widget.role[0].toUpperCase()}${widget.role.substring(1)}';

    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.primaryColor,
        title: Text('$formattedRole Registration'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Center(
          child: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  CircleAvatar(
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
                  const SizedBox(height: 24),
                  CustomInputField(
                    controller: _nameController,
                    label: 'Full Name',
                    icon: FontAwesomeIcons.user,
                    validator: (v) =>
                        v == null || v.trim().isEmpty ? 'Required' : null,
                    labelStyle: const TextStyle(color: Colors.grey),
                  ),
                  const SizedBox(height: 16),
                  CustomInputField(
                    controller: _phoneController,
                    label: 'Mobile Number',
                    icon: FontAwesomeIcons.mobileAlt,
                    keyboardType: TextInputType.phone,
                    maxLength: 10,
                    labelStyle: const TextStyle(color: Color(0xFF9B9B9B)),
                    validator: (v) => v == null || v.trim().length != 10
                        ? 'Enter valid 10-digit mobile number'
                        : null,
                  ),
                  const SizedBox(height: 16),

                  // ✅ Terms & Conditions checkbox
                  Row(
                    children: [
                      Checkbox(
                        value: _agreed,
                        onChanged: (value) {
                          setState(() {
                            _agreed = value ?? false;
                          });
                        },
                        activeColor: AppColors.primaryColor,
                      ),
                      Expanded(
                        child: GestureDetector(
                          onTap: _openTerms,
                          child: RichText(
                            text: TextSpan(
                              style: const TextStyle(color: Colors.black87),
                              children: [
                                const TextSpan(text: 'I agree to '),
                                TextSpan(
                                  text: 'Terms & Conditions',
                                  style: const TextStyle(
                                    color: Colors.blue,
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
                  CustomButton(
                    label: 'Register',
                    onPressed: _sendOtp,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
