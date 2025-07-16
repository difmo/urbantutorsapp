import 'package:flutter/material.dart';
import 'package:urbantutorsapp/screens/student/childs_screens/ChatScreen.dart';

class ChatUserListScreen extends StatelessWidget {
  final List<Map<String, String>> chatUsers = [
    {
      'name': 'Tutor John',
      'email': 'john@tutors.com',
      'lastMessage': 'Let’s review Algebra today.',
      'profile': 'J'
    },
    {
      'name': 'Tutor Lisa',
      'email': 'lisa@tutors.com',
      'lastMessage': 'I shared the notes.',
      'profile': 'L'
    },
    {
      'name': 'Tutor Aman',
      'email': 'aman@tutors.com',
      'lastMessage': 'Class rescheduled to 5PM.',
      'profile': 'A'
    },
  ];

  ChatUserListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).primaryColor;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Chat with Tutors'),
        backgroundColor: Colors.white,
        elevation: 1,
        foregroundColor: Colors.black,
      ),
      body: chatUsers.isEmpty
          ? const Center(child: Text("No chats available"))
          : ListView.separated(
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: chatUsers.length,
              separatorBuilder: (_, __) => const Divider(indent: 72, height: 1),
              itemBuilder: (context, index) {
                final user = chatUsers[index];
                return ListTile(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ChatScreen(teacherName: user['name']!),
                      ),
                    );  
                  },
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  leading: CircleAvatar(
                    radius: 26,
                    backgroundColor: primaryColor.withOpacity(0.1),
                    child: Text(
                      user['profile']!,
                      style: TextStyle(
                        fontSize: 20,
                        color: primaryColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  title: Text(
                    user['name']!,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                  ),
                  subtitle: Text(
                    user['lastMessage']!,
                    style: const TextStyle(color: Colors.black54, fontSize: 14),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
                );
              },
            ),
    );
  }
}
