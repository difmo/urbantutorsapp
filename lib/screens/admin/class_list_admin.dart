import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ClassListAdmin extends StatefulWidget {
  const ClassListAdmin({super.key});

  @override
  State<ClassListAdmin> createState() => _ClassListAdminState();
}

class _ClassListAdminState extends State<ClassListAdmin> {
  final TextEditingController _titleController = TextEditingController();

  void _addClass() {
    final title = _titleController.text.trim();
    if (title.isNotEmpty) {
      // Add logic to send to backend or list
      print("Add class: $title");
      _titleController.clear();
    } else {
      Get.snackbar("Error", "Please enter a class title.");
    }
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).primaryColor;

    return Scaffold(
      backgroundColor: const Color(0xFFF7EDF9), // Light purple background
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: BackButton(color: Colors.black),
        title: const Text(
          "Class List",
          style: TextStyle(color: Colors.black),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _titleController,
                    decoration: const InputDecoration(
                      labelText: 'Title',
                      border: UnderlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                ElevatedButton(
                  onPressed: _addClass,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    elevation: 2,
                  ),
                  child: const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    child: Text("Add"),
                  ),
                ),
              ],
            ),

            // Optional: List of added classes (You can bind it to a controller/list)
            const SizedBox(height: 20),
            const Divider(),
            const Text(
              "Your class list will appear below...",
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}
