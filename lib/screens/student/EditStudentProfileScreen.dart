// STEP 3: EDIT PROFILE SCREEN
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:urbantutorsapp/controllers/AuthController.dart';

class EditProfileScreen extends StatefulWidget {
  @override
  _EditProfileScreenState createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final AuthController authController = Get.find<AuthController>();
  final _formKey = GlobalKey<FormState>();
  late TextEditingController nameCtrl;
  late TextEditingController mobileCtrl;
  late TextEditingController courseCtrl;
  late TextEditingController subjectCtrl;
  late TextEditingController priceCtrl;
  late TextEditingController locationCtrl;


  @override
  void initState() {
    final profile = authController.studentProfile.value;
    nameCtrl = TextEditingController(text: profile?.studentName);
    mobileCtrl = TextEditingController(text: profile?.mobile);
    courseCtrl = TextEditingController(text: profile?.courseName);
    subjectCtrl = TextEditingController(text: profile?.subjectName);
    priceCtrl = TextEditingController(text: profile?.price);
    locationCtrl = TextEditingController(text: profile?.location);
    super.initState();
  }

  @override
  void dispose() {
    nameCtrl.dispose();
    mobileCtrl.dispose();
    courseCtrl.dispose();
    subjectCtrl.dispose();
    priceCtrl.dispose();
    locationCtrl.dispose();
    super.dispose();
  }

  void _submit() async {
    if (_formKey.currentState!.validate()) {
      final updatedData = {
        "student_name": nameCtrl.text,
        "mobile": mobileCtrl.text,
        "course_name": courseCtrl.text,
        "subject_name": subjectCtrl.text,
        "price": priceCtrl.text,
        "location": locationCtrl.text,
      };

      await authController.updateProfile(updatedData);
      await authController.fetchProfile();
      Get.back();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Edit Profile")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              _textField("Name", nameCtrl),
              _textField("Mobile", mobileCtrl),
              _textField("Course", courseCtrl),
              _textField("Subject", subjectCtrl),
              _textField("Price", priceCtrl),
              _textField("Location", locationCtrl),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _submit,
                child: Text("Save Changes"),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _textField(String label, TextEditingController ctrl) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: ctrl,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(),
        ),
        validator: (val) => val == null || val.isEmpty ? 'Required' : null,
      ),
    );
  }
}