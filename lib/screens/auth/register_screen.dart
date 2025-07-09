import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'otp_screen.dart';
import '../../theme/theme_constants.dart';

class RegisterScreen extends StatefulWidget {
  final String role;

  const RegisterScreen({super.key, required this.role});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _mobileController = TextEditingController();

  void _sendOtp() async {
    if (_formKey.currentState!.validate()) {
      final name = _nameController.text.trim();
      final phone = _mobileController.text.trim();

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('reg_name', name);
      await prefs.setString('reg_phone', phone);

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => OTPScreen(phone: phone, role: widget.role),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final roleTitle = widget.role[0].toUpperCase() + widget.role.substring(1);

    return Scaffold(
      appBar: AppBar(title: Text('$roleTitle Registration')),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.app_registration, size: 60, color: AppColors.primaryColor),
              const SizedBox(height: 20),

              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Full Name',
                  prefixIcon: Icon(Icons.person),
                ),
                validator: (value) =>
                    value == null || value.isEmpty ? 'Enter your name' : null,
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _mobileController,
                keyboardType: TextInputType.phone,
                maxLength: 10,
                decoration: const InputDecoration(
                  labelText: 'Mobile Number',
                  prefixIcon: Icon(Icons.phone),
                ),
                validator: (value) =>
                    value == null || value.length != 10
                        ? 'Enter a valid 10-digit number'
                        : null,
              ),
              const SizedBox(height: 24),

              ElevatedButton(
                onPressed: _sendOtp,
                child: const Text('Register & Send OTP'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
