import 'package:flutter/material.dart';
import 'package:urbantutors_app/theme/theme_constants.dart';

class CourseListScreen extends StatelessWidget {
  const CourseListScreen({super.key});

  final List<Map<String, String>> courses = const [
    {
      'title': 'Course 1: Mathematics Basics',
      'description': 'Learn arithmetic, algebra, and geometry fundamentals.'
    },
    {
      'title': 'Course 2: English Grammar',
      'description': 'Master grammar, vocabulary, and communication skills.'
    },
    {
      'title': 'Course 3: Science Explorer',
      'description': 'Understand basic physics, chemistry, and biology.'
    },
    {
      'title': 'Course 4: Computer Fundamentals',
      'description': 'Introduction to computers, MS Office, and Internet basics.'
    },
    {
      'title': 'Course 5: Programming in Python',
      'description': 'Beginner-friendly Python programming course.'
    },
    {
      'title': 'Course 6: Logical Reasoning',
      'description': 'Improve logical and analytical thinking skills.'
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Available Courses'),
        backgroundColor: const Color.fromARGB(255, 12, 205, 54),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: courses.length,
        itemBuilder: (context, index) {
          final course = courses[index];
          return Card(
            margin: const EdgeInsets.symmetric(vertical: 8),
            elevation: 4,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            child: ListTile(
              title: Text(course['title']!, style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text(course['description']!),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () {
                // Optional: Add course detail navigation here
              },
            ),
          );
        },
      ),
    );
  }
}
