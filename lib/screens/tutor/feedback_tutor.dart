import 'package:flutter/material.dart';
import 'package:urbantutorsapp/theme/theme_constants.dart';

class FeedbackTutor extends StatefulWidget {
  const FeedbackTutor({super.key});

  @override
  State<FeedbackTutor> createState() => _FeedbackTutorState();
}

class _FeedbackTutorState extends State<FeedbackTutor> {
  // This is the function that gets called when you press the button
  void _submitFeedback() {
    // For now, just show a Snackbar
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Feedback submitted")),
    );

    // Later you can replace this with API call or logic to save feedback
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Feedback"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextFormField(
              style: const TextStyle(
                color: Colors.black87, // input text color
                fontSize: 16,
              ),
              decoration: InputDecoration(
                labelText: 'Title',
                labelStyle: const TextStyle(
                  color: Colors.black, // light label color
                  fontSize: 14,
                ),
                hintText: 'Main Heading', // placeholder
                hintStyle: TextStyle(
                  color: Colors.grey.shade500,
                ),
                border: InputBorder.none,
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              style: const TextStyle(
                color: Colors.black87,
                fontSize: 16,
              ),
              decoration: InputDecoration(
                labelText: 'More Details',
                labelStyle: const TextStyle(
                  color: Colors.black,
                  fontSize: 14,
                ),
                hintText: 'Description',
                hintStyle: TextStyle(
                  color: Colors.grey.shade500,
                ),
                border: InputBorder.none,
              ),
              maxLines: 4,
            ),
            const SizedBox(height: 24),
            OutlinedButton(
              style: OutlinedButton.styleFrom(
                backgroundColor:
                    AppColors.primaryColor, // App theme color background
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
              onPressed: _submitFeedback,
              child: const Text(
                "Submit",
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.white, // White text
                  fontWeight: FontWeight.bold,
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
