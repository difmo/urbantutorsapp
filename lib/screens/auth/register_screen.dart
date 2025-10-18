import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:urbantutorsapp/screens/tutor/tutor_coins_screen.dart';
import 'package:urbantutorsapp/widgets/custom_input_field2.dart';
import 'package:url_launcher/url_launcher.dart'; // ⬅️ Added for opening link
import 'package:urbantutorsapp/controllers/auth_controller.dart';
import 'package:urbantutorsapp/widgets/custom_button.dart';
import 'package:urbantutorsapp/widgets/custom_input_field.dart';
import '../../theme/theme_constants.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'otp_screen.dart';

class RegisterScreen extends StatefulWidget {
  final String role;
  final int roleId;

  const RegisterScreen({super.key, required this.role, required this.roleId});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final AuthController auth = Get.find<AuthController>();
  bool _agreed = false;
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
      print(_nameController.text.toString());
      print(_phoneController.text.toString());
      print(widget.roleId);
      print(widget.role);
      try {
        final otp = await auth.sendOtp(_phoneController.text.trim(),
            name: _nameController.text.toString(), roleId: widget.roleId);
        if (otp != null) {
          debugPrint('🔐 OTP for testing: $otp');
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => OTPScreen(
                role: widget.role,
                phone: _phoneController.text.trim(),
                roleId: widget.roleId,
                name: _nameController.text.toString(),
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
    final primary = AppColors.primaryColor;
    final accent = AppColors.accentColor;
    return Scaffold(
      appBar: AppBar(
          elevation: 0,
          backgroundColor: Colors.transparent,
          toolbarHeight: 76,
          titleSpacing: 0,
          systemOverlayStyle: const SystemUiOverlayStyle(
            statusBarColor: Colors.transparent,
            statusBarIconBrightness: Brightness.light,
            statusBarBrightness: Brightness.dark,
          ),
          flexibleSpace: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [primary, accent],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
          title: _Header(
            primary: primary,
            accent: accent,
            initial: "initial",
            greeting: "Wallet",
            name: " $formattedRole Registration",
            balance: "balanceText",
            onCoinTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const TutorCoinsScreen()),
              );
            },
          )),
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
                  CustomInputField2(
                    controller: _nameController,
                    label: "Full Name",
                    icon: Icons.person,
                    validator: (val) {
                      if (val == null || val.isEmpty)
                        return "Please enter your full name";
                      return null;
                    },
                    capitalizeEach: _capitalizeEach,
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

  String _capitalizeEach(String text) {
    return text.split(' ').map((word) {
      if (word.isEmpty) return '';
      return word[0].toUpperCase() + word.substring(1);
    }).join(' ');
  }
}

class _Header extends StatelessWidget {
  const _Header({
    required this.primary,
    required this.accent,
    required this.onCoinTap,
    required this.balance,
    required this.initial, // ⬅️ NEW
    required this.greeting, // ⬅️ NEW
    required this.name, // ⬅️ NEW
  });

  final Color primary;
  final Color accent;
  final VoidCallback onCoinTap;
  final String balance;

  final String initial;
  final String greeting;
  final String name;
  String _capFirst(String s) {
    final t = s.trim();
    if (t.isEmpty) return '';
    return t[0].toUpperCase() + t.substring(1);
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: 8,
        ),

        const SizedBox(width: 12),
        // Greeting + name (ellipsized)
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                  fontSize: 18,
                ),
              ),
            ],
          ),
        ),

        // Coins chip
        const SizedBox(width: 8),
      ],
    );
  }
}
