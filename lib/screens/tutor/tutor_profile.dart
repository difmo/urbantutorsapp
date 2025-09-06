import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:urbantutorsapp/theme/theme_constants.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool isEditing = false;
  String? profileImagePath;

  final nameController = TextEditingController(text: "Pritam");
  String gender = "Male";
  final emailController = TextEditingController(text: "developer@gmail.com");
  final localityController = TextEditingController(text: "Shekhala");
  String state = "Rajasthan";
  String city = "Jodhpur Gramin";

  String preferredClass = "12th";
  String preferredMode = "Online";
  String preferredSubject = "English";

  final experienceController = TextEditingController(text: "3");
  final qualificationController = TextEditingController(text: "B Tech");

  final genderList = ["Male", "Female", "Other"];
  final stateList = ["Rajasthan", "Delhi", "Maharashtra"];
  final cityList = ["Jodhpur Gramin", "Jaipur", "Udaipur"];
  final classList = ["10th", "11th", "12th"];
  final modeList = ["Online", "Offline"];
  final subjectList = ["English", "Maths", "Science"];

  // 📌 Pick image from gallery or camera
  Future<void> pickImage(ImageSource source) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: source);
    if (pickedFile != null) {
      setState(() {
        profileImagePath = pickedFile.path;
      });
    }
  }

  // 📌 Show bottom sheet to choose camera/gallery
  void showImagePickerOptions() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.photo_camera),
              title: const Text("Take Photo"),
              onTap: () {
                Navigator.pop(context);
                pickImage(ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text("Choose from Gallery"),
              onTap: () {
                Navigator.pop(context);
                pickImage(ImageSource.gallery);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget buildRowTextField(String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(
              width: 120,
              child: Text(label,
                  style: const TextStyle(fontWeight: FontWeight.w500))),
          Expanded(
            child: TextField(
              controller: controller,
              readOnly: !isEditing,
              decoration: const InputDecoration(
                border: InputBorder.none,
                isDense: true,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildRowDropdown(String label, String value, List<String> items,
      Function(String?) onChanged) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(
              width: 120,
              child: Text(label,
                  style: const TextStyle(fontWeight: FontWeight.w500))),
          Expanded(
            child: DropdownButtonFormField<String>(
              value: value,
              decoration: const InputDecoration(
                border: InputBorder.none,
                isDense: true,
              ),
              onChanged: isEditing ? onChanged : null,
              items: items
                  .map((item) =>
                      DropdownMenuItem(value: item, child: Text(item)))
                  .toList(),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Profile"),
        actions: [
          IconButton(
            icon: Icon(isEditing ? Icons.close : Icons.edit),
            onPressed: () {
              setState(() {
                isEditing = !isEditing;
              });
            },
          )
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Profile Picture with edit icon
            Center(
              child: Stack(
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundImage: profileImagePath != null
                        ? FileImage(File(profileImagePath!))
                        : const AssetImage("assets/icons/profile.jpg")
                            as ImageProvider,
                  ),
                  if (isEditing)
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: GestureDetector(
                        onTap: showImagePickerOptions,
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: AppColors.primaryColor,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.camera_alt,
                              color: Colors.white, size: 18),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            const Text("Personal details:",
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryColor)),
            buildRowTextField("Full Name", nameController),
            buildRowDropdown("Gender", gender, genderList,
                (val) => setState(() => gender = val!)),
            buildRowTextField("Email", emailController),
            buildRowTextField("Locality", localityController),
            buildRowDropdown("State", state, stateList,
                (val) => setState(() => state = val!)),
            buildRowDropdown(
                "City", city, cityList, (val) => setState(() => city = val!)),

            const SizedBox(height: 16),

            const Text("Class Preference:",
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryColor)),
            buildRowDropdown("Class", preferredClass, classList,
                (val) => setState(() => preferredClass = val!)),
            buildRowDropdown("Mode", preferredMode, modeList,
                (val) => setState(() => preferredMode = val!)),
            buildRowDropdown("Subject", preferredSubject, subjectList,
                (val) => setState(() => preferredSubject = val!)),

            const SizedBox(height: 16),

            const Text("Qualifications:",
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryColor)),
            buildRowTextField("Experience", experienceController),
            buildRowTextField("Qualification", qualificationController),

            const SizedBox(height: 20),

            if (isEditing)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    setState(() {
                      isEditing = false;
                    });
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text("Profile saved successfully")),
                    );
                  },
                  child: const Text("Save and Proceed"),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
