// import 'dart:io';
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:get/get_core/src/get_main.dart';
// import 'package:image_picker/image_picker.dart';
// import 'package:urbantutorsapp/controllers/profile_update_controller.dart';
// import 'package:urbantutorsapp/models/profile_update_request_model.dart';

// class ProfileFormScreen extends StatefulWidget {
//   const ProfileFormScreen({super.key});

//   @override
//   State<ProfileFormScreen> createState() => _ProfileFormScreenState();
// }

// class _ProfileFormScreenState extends State<ProfileFormScreen> {
//   final TextEditingController nameController = TextEditingController();
//   final TextEditingController emailController = TextEditingController();
//   final TextEditingController localityController = TextEditingController();
//   final TextEditingController qualificationController = TextEditingController();

//   String? selectedGender;
//   String? selectedState;
//   String? selectedClass;
//   String? selectedMode;
//   String? selectedSubject;
//   String? selectedExperience;
//   String? selectedIdType;

//   final ImagePicker _picker = ImagePicker();
//   XFile? _profileImage;
//   XFile? _frontIdImage;
//   XFile? _backIdImage;

//   // pick image function
//   Future<void> _pickImage(ImageSource source, String type) async {
//     final pickedFile = await _picker.pickImage(source: source);
//     if (pickedFile != null) {
//       setState(() {
//         if (type == "profile") {
//           _profileImage = pickedFile;
//         } else if (type == "front") {
//           _frontIdImage = pickedFile;
//         } else if (type == "back") {
//           _backIdImage = pickedFile;
//         }
//       });
//     }
//     Navigator.pop(context); // close bottom sheet
//   }
  

//   // bottom sheet options
//   void _showPickerOptions(String type) {
//     showModalBottomSheet(
//       context: context,
//       shape: const RoundedRectangleBorder(
//         borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
//       ),
//       builder: (context) {
//         return SafeArea(
//           child: Wrap(
//             children: [
//               ListTile(
//                 leading: const Icon(Icons.camera_alt),
//                 title: const Text("Camera"),
//                 onTap: () => _pickImage(ImageSource.camera, type),
//               ),
//               ListTile(
//                 leading: const Icon(Icons.photo),
//                 title: const Text("Gallery"),
//                 onTap: () => _pickImage(ImageSource.gallery, type),
//               ),
//             ],
//           ),
//         );
//       },
//     );
//   }

//   // delete dialog
//   void _showDeleteDialog(BuildContext context) {
//     showDialog(
//       context: context,
//       builder: (BuildContext context) {
//         return AlertDialog(
//           title: const Text('Delete Account?'),
//           content: const Text(
//             'This will delete your Account',
//           ),
//           actions: [
//             TextButton(
//               onPressed: () {
//                 Navigator.of(context).pop(); // Close the dialog
//               },
//               child: const Text('CANCEL'),
//             ),
//             TextButton(
//               onPressed: () {
//                 Navigator.of(context).pop(); // Close dialog
//                 // 👉 Add reset logic here if needed
//               },
//               child: const Text('ACCEPT'),
//             ),
//           ],
//         );
//       },
//     );
//   }

//   final ProfileUpdateController profileUpdateController = Get.put(ProfileUpdateController());

//   void onUpdatePressed() async {
//   final request = ProfileUpdateRequest(
//     userId: 1, // take dynamically from login/session
//     boardId: 6, 
//     courseId: 8,
//     subjectId: 9,
//     price:  300,
//     location: "kjv",
//     state: "kjhgfg",
//     idType: "hgvjhb",
//     remark: "jkghv ",
//     profilePicture: "", // you generate with ImagePicker
//     frontId: "",
//     backId: "",
//   );

//  await profileUpdateController.updateProfile(request);
// }



