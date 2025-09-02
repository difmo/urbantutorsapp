import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:urbantutorsapp/theme/theme_constants.dart';

class StudentProfileScreenEdit extends StatefulWidget {
  const StudentProfileScreenEdit({super.key});

  @override
  State<StudentProfileScreenEdit> createState() =>
      _StudentProfileScreenEditState();
}

class _StudentProfileScreenEditState extends State<StudentProfileScreenEdit> {
  bool isEditing = false;
  File? _imageFile;
  final ImagePicker _picker = ImagePicker();

  final TextEditingController nameController =
      TextEditingController(text: "John Doe");
  final TextEditingController classController =
      TextEditingController(text: "10th Grade");
  final TextEditingController phoneController =
      TextEditingController(text: "+91 9876543210");
  final TextEditingController emailController =
      TextEditingController(text: "john.doe@email.com");

  Future<void> _pickImage(ImageSource source) async {
    final pickedFile = await _picker.pickImage(source: source);
    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
    }
  }

  void _showImagePickerOptions() {
    showModalBottomSheet(
      context: context,
      builder: (_) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('Take a photo'),
                onTap: () {
                  _pickImage(ImageSource.camera);
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Choose from gallery'),
                onTap: () {
                  _pickImage(ImageSource.gallery);
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeColor = AppColors.primaryColor;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // Top Wave
          ClipPath(
            clipper: TopWaveClipper(),
            child: Container(height: 260, color: themeColor.withOpacity(0.2)),
          ),

          // Main Content
          SingleChildScrollView(
            child: Column(
              children: [
                const SizedBox(height: 50),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: [
                      const BackButton(color: AppColors.primaryColor),
                      const Text(
                        "Edit Profile",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primaryColor,
                        ),
                      ),
                      const Spacer(),
                      IconButton(
                        icon: Icon(
                          isEditing ? Icons.check : Icons.edit,
                          color: themeColor,
                        ),
                        onPressed: () {
                          setState(() {
                            isEditing = !isEditing;
                          });
                        },
                      ),
                    ],
                  ),
                ),

                // Profile Avatar
                Center(
                  child: Stack(
                    children: [
                      CircleAvatar(
                        radius: 50,
                        backgroundImage: _imageFile != null
                            ? FileImage(_imageFile!)
                            : const AssetImage('assets/icons/profile.jpg')
                                as ImageProvider,
                        backgroundColor: Colors.grey[300],
                      ),
                      if (isEditing)
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: GestureDetector(
                            onTap: _showImagePickerOptions,
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                color: themeColor,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.add,
                                  color: Colors.white, size: 18),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),

                const SizedBox(height: 30),

                _buildField("Name", nameController, isEditing),
                _buildField("Class", classController, isEditing),
                _buildField("Phone no.", phoneController, isEditing,
                    keyboardType: TextInputType.phone),
                _buildField("E-Mail", emailController, isEditing,
                    keyboardType: TextInputType.emailAddress),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildField(
    String label,
    TextEditingController controller,
    bool editable, {
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style:
                  const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
          const SizedBox(height: 6),
          TextField(
            controller: controller,
            enabled: editable,
            keyboardType: keyboardType,
            decoration: InputDecoration(
              contentPadding:
                  const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
              filled: true,
              fillColor: Colors.grey.shade200,
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide.none),
            ),
          )
        ],
      ),
    );
  }
}

class TopWaveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    Path path = Path();
    path.lineTo(0, size.height * 0.75);
    path.quadraticBezierTo(
        size.width * 0.5, size.height, size.width, size.height * 0.75);
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}
