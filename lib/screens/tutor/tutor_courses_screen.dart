import 'package:flutter/material.dart';
import '../../theme/theme_constants.dart';

class CoursesScreen extends StatelessWidget {
  final List<String> courses = [
    "Mathematics - Grade 10",
    "Physics - Grade 12",
    "English Literature",
    "Biology Basics",
    "History of India",
    "Chemistry Crash Course",
  ];

  CoursesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final primaryColor = AppColors.primaryColor;
    final accentColor = AppColors.accentColor;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: primaryColor,
        title: const Text('Available Courses'),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: courses.length,
        itemBuilder: (context, index) {
          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.grey.shade100,
                foregroundColor: primaryColor,
                padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
                elevation: 1,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(color: accentColor.withOpacity(0.2)),
                ),
              ),
              onPressed: () {
                // You can navigate to course details here
              },
              child: Row(
                children: [
                  Icon(Icons.book, color: accentColor),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      courses[index],
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                    ),
                  ),
                  Icon(Icons.arrow_forward_ios, size: 16, color: primaryColor),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
