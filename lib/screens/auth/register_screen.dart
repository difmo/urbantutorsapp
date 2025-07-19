import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:urbantutorsapp/controllers/AuthController.dart';
import 'package:urbantutorsapp/services/auth_service.dart';
import 'package:urbantutorsapp/services/profile_services.dart';
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
  final AuthService authService =Get.put( AuthService());
  final ProfileService authService1 =Get.put( ProfileService());
  final AuthController auth = Get.put(AuthController());
  
// inside _sendOtp method
Future<void> _sendOtp() async {
  print("fhfg");
   print(_phoneController.text);
  if (_formKey.currentState!.validate()) {
    print(_phoneController.text);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('reg_name', _nameController.text.trim());
    await prefs.setString('reg_phone', _phoneController.text.trim());

    try {
print(_phoneController.text);
      final otp = await auth.sendOtp(_phoneController.text.trim());
print(_phoneController.text);
      if (otp != null) {
        debugPrint('🔐 OTP for testing: $otp');

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => OTPScreen(
              role: widget.role,
              phone: _phoneController.text.trim(),
              otp: otp, // Pass to OTPScreen for dev
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
                  FaIcon(
                    FontAwesomeIcons.userPlus,
                    size: 60,
                    color: AppColors.primaryColor,
                  ),
                  const SizedBox(height: 24),
                  CustomInputField(
                    controller: _nameController,
                    label: 'Full Name',
                    icon: FontAwesomeIcons.user,
                    validator: (v) =>
                        v == null || v.trim().isEmpty ? 'Required' : null,
                  ),
                  const SizedBox(height: 16),
                  CustomInputField(
                    controller: _phoneController,
                    label: 'Mobile Number',
                    icon: FontAwesomeIcons.mobileAlt,
                    keyboardType: TextInputType.phone,
                    maxLength: 10,
                    validator: (v) => v == null || v.trim().length != 10
                        ? 'Enter valid 10-digit mobile number'
                        : null,
                  ),
                  const SizedBox(height: 24),
                  CustomButton(
                    label: 'Register',
                    onPressed: _sendOtp,
                    icon: Icons.check,
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
