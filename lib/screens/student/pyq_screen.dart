import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:urbantutorsapp/controllers/StudentController.dart';
import 'package:urbantutorsapp/screens/student/SubjectScreen.dart';

class PyqScreen extends StatelessWidget {
  final controller = Get.put(StudentController());

  PyqScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Load initial class list
    controller.loadClasses("1", "pyq");

    return Scaffold(
      appBar: AppBar(
        title: const Text("Select Class"),
        centerTitle: true,
        elevation: 2,
      ),
      body: SafeArea(
        child: Obx(() {
          if (controller.isLoading.value) {
            return const Center(child: CircularProgressIndicator());
          }

          if (controller.classes.isEmpty) {
            return const Center(child: Text("No classes available."));
          }

          return RefreshIndicator(
            onRefresh: () async {
              await controller.loadClasses("1", "pyq");
            },
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
              itemCount: controller.classes.length,
              itemBuilder: (context, index) {
                final classItem = controller.classes[index];

                return Card(
                  elevation: 3,
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                    title: Text(
                      classItem.className,
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                    ),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 18),
                    onTap: () async {
                      await controller.loadSubjects(classItem.classId.toString(), "pyq");
                      Get.to(() => SubjectScreen());
                    },
                  ),
                );
              },
            ),
          );
        }),
      ),
    );
  }
}
