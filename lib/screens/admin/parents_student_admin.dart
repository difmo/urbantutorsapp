import 'package:flutter/material.dart';

class ParentsStudentAdmin extends StatefulWidget {
  const ParentsStudentAdmin({super.key});

  @override
  State<ParentsStudentAdmin> createState() => _ParentsStudentAdminState();
}

class _ParentsStudentAdminState extends State<ParentsStudentAdmin> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("All Parents"),
        actions: [
          IconButton(
            icon: const Icon(Icons.download),
            onPressed: () {
              print("Download button pressed");
            },
          )
        ],
      ),
      body: Container(),
    );
  }
}
