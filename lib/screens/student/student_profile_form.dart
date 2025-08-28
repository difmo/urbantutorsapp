import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

import 'package:urbantutorsapp/controllers/student_update_profile_controller.dart';
import 'package:urbantutorsapp/models/student_update_profile_model.dart';

import 'package:urbantutorsapp/screens/student/student_dashboard.dart';
import 'package:urbantutorsapp/utils/storage_helper.dart';

class StudentProfileFormScreen extends StatefulWidget {
  const StudentProfileFormScreen({super.key});

  @override
  State<StudentProfileFormScreen> createState() =>
      _StudentProfileFormScreenState();
}

class _StudentProfileFormScreenState extends State<StudentProfileFormScreen> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController localityController = TextEditingController();
  final TextEditingController remarkController = TextEditingController();
  final TextEditingController priceController = TextEditingController();

  String? selectedGender;
  String? selectedState;
  String? selectedClass;
  String? selectedMode;
  String? selectedSubject;
  String? selectedBoard;
  String? selectedIdType;

  final ImagePicker _picker = ImagePicker();
  XFile? _profileImage;
  XFile? _frontIdImage;
  XFile? _backIdImage;

  final StudentProfileController profileController =
      Get.put(StudentProfileController());

  // Pick image from gallery/camera
  Future<void> _pickImage(ImageSource source, String type) async {
    final picked = await _picker.pickImage(source: source);
    if (picked != null) {
      setState(() {
        if (type == "profile") _profileImage = picked;
        if (type == "front") _frontIdImage = picked;
        if (type == "back") _backIdImage = picked;
      });
    }
    Navigator.pop(context);
  }

  void _showPickerOptions(String type) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text("Camera"),
              onTap: () => _pickImage(ImageSource.camera, type),
            ),
            ListTile(
              leading: const Icon(Icons.photo),
              title: const Text("Gallery"),
              onTap: () => _pickImage(ImageSource.gallery, type),
            ),
          ],
        ),
      ),
    );
  }

  // Convert image to Base64
  Future<String?> _fileToBase64(XFile? file) async {
    if (file == null) return null;
    final bytes = await File(file.path).readAsBytes();
    return "data:image/${file.path.split('.').last};base64,${base64Encode(bytes)}";
  }

  // Save Profile
  Future<void> onSavePressed() async {
    final profileBase64 = await _fileToBase64(_profileImage);
    final frontBase64 = await _fileToBase64(_frontIdImage);
    final backBase64 = await _fileToBase64(_backIdImage);

    final request = StudentProfileUpdateRequest(
      userId: 23, // TODO: dynamic from login
      boardId: 6, // TODO: dynamic mapping
      courseId: 8,
      subjectId: 9,
      price: int.tryParse(priceController.text) ?? 0,
      location: localityController.text,
      state: selectedState ?? "",
      idType: selectedIdType ?? "",
      remark: remarkController.text,
      profilePicture: profileBase64!,
      frontId: frontBase64!,
      frontBack: backBase64!,
    );

    await profileController.updateProfile(request);

    if (profileController.errorMessage.value.isEmpty) {
      TokenStorage.saveIsProfileActive("done");
      Get.offAll(() => const StudentDashboardScreen());
    } else {
      Get.snackbar("Error", profileController.errorMessage.value,
          snackPosition: SnackPosition.BOTTOM);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Student Profile"),
        backgroundColor: Theme.of(context).primaryColor,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /// Profile Image + Name
              Row(
                children: [
                  Stack(
                    children: [
                      CircleAvatar(
                        radius: 40,
                        backgroundImage: _profileImage != null
                            ? FileImage(File(_profileImage!.path))
                            : null,
                        backgroundColor: Colors.grey.shade300,
                        child: _profileImage == null
                            ? const Icon(Icons.person,
                                size: 50, color: Colors.white)
                            : null,
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: InkWell(
                          onTap: () => _showPickerOptions("profile"),
                          child: const CircleAvatar(
                            radius: 14,
                            backgroundColor: Colors.blue,
                            child: Icon(Icons.camera_alt,
                                size: 16, color: Colors.white),
                          ),
                        ),
                      )
                    ],
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      controller: nameController,
                      decoration:
                          const InputDecoration(labelText: "Full Name"),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              TextField(
                controller: emailController,
                decoration: const InputDecoration(labelText: "Email"),
              ),
              const SizedBox(height: 16),

              TextField(
                controller: localityController,
                decoration: const InputDecoration(labelText: "Locality"),
              ),
              const SizedBox(height: 16),

              DropdownButtonFormField<String>(
                decoration: const InputDecoration(labelText: "Class"),
                value: selectedClass,
                items: ["Class 6", "Class 7", "Class 8", "Class 9", "Class 10"]
                    .map((c) =>
                        DropdownMenuItem(value: c, child: Text(c)))
                    .toList(),
                onChanged: (val) => setState(() => selectedClass = val),
              ),
              const SizedBox(height: 16),

              DropdownButtonFormField<String>(
                decoration: const InputDecoration(labelText: "Subject"),
                value: selectedSubject,
                items: ["Maths", "Science", "English"]
                    .map((s) =>
                        DropdownMenuItem(value: s, child: Text(s)))
                    .toList(),
                onChanged: (val) => setState(() => selectedSubject = val),
              ),
              const SizedBox(height: 16),

              DropdownButtonFormField<String>(
                decoration: const InputDecoration(labelText: "Board"),
                value: selectedBoard,
                items: ["CBSE", "ICSE", "STATE BOARD"]
                    .map((b) =>
                        DropdownMenuItem(value: b, child: Text(b)))
                    .toList(),
                onChanged: (val) => setState(() => selectedBoard = val),
              ),
              const SizedBox(height: 16),

              DropdownButtonFormField<String>(
                decoration: const InputDecoration(labelText: "State"),
                value: selectedState,
                items: ["Delhi", "UP", "Haryana"]
                    .map((st) =>
                        DropdownMenuItem(value: st, child: Text(st)))
                    .toList(),
                onChanged: (val) => setState(() => selectedState = val),
              ),
              const SizedBox(height: 16),

              TextField(
                controller: priceController,
                decoration:
                    const InputDecoration(labelText: "Budget (Price)"),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 16),

              DropdownButtonFormField<String>(
                decoration: const InputDecoration(labelText: "ID Type"),
                value: selectedIdType,
                items: ["Aadhar", "PAN", "Voter ID"]
                    .map((id) =>
                        DropdownMenuItem(value: id, child: Text(id)))
                    .toList(),
                onChanged: (val) => setState(() => selectedIdType = val),
              ),
              const SizedBox(height: 16),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _idUploadBox("Front ID", _frontIdImage, "front"),
                  _idUploadBox("Back ID", _backIdImage, "back"),
                ],
              ),
              const SizedBox(height: 24),

              TextField(
                controller: remarkController,
                decoration:
                    const InputDecoration(labelText: "Remarks"),
              ),
              const SizedBox(height: 24),

              Center(
                child: ElevatedButton(
                  onPressed: onSavePressed,
                  child: const Text("Save Profile"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _idUploadBox(String label, XFile? file, String type) {
    return Column(
      children: [
        Text(label),
        const SizedBox(height: 6),
        GestureDetector(
          onTap: () => _showPickerOptions(type),
          child: Container(
            width: 120,
            height: 100,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey),
              borderRadius: BorderRadius.circular(8),
            ),
            child: file == null
                ? const Icon(Icons.image,
                    size: 40, color: Colors.black54)
                : ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.file(File(file.path),
                        fit: BoxFit.cover),
                  ),
          ),
        ),
      ],
    );
  }
}
