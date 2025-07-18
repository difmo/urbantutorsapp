import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:urbantutorsapp/controllers/StudentController.dart';

class SubjectScreen extends StatelessWidget {
  final controller = Get.find<StudentController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Select Subject")),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        return ListView.builder(
          itemCount: controller.subjects.length,
          itemBuilder: (context, index) {
            final subject = controller.subjects[index];
            return ListTile(
              title: Text(subject.subjectName),
              onTap: () async {
                await controller.loadChapters(subject.id.toString(), "student");
                // Get.to(() => ChapterScreen());
              },
            );
          },
        );
      }),
    );
  }
}
