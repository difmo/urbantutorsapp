import 'package:flutter/material.dart';

class PDFCoursesScreen extends StatelessWidget {
  final List<Map<String, String>> pdfCourses = [
    {
      'title': 'Algebra Basics',
      'subject': 'Mathematics',
      'file': 'Algebra_Basics.pdf'
    },
    {
      'title': 'Organic Chemistry Notes',
      'subject': 'Chemistry',
      'file': 'Organic_Chemistry.pdf'
    },
    {
      'title': 'Modern Physics Overview',
      'subject': 'Physics',
      'file': 'Modern_Physics.pdf'
    },
    {
      'title': 'Cell Biology Diagrams',
      'subject': 'Biology',
      'file': 'Cell_Biology.pdf'
    },
  ];

   PDFCoursesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).primaryColor;

    return Scaffold(
      appBar: AppBar(
        title: const Text('PDF Courses'),
        elevation: 1,
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: pdfCourses.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final course = pdfCourses[index];
          return Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: Row(
              children: [
                const Icon(Icons.picture_as_pdf,
                    color: Colors.red, size: 32),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        course['title']!,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        course['subject']!,
                        style: const TextStyle(
                          fontSize: 13,
                          color: Colors.black54,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.download_rounded, color: primaryColor),
                  onPressed: () {
                    // TODO: Handle download or preview
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text("Downloading ${course['file']}"),
                      ),
                    );
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