//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.white,
//       appBar: AppBar(
//         title: const Text("Profile"),
//         backgroundColor: Theme.of(context).primaryColor,
//         elevation: 0,
//         actions: [
//           IconButton(
//             icon: const Icon(Icons.delete, color: Colors.white),
//             onPressed: () => _showDeleteDialog(context),
//           ),
//         ],
//       ),
//       body: SafeArea(
//         child: SingleChildScrollView(
//           padding: const EdgeInsets.all(16),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               // Profile photo + Name
//               Row(
//                 children: [
//                   Stack(
//                     children: [
//                       CircleAvatar(
//                         radius: 40,
//                         backgroundColor: Colors.grey.shade300,
//                         backgroundImage: _profileImage != null
//                             ? FileImage(File(_profileImage!.path))
//                             : null,
//                         child: _profileImage == null
//                             ? const Icon(Icons.person,
//                                 size: 50, color: Colors.white)
//                             : null,
//                       ),
//                       Positioned(
//                         bottom: 0,
//                         right: 0,
//                         child: Container(
//                           width: 28,
//                           height: 28,
//                           decoration: const BoxDecoration(
//                             shape: BoxShape.circle,
//                             color: Colors.blue,
//                           ),
//                           child: IconButton(
//                             padding: EdgeInsets.zero,
//                             icon: const Icon(Icons.camera_alt,
//                                 color: Colors.white, size: 18),
//                             onPressed: () => _showPickerOptions("profile"),
//                           ),
//                         ),
//                       ),
//                     ],
//                   ),
//                   const SizedBox(width: 12),
//                   Expanded(
//                     child: TextField(
//                       controller: nameController,
//                       decoration: InputDecoration(
//                         labelText: "Full Name",
//                         counterText: "0/50",
//                         enabledBorder: OutlineInputBorder(
//                           borderSide: BorderSide(color: Colors.grey.shade300),
//                         ),
//                         focusedBorder: OutlineInputBorder(
//                           borderSide:
//                               const BorderSide(color: Colors.blue, width: 2),
//                           borderRadius: BorderRadius.circular(8),
//                         ),
//                       ),
//                       maxLength: 50,
//                     ),
//                   ),
//                 ],
//               ),
//               const SizedBox(height: 16),

//               // Personal Details
//               const Text("Personal details:",
//                   style: TextStyle(
//                       fontSize: 16,
//                       fontWeight: FontWeight.bold,
//                       color: Colors.blue)),
//               const SizedBox(height: 16),
//               DropdownButtonFormField<String>(
//                 decoration: InputDecoration(
//                   labelText: "Gender",
//                   enabledBorder: OutlineInputBorder(
//                     borderSide: BorderSide(color: Colors.grey.shade300),
//                   ),
//                   focusedBorder: OutlineInputBorder(
//                     borderSide: const BorderSide(color: Colors.blue, width: 2),
//                     borderRadius: BorderRadius.circular(8),
//                   ),
//                 ),
//                 value: selectedGender,
//                 items: ["Male", "Female", "Other"]
//                     .map((e) => DropdownMenuItem(value: e, child: Text(e)))
//                     .toList(),
//                 onChanged: (val) => setState(() => selectedGender = val),
//               ),
//               const SizedBox(height: 16),
//               TextField(
//                 controller: emailController,
//                 decoration: InputDecoration(
//                   labelText: "Email",
//                   counterText: "0/50",
//                   enabledBorder: OutlineInputBorder(
//                     borderSide: BorderSide(color: Colors.grey.shade300),
//                   ),
//                   focusedBorder: OutlineInputBorder(
//                     borderSide: const BorderSide(color: Colors.blue, width: 2),
//                     borderRadius: BorderRadius.circular(8),
//                   ),
//                 ),
//                 maxLength: 50,
//               ),
//               const SizedBox(height: 16),
//               TextField(
//                 controller: localityController,
//                 decoration: InputDecoration(
//                   labelText: "Locality",
//                   counterText: "0/50",
//                   enabledBorder: OutlineInputBorder(
//                     borderSide: BorderSide(color: Colors.grey.shade300),
//                   ),
//                   focusedBorder: OutlineInputBorder(
//                     borderSide: const BorderSide(color: Colors.blue, width: 2),
//                     borderRadius: BorderRadius.circular(8),
//                   ),
//                 ),
//                 maxLength: 50,
//               ),
//               const SizedBox(height: 16),
//               DropdownButtonFormField<String>(
//                 decoration: InputDecoration(
//                   labelText: "Select state",
//                   enabledBorder: OutlineInputBorder(
//                     borderSide: BorderSide(color: Colors.grey.shade300),
//                   ),
//                   focusedBorder: OutlineInputBorder(
//                     borderSide: const BorderSide(color: Colors.blue, width: 2),
//                     borderRadius: BorderRadius.circular(8),
//                   ),
//                 ),
//                 value: selectedState,
//                 items: ["State 1", "State 2", "State 3"]
//                     .map((e) => DropdownMenuItem(value: e, child: Text(e)))
//                     .toList(),
//                 onChanged: (val) => setState(() => selectedState = val),
//               ),

