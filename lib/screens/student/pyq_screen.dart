import 'package:flutter/material.dart';

class PYQScreen extends StatelessWidget {
  final List<Map<String, String>> pyqList = [
    {
      'subject': 'Mathematics',
      'year': '2024',
      'file': 'Math_2024.pdf',
    },
    {
      'subject': 'Physics',
      'year': '2023',
      'file': 'Physics_2023.pdf',
    },
    {
      'subject': 'Chemistry',
      'year': '2022',
      'file': 'Chemistry_2022.pdf',
    },
    {
      'subject': 'Biology',
      'year': '2021',
      'file': 'Biology_2021.pdf',
    },
  ];

   PYQScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).primaryColor;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Previous Year Questions"),
        elevation: 1,
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: pyqList.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final item = pyqList[index];
          return Container(
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade300),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                const Icon(Icons.picture_as_pdf, color: Colors.red, size: 28),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item['subject']!,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        "Year: ${item['year']}",
                        style: const TextStyle(
                          fontSize: 13,
                          color: Colors.black54,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () {
                    // TODO: Handle download or view
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text("Downloading ${item['file']}"),
                      ),
                    );
                  },
                  icon: Icon(Icons.download_rounded, color: primaryColor),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
