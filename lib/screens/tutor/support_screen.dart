import 'package:flutter/material.dart';

class TutorSupportPage extends StatelessWidget {
  const TutorSupportPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            supportButton(
              context,
              title: '📖 FAQs',
              onPressed: () {
                // TODO: Navigate to FAQ Page
              },
            ),
            const SizedBox(height: 12),
            supportButton(
              context,
              title: '💬 Contact Support',
              onPressed: () {
                // TODO: Open chat or support contact
              },
            ),
            const SizedBox(height: 12),
            supportButton(
              context,
              title: '🐞 Report an Issue',
              onPressed: () {
                // TODO: Open report issue form
              },
            ),
            const SizedBox(height: 12),
            supportButton(
              context,
              title: '📜 Terms & Policies',
              onPressed: () {
                // TODO: Show terms and policies
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget supportButton(BuildContext context, {required String title, required VoidCallback onPressed}) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 16),
        backgroundColor: const Color.fromARGB(255, 228, 229, 229),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      onPressed: onPressed,
      child: Text(title, style: const TextStyle(fontSize: 16, color: Colors.black)),
    );
  }
}
