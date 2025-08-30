import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:urbantutorsapp/controllers/pyq_controller.dart';

class PyqScreenNew extends StatelessWidget {
  PyqScreenNew({super.key});

  final PyqController controller = Get.put(PyqController());

  InputDecoration _dec(String label) => InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        isDense: true,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("PYQ Notes")),
      body: Obx(() {
        if (controller.errorMessage.isNotEmpty) {
          return Center(child: Text("Error: ${controller.errorMessage}"));
        }
        return Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // Board
              DropdownButtonFormField<int>(
                decoration: _dec("Select Board"),
                isExpanded: true,
                value: controller.selectedBoardId.value,
                items: controller.boards
                    .map((b) => DropdownMenuItem(
                          value: b.boardId,
                          child: Text(b.boardLabel ?? ""),
                        ))
                    .toList(),
                onChanged: (val) {
                  if (val != null) controller.fetchClasses(val);
                },
              ),
              const SizedBox(height: 12),

              // Class
              DropdownButtonFormField<int>(
                decoration: _dec("Select Class"),
                isExpanded: true,
                value: controller.selectedClassId.value,
                items: controller.classes
                    .map((c) => DropdownMenuItem(
                          value: c.classId,
                          child: Text(c.className ?? ""),
                        ))
                    .toList(),
                onChanged: (val) {
                  if (val != null) controller.fetchSubjects(val);
                },
              ),
              const SizedBox(height: 12),

              // Subject
              DropdownButtonFormField<int>(
                decoration: _dec("Select Subject"),
                isExpanded: true,
                value: controller.selectedSubjectId.value,
                items: controller.subjects
                    .map((s) => DropdownMenuItem(
                          value: s.subjectId,
                          child: Text(s.subjectName ?? ""),
                        ))
                    .toList(),
                onChanged: (val) {
                  if (val != null) controller.fetchChapters(val);
                },
              ),
              const SizedBox(height: 12),

              // Chapter
              DropdownButtonFormField<int>(
                decoration: _dec("Select Chapter"),
                isExpanded: true,
                value: controller.selectedChapterId.value,
                items: controller.chapters
                    .map((c) => DropdownMenuItem(
                          value: c.chapterId,
                          child: Text(c.chapterName ?? ""),
                        ))
                    .toList(),
                onChanged: (val) {
                  if (val != null) controller.fetchChapterDetails(val);
                },
              ),
              const SizedBox(height: 20),

              // Details Section
              Obx(() {
                final detail = controller.chapterDetails.value;
                if (detail == null) {
                  return const Text("Select a chapter to view details");
                }
                return Card(
                  margin: const EdgeInsets.only(top: 10),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Chapter: ${detail.chapterName ?? ''}",
                            style: const TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 16)),
                        const SizedBox(height: 8),
                        Text(detail.chapterDetail[0].content ?? "No details"),
                      ],
                    ),
                  ),
                );
              }),
            ],
          ),
        );
      }),
    );
  }
}
