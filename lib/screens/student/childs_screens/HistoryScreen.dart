import 'package:flutter/material.dart';

class HistoryScreen extends StatelessWidget {
  final List<Map<String, String>> historyItems = [
    {
      'title': 'Live Class with Tutor John',
      'subtitle': 'Completed • July 10, 2025 • 5:00 PM',
      'type': 'class'
    },
    {
      'title': 'Purchased Premium Plan',
      'subtitle': '₹499 • July 1, 2025',
      'type': 'upgrade'
    },
    {
      'title': 'Private Chat with Tutor Lisa',
      'subtitle': 'July 2, 2025 • 11:00 AM',
      'type': 'chat'
    },
    {
      'title': 'Joined Doubt Session',
      'subtitle': 'July 8, 2025 • 2:00 PM',
      'type': 'class'
    },
    {
      'title': 'Purchased 300 Coins',
      'subtitle': '₹199 • July 5, 2025',
      'type': 'coins'
    },
  ];

  HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).primaryColor;

    return Scaffold(
   
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: historyItems.length,
        separatorBuilder: (_, __) => const Divider(height: 1),
        itemBuilder: (context, index) {
          final item = historyItems[index];

          return ListTile(
            leading: _getIcon(item['type'], primaryColor),
            title: Text(
              item['title']!,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            subtitle: Text(item['subtitle']!,
                style: const TextStyle(color: Colors.black54)),
            onTap: () {
              // Optionally: show detail page or dialog
            },
          );
        },
      ),
    );
  }

  Widget _getIcon(String? type, Color color) {
    switch (type) {
      case 'class':
        return Icon(Icons.video_camera_front, color: color);
      case 'upgrade':
        return Icon(Icons.star, color: Colors.orange);
      case 'chat':
        return Icon(Icons.chat_bubble_outline, color: Colors.blue);
      case 'coins':
        return Icon(Icons.monetization_on, color: Colors.green);
      default:
        return Icon(Icons.history, color: Colors.grey);
    }
  }
}
