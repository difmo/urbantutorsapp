import 'package:flutter/material.dart';
import 'package:urbantutorsapp/theme/theme_constants.dart';

class NotificationPage extends StatefulWidget {
  const NotificationPage({super.key});

  @override
  State<NotificationPage> createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {
  final List<String> _notifications = [];

  @override
  void initState() {
    super.initState();

    // Fake initial data — comment this out to start empty
    // _notifications = ['Welcome to the app!', 'New feature released!', 'Discount available!'];
  }

  void _clearAllNotifications() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Confirm"),
          content:
              const Text("Are you sure you want to delete all notifications?"),
          actions: [
            TextButton(
              child: const Text("Cancel"),
              onPressed: () => Navigator.of(context).pop(),
            ),
            ElevatedButton(
              child: const Text("Delete All"),
              onPressed: () {
                setState(() {
                  _notifications.clear();
                });
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Notifications"),
      ),
      body: _notifications.isEmpty
          ? const Center(
              child: Text(
                "No notifications available.",
                style: TextStyle(fontSize: 16),
              ),
            )
          : ListView.builder(
              itemCount: _notifications.length,
              itemBuilder: (context, index) {
                return ListTile(
                  leading: const Icon(Icons.notifications),
                  title: Text(_notifications[index]),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _clearAllNotifications,
        tooltip: 'Clear All',
        backgroundColor: AppColors.primaryColor,
        child: const Icon(
          Icons.delete,
          color: Colors.white,
        ),
      ),
    );
  }
}
