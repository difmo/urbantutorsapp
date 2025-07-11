import 'package:flutter/material.dart';
import 'package:urbantutors_app/theme/theme_constants.dart';

class AdminHistoryPage extends StatelessWidget {
  const AdminHistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin History'),
        backgroundColor: AppColors.primaryColor,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh History',
            onPressed: () {
              // TODO: Add refresh logic here
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('History refreshed')),
              );
            },
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          sectionTitle('👥 User Management'),
          historyItem('User "john_doe" deactivated', '2025-07-07 04:22 PM'),
          historyItem('New user "jane_admin" added with role Moderator', '2025-07-06 01:15 PM'),

          sectionTitle('📁 Content Changes'),
          historyItem('Updated course: "Flutter Basics" (ID: #0231)', '2025-07-05 03:11 PM'),
          historyItem('Deleted post: "Old policy guidelines"', '2025-07-04 10:30 AM'),

          sectionTitle('⚠️ System Logs'),
          historyItem('Server downtime detected (5 min)', '2025-07-01 01:10 AM'),
          historyItem('Unauthorized access attempt blocked', '2025-06-30 11:50 PM'),
        ],
      ),
    );
  }

  Widget sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.black54,
        ),
      ),
    );
  }

  Widget historyItem(String text, String dateTime) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 0, vertical: 4),
      title: Text(text),
      subtitle: Text(dateTime),
      leading: const Icon(Icons.history, color: Colors.grey),
    );
  }
}
