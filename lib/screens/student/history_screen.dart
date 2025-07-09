import 'package:flutter/material.dart';
import 'package:urbantutors_app/theme/theme_constants.dart';

class StudentHistoryScreen extends StatelessWidget {
  const StudentHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).primaryColor;

    return Scaffold(
      appBar: AppBar(
        title: const Text('History'),
        backgroundColor: primaryColor,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _historyTile(
            icon: Icons.download,
            title: 'Downloaded Notes',
            subtitle: 'Maths Class 12 - Chapter 5',
            date: 'July 5, 2025',
          ),
          _historyTile(
            icon: Icons.picture_as_pdf,
            title: 'Accessed Course PDF',
            subtitle: 'Physics Full Course PDF',
            date: 'July 3, 2025',
          ),
          _historyTile(
            icon: Icons.chat,
            title: 'Chatted with Tutor',
            subtitle: 'Mr. Sharma (Science)',
            date: 'July 1, 2025',
          ),
          _historyTile(
            icon: Icons.person_search,
            title: 'Searched for Tutors',
            subtitle: 'Private tutors in Delhi',
            date: 'June 30, 2025',
          ),
        ],
      ),
    );
  }

  Widget _historyTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required String date,
  }) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.blue.shade100,
          child: Icon(icon, color: AppColors.primaryColor, size: 24),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(subtitle),
            const SizedBox(height: 4),
            Text(date, style: const TextStyle(fontSize: 12, color: Colors.grey)),
          ],
        ),
        isThreeLine: true,
        trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
        onTap: () {},
      ),
    );
  }
} 
