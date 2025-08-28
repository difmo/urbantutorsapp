import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:urbantutorsapp/controllers/profile_update_controller.dart';
import 'package:urbantutorsapp/models/profile_update_request_model.dart';
import 'package:urbantutorsapp/screens/admin/admin_dashboard.dart';
import 'package:urbantutorsapp/screens/tutor/pending_page.dart';
import 'package:urbantutorsapp/utils/storage_helper.dart';

class ProfileFormScreen extends StatefulWidget {
  const ProfileFormScreen({super.key});

  @override
  State<ProfileFormScreen> createState() => _ProfileFormScreenState();
}

class _ProfileFormScreenState extends State<ProfileFormScreen> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController localityController = TextEditingController();
  final TextEditingController qualificationController = TextEditingController();
  final TextEditingController priceController = TextEditingController();

  String? selectedGender;
  String? selectedState;
  String? selectedClass;
  String? selectedMode;
  String? selectedSubject;
  String? selectedExperience;
  String? selectedIdType;
  String? selectedBoard; // ✅ Added missing variable

  final ImagePicker _picker = ImagePicker();
  XFile? _profileImage;
  XFile? _frontIdImage;
  XFile? _backIdImage;

  final ProfileUpdateController profileUpdateController =
      Get.put(ProfileUpdateController());

  // Pick image from camera/gallery
  Future<void> _pickImage(ImageSource source, String type) async {
    final pickedFile = await _picker.pickImage(source: source);
    if (pickedFile != null) {
      setState(() {
        if (type == "profile") {
          _profileImage = pickedFile;
        } else if (type == "front") {
          _frontIdImage = pickedFile;
        } else if (type == "back") {
          _backIdImage = pickedFile;
        }
      });
    }
    Navigator.pop(context);
  }

  // Bottom sheet for image picker
  void _showPickerOptions(String type) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SafeArea(
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
        );
      },
    );
  }

  // Convert File to Base64
  Future<String?> _fileToBase64(XFile? file) async {
    if (file == null) return null;
    final bytes = await File(file.path).readAsBytes();
    return "data:image/${file.path.split('.').last};base64,${base64Encode(bytes)}";
  }

  // Save / Update pressed
  Future<void> onUpdatePressed() async {
    final profileBase64 = await _fileToBase64(_profileImage);
    final frontBase64 = await _fileToBase64(_frontIdImage);
    final backBase64 = await _fileToBase64(_backIdImage);

    final request = ProfileUpdateRequest(
      userId: 1, // TODO: replace with logged-in user ID
      boardId: 6, // TODO: map dynamically
      courseId: 8,
      subjectId: 9,
      price: int.tryParse(priceController.text) ?? 0,
      location: localityController.text,
      state: selectedState ?? "",
      idType: selectedIdType ?? "",
      remark: "Experienced Teacher",
      profilePicture: profileBase64,
      frontId: frontBase64,
      backId: backBase64,
    );

    try {
      final bool success = await profileUpdateController.updateProfile(request);
      print('Error from Profile form tutor');

      if (success) {
        profileUpdateController.fetchProfileUpdate();

        if (profileUpdateController.profileData.value?.status == "Active") {
          StorageService.saveIsProfileActive("done");
          Get.offAll(() => const AdminDashboard());
        } else {
          StorageService.saveIsProfileActive("pending");
          Get.offAll(() => const PendingPage());
        }
      } else {
        Get.snackbar("Error", "Failed to update profile",
            snackPosition: SnackPosition.BOTTOM);
      }
    } catch (e) {
      print('Error from catch e in profile from tutor');
      print("Other error: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Profile"),
        backgroundColor: Theme.of(context).primaryColor,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.delete, color: Colors.white),
            onPressed: () {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: const Text('Account Delete?'),
                    content: const Text('This will delete your account'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: const Text('CANCEL'),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                          print("Account Deleted");
                        },
                        child: const Text('ACCEPT'),
                      ),
                    ],
                  );
                },
              );
            },
          ),
        ],
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
                        backgroundColor: Colors.grey.shade300,
                        backgroundImage: _profileImage != null
                            ? FileImage(File(_profileImage!.path))
                            : null,
                        child: _profileImage == null
                            ? const Icon(Icons.person,
                                size: 50, color: Colors.white)
                            : null,
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Container(
                          width: 28,
                          height: 28,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.blue,
                          ),
                          child: IconButton(
                            padding: EdgeInsets.zero,
                            icon: const Icon(Icons.camera_alt,
                                color: Colors.white, size: 18),
                            onPressed: () => _showPickerOptions("profile"),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      controller: nameController,
                      decoration: const InputDecoration(labelText: "Full Name"),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              /// Email
              TextField(
                controller: emailController,
                decoration: const InputDecoration(labelText: "Email"),
              ),
              const SizedBox(height: 16),

              /// Locality
              TextField(
                controller: localityController,
                decoration: const InputDecoration(labelText: "Locality"),
              ),
              const SizedBox(height: 16),

              /// Select Class
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(labelText: "Select Class"),
                value: selectedClass,
                items: ["Class 6", "Class 7", "Class 8", "Class 9", "Class 10"]
                    .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                    .toList(),
                onChanged: (val) => setState(() => selectedClass = val),
              ),
              const SizedBox(height: 16),

              /// Subject
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(labelText: "Select Subject"),
                value: selectedSubject,
                items: ["Maths", "Science", "Drawing"]
                    .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                    .toList(),
                onChanged: (val) => setState(() => selectedSubject = val),
              ),
              const SizedBox(height: 16),

              /// Board Name ✅ FIXED
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(labelText: "Board Name"),
                value: selectedBoard,
                items: ["CBSE", "ICSE", "STATE BOARD"]
                    .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                    .toList(),
                onChanged: (val) => setState(() => selectedBoard = val),
              ),
              const SizedBox(height: 16),

              /// State
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(labelText: "Select State"),
                value: selectedState,
                items: ["Delhi", "UP", "Haryana"]
                    .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                    .toList(),
                onChanged: (val) => setState(() => selectedState = val),
              ),
              const SizedBox(height: 16),

              /// Price
              TextField(
                controller: priceController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: "Price"),
              ),
              const SizedBox(height: 16),

              /// ID Type
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(labelText: "ID Proof Type"),
                value: selectedIdType,
                items: ["Aadhar", "PAN", "Voter ID", "Passport"]
                    .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                    .toList(),
                onChanged: (val) => setState(() => selectedIdType = val),
              ),
              const SizedBox(height: 16),

              /// ID Upload
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _idUploadBox("Front side", _frontIdImage, "front"),
                  _idUploadBox("Back side", _backIdImage, "back"),
                ],
              ),

              const SizedBox(height: 24),
              Center(
                child: ElevatedButton(
                  onPressed: onUpdatePressed,
                  child: const Text("Save and Proceed"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _idUploadBox(String label, XFile? imageFile, String type) {
    return Column(
      children: [
        Text(label, style: const TextStyle(fontSize: 14)),
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
            child: imageFile == null
                ? const Icon(Icons.image, size: 40, color: Colors.black54)
                : ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.file(File(imageFile.path),
                        fit: BoxFit.cover, width: 120, height: 100),
                  ),
          ),
        ),
      ],
    );
  }
}
