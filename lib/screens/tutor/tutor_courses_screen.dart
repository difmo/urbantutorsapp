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
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: courses.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          return Material(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(12),
            child: InkWell(
              borderRadius: BorderRadius.circular(12),
              splashColor: accentColor.withOpacity(0.1),
              highlightColor: accentColor.withOpacity(0.05),
              onTap: () {
                // Navigate to course details here
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
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
                    
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