//               const SizedBox(height: 16),
//               const Text("Class Preference:",
//                   style: TextStyle(
//                       fontSize: 16,
//                       fontWeight: FontWeight.bold,
//                       color: Colors.blue)),
//               const SizedBox(height: 16),
//               DropdownButtonFormField<String>(
//                 decoration: InputDecoration(
//                   labelText: "Preferred Classes",
//                   enabledBorder: OutlineInputBorder(
//                     borderSide: BorderSide(color: Colors.grey.shade300),
//                   ),
//                   focusedBorder: OutlineInputBorder(
//                     borderSide: const BorderSide(color: Colors.blue, width: 2),
//                     borderRadius: BorderRadius.circular(8),
//                   ),
//                 ),
//                 value: selectedClass,
//                 items: ["Class 6", "Class 7", "Class 8"]
//                     .map((e) => DropdownMenuItem(value: e, child: Text(e)))
//                     .toList(),
//                 onChanged: (val) => setState(() => selectedClass = val),
//               ),
//               const SizedBox(height: 16),
//               DropdownButtonFormField<String>(
//                 decoration: InputDecoration(
//                   labelText: "Preferred Mode",
//                   enabledBorder: OutlineInputBorder(
//                     borderSide: BorderSide(color: Colors.grey.shade300),
//                   ),
//                   focusedBorder: OutlineInputBorder(
//                     borderSide: const BorderSide(color: Colors.blue, width: 2),
//                     borderRadius: BorderRadius.circular(8),
//                   ),
//                 ),
//                 value: selectedMode,
//                 items: ["Online", "Offline", "Hybrid"]
//                     .map((e) => DropdownMenuItem(value: e, child: Text(e)))
//                     .toList(),
//                 onChanged: (val) => setState(() => selectedMode = val),
//               ),
//               const SizedBox(height: 16),
//               DropdownButtonFormField<String>(
//                 decoration: InputDecoration(
//                   labelText: "Preferred Subjects",
//                   enabledBorder: OutlineInputBorder(
//                     borderSide: BorderSide(color: Colors.grey.shade300),
//                   ),
//                   focusedBorder: OutlineInputBorder(
//                     borderSide: const BorderSide(color: Colors.blue, width: 2),
//                     borderRadius: BorderRadius.circular(8),
//                   ),
//                 ),
//                 value: selectedSubject,
//                 items: ["Math", "Science", "English"]
//                     .map((e) => DropdownMenuItem(value: e, child: Text(e)))
//                     .toList(),
//                 onChanged: (val) => setState(() => selectedSubject = val),
//               ),

