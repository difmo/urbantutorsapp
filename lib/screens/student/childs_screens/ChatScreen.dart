import 'package:flutter/material.dart';
import 'package:urbantutorsapp/screens/student/search_tutor_screen.dart';
import 'package:urbantutorsapp/theme/theme_constants.dart';

/// Chat with a tutor.
///
/// The server can send chat messages (/chat_send) but has no endpoint to load
/// a conversation, so real two-way chat isn't possible yet. Until then this
/// screen says so and points students to posting a requirement, instead of
/// showing a made-up conversation whose messages were never delivered.
class ChatScreen extends StatelessWidget {
  final String teacherName;

  const ChatScreen({super.key, this.teacherName = 'Tutor'});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(teacherName),
        backgroundColor: AppColors.primaryColor,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.forum_outlined,
                  size: 64, color: AppColors.primaryColor),
              const SizedBox(height: 16),
              const Text(
                'In-app chat is coming soon',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 8),
              const Text(
                'To connect with a tutor now, post your requirement. '
                'Matching tutors will contact you directly.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.black54, fontSize: 15),
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                icon: const Icon(Icons.search_rounded),
                label: const Text('Search a Private Tutor'),
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const SearchTutorScreen()),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
