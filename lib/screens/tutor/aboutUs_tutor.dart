import 'package:flutter/material.dart';

class AboutusTutor extends StatefulWidget {
  const AboutusTutor({super.key});

  @override
  State<AboutusTutor> createState() => _AboutusTutorState();
}

class _AboutusTutorState extends State<AboutusTutor> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('About us'),
      ),
      body: Container(
        padding: const EdgeInsets.all(16),
        child: const Text(
          '''Urban Tutors, established in 2024, is dedicated to connecting students with skilled and passionate educators, offering personalized learning experiences that inspire growth and confidence. With a vision to make quality education accessible to all, Urban Tutors strives to bridge the gap between learning needs and expert guidance.

Thank you! 🙏''',
          style: TextStyle(fontSize: 20),
        ),
      ),
    );
  }
}
