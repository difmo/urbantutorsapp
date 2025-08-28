import 'package:flutter/material.dart';
import '../../theme/theme_constants.dart';

class TutorPYQScreen extends StatefulWidget {
  const TutorPYQScreen({super.key});

  @override
  State<TutorPYQScreen> createState() => _TutorPYQScreenState();
}

class _TutorPYQScreenState extends State<TutorPYQScreen> {
  final List<Map<String, String>> _pyqs = [];

  void _addPYQDialog() {
    final TextEditingController questionController = TextEditingController();
    final TextEditingController descController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text("Add New PYQ"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: questionController,
                decoration: const InputDecoration(
                  labelText: "Question",
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: descController,
                decoration: const InputDecoration(
                  labelText: "Description (optional)",
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryColor,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              onPressed: () {
                if (questionController.text.trim().isNotEmpty) {
                  setState(() {
                    _pyqs.add({
                      "question": questionController.text.trim(),
                      "desc": descController.text.trim(),
                    });
                  });
                  Navigator.pop(context);
                }
              },
              child: const Text("Save"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeColor = AppColors.primaryColor;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: themeColor,
        title: const Text(
          "Previous Year Questions",
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
      ),
      body: _pyqs.isEmpty
          ? const Center(
              child: Text(
                "No PYQs added yet.\nClick + to add one!",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _pyqs.length,
              itemBuilder: (context, index) {
                final item = _pyqs[index];
                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 6,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: Icon(Icons.description, color: themeColor, size: 28),
                    title: Text(
                      item["question"] ?? "",
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    subtitle: item["desc"]!.isNotEmpty
                        ? Text(item["desc"]!)
                        : null,
                    trailing: IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () {
                        setState(() {
                          _pyqs.removeAt(index);
                        });
                      },
                    ),
                  ),
                );
              },
            ),

      // ➕ Floating Add Button
      floatingActionButton: FloatingActionButton(
        backgroundColor: themeColor,
        onPressed: _addPYQDialog,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
