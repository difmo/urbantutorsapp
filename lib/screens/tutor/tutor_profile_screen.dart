import 'package:flutter/material.dart';

class TeacherProfileScreen extends StatelessWidget {
  const TeacherProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final List<String> courses = [
      'Course1',
      'Course2',
      'Course3',
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Teacher Profile'),
        backgroundColor: const Color.fromARGB(255, 12, 205, 54),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Profile Image and Name
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundImage: AssetImage('assets/images/teacher.jpg'), // Replace with your image path
                  ),
                  const SizedBox(height: 10),
                  const Text('Tutor Name',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  const Text('Subject Expertise',
                      style: TextStyle(color: Colors.grey)),
                ],
              ),
            ),

            // About Section
            ListTile(
              leading: const Icon(Icons.info_outline),
              title: const Text('About'),
              subtitle: const Text(
                  'Experienced tutor with 5+ years in Mathematics and Programming.'),
            ),

            // Subjects Taught
            ListTile(
              leading: const Icon(Icons.book_outlined),
              title: const Text('Subjects Taught'),
              subtitle: const Text('Mathematics, Science, Python Programming'),
            ),

            // Courses Section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Courses Created', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  TextButton.icon(
                    icon: const Icon(Icons.add),
                    label: const Text("Add Course"),
                    onPressed: () {
                      // Add new course logic
                    },
                  )
                ],
              ),
            ),
            ...courses.map((course) => ListTile(
                  leading: const Icon(Icons.check_circle_outline),
                  title: Text(course),
                )),

            const Divider(),

            // Profile Controls (Only Edit & Availability)
            const Padding(
              padding: EdgeInsets.all(16),
              child: Text('Profile Controls',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ),
            ListTile(
              leading: const Icon(Icons.edit),
              title: const Text('Edit Profile'),
              onTap: () {
                // Navigate to Edit Profile Screen
              },
            ),
            ListTile(
              leading: const Icon(Icons.access_time),
              title: const Text('Availability'),
              subtitle: const Text('Set your available time slots'),
              onTap: () {
                // Navigate to Availability Screen
              },
            ),
          ],
        ),
      ),
    );
  }
}