//               const SizedBox(height: 16),
//               const Text("Qualifications:",
//                   style: TextStyle(
//                       fontSize: 16,
//                       fontWeight: FontWeight.bold,
//                       color: Colors.blue)),
//               const SizedBox(height: 16),
//               DropdownButtonFormField<String>(
//                 decoration: InputDecoration(
//                   labelText: "Total Experience",
//                   enabledBorder: OutlineInputBorder(
//                     borderSide: BorderSide(color: Colors.grey.shade300),
//                   ),
//                   focusedBorder: OutlineInputBorder(
//                     borderSide: const BorderSide(color: Colors.blue, width: 2),
//                     borderRadius: BorderRadius.circular(8),
//                   ),
//                 ),
//                 value: selectedExperience,
//                 items: ["0-1 years", "1-3 years", "3-5 years", "5+ years"]
//                     .map((e) => DropdownMenuItem(value: e, child: Text(e)))
//                     .toList(),
//                 onChanged: (val) => setState(() => selectedExperience = val),
//               ),
//               const SizedBox(height: 16),
//               TextField(
//                 controller: qualificationController,
//                 decoration: InputDecoration(
//                   labelText: "Qualification",
//                   counterText: "0/50",
//                   enabledBorder: OutlineInputBorder(
//                     borderSide: BorderSide(color: Colors.grey.shade300),
//                   ),
//                   focusedBorder: OutlineInputBorder(
//                     borderSide: const BorderSide(color: Colors.blue, width: 2),
//                     borderRadius: BorderRadius.circular(8),
//                   ),
//                 ),
//                 maxLength: 50,
//               ),

//               const SizedBox(height: 16),
//               const Text("Documents:",
//                   style: TextStyle(
//                       fontSize: 16,
//                       fontWeight: FontWeight.bold,
//                       color: Colors.blue)),
//               const SizedBox(height: 16),
//               DropdownButtonFormField<String>(
//                 decoration: InputDecoration(
//                   labelText: "ID proof type",
//                   enabledBorder: OutlineInputBorder(
//                     borderSide: BorderSide(color: Colors.grey.shade300),
//                   ),
//                   focusedBorder: OutlineInputBorder(
//                     borderSide: const BorderSide(color: Colors.blue, width: 2),
//                     borderRadius: BorderRadius.circular(8),
//                   ),
//                 ),
//                 value: selectedIdType,
//                 items: ["Aadhar", "PAN", "Voter ID", "Passport"]
//                     .map((e) => DropdownMenuItem(value: e, child: Text(e)))
//                     .toList(),
//                 onChanged: (val) => setState(() => selectedIdType = val),
//               ),
//               const SizedBox(height: 16),

//               Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//                 children: [
//                   _idUploadBox("Front side", _frontIdImage, "front"),
//                   _idUploadBox("Back side", _backIdImage, "back"),
//                 ],
//               ),

//               const SizedBox(height: 24),
//               Center(
//                 child: ElevatedButton(
//                   style: ElevatedButton.styleFrom(
//                       backgroundColor: Colors.blue,
//                       padding: const EdgeInsets.symmetric(
//                           horizontal: 32, vertical: 14),
//                       shape: RoundedRectangleBorder(
//                           borderRadius: BorderRadius.circular(8))),
//                   onPressed: () {
//                     // Save action
//                     onUpdatePressed();
//                   },
//                   child: const Text(
//                     "Save and proceed",
//                     style: TextStyle(fontSize: 16, color: Colors.white),
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _idUploadBox(String label, XFile? imageFile, String type) {
//     return Column(
//       children: [
//         Text(label, style: const TextStyle(fontSize: 14)),
//         const SizedBox(height: 6),
//         GestureDetector(
//           onTap: () => _showPickerOptions(type),
//           child: Container(
//             width: 120,
//             height: 100,
//             decoration: BoxDecoration(
//               border: Border.all(color: Colors.grey),
//               borderRadius: BorderRadius.circular(8),
//             ),
//             child: imageFile == null
//                 ? const Icon(Icons.image, size: 40, color: Colors.black54)
//                 : ClipRRect(
//                     borderRadius: BorderRadius.circular(8),
//                     child: Image.file(File(imageFile.path),
//                         fit: BoxFit.cover, width: 120, height: 100),
//                   ),
//           ),
//         ),
//       ],
//     );
//   }
// }

