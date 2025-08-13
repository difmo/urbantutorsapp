import 'package:flutter/material.dart';

class FeedbackTutor extends StatefulWidget {
  const FeedbackTutor({super.key});

  @override
  State<FeedbackTutor> createState() => _FeedbackTutorState();
}

class _FeedbackTutorState extends State<FeedbackTutor> {
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
                  color: Colors.grey, // light label color
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
                  color: Colors.grey,
                  fontSize: 14,
                ),
                hintText: 'Description',
                hintStyle: TextStyle(
                  color: Colors.grey.shade500,
                ),
                border: InputBorder.none,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
