import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:urbantutorsapp/screens/controllers/profile_controller.dart';
import 'package:urbantutorsapp/theme/theme_constants.dart';
import 'package:urbantutorsapp/utils/storage_helper.dart';

class AdmitProfile extends StatefulWidget {
  const AdmitProfile({Key? key}) : super(key: key);

  @override
  _AdmitProfileState createState() => _AdmitProfileState();
}

class _AdmitProfileState extends State<AdmitProfile> {
  bool isEditingName = false; // Toggle for editing name
  final TextEditingController nameController =
      TextEditingController(text: "Nikhil Kumar");

    final ProfileController profileController = Get.put 
    (ProfileController());

  @override
  void initState() {
    TokenStorage.getToken().then((token) {
      print('kuchbhi');
      print(token);
      if (token != null) {
        profileController.fetchUserProfile(token);
      } else {
        print("No token found");
      };
    });
  fetchProfileData();
    super.initState();
  }

  void fetchProfileData() async {
    try {
      final profileData = await profileController.fetchUserProfile('');
      print('Profile Data: ${profileData.data?.studentName}');
    } catch (e) {
      print('Error fetching profile data: $e');
    }
  }

  @override
  void dispose() {
    nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Admin Profile"),
        backgroundColor: AppColors.primaryColor,
        actions: [
          IconButton(
            icon: Icon(isEditingName ? Icons.check : Icons.edit),
            onPressed: () {
              setState(() {
                if (isEditingName) {
                  // Save logic can be added here if needed
                }
                isEditingName = !isEditingName;
              });
            },
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Profile picture
            Center(
              child: CircleAvatar(
                radius: 50,
                backgroundColor: Colors.blueGrey[100],
                child: const Icon(Icons.person, size: 50, color: Colors.white),
              ),
            ),
            const SizedBox(height: 20),

            // Name (editable)
            ListTile(
              leading: const Icon(Icons.person),
              title: const Text("Name"),
              subtitle: isEditingName
                  ? TextField(
                      controller: nameController,
                      decoration: const InputDecoration(
                        hintText: "Enter your name",
                        border: UnderlineInputBorder(),
                      ),
                    )
                  : Text(nameController.text),
            ),

            // Email
            const ListTile(
              leading: Icon(Icons.email),
              title: Text("Email"),
              subtitle: Text("nikhil@email.com"),
            ),

            // Phone
            const ListTile(
              leading: Icon(Icons.phone),
              title: Text("Phone"),
              subtitle: Text("+91 9876543210"),
            ),
          ],
        ),
      ),
    );
  }
}
