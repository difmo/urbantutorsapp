import 'package:flutter/material.dart';
import 'package:urbantutors_app/theme/theme_constants.dart';

class StudentChatBotScreen extends StatefulWidget {
  const StudentChatBotScreen({super.key});

  @override
  State<StudentChatBotScreen> createState() => _StudentChatBotScreenState();
}

class _StudentChatBotScreenState extends State<StudentChatBotScreen> {
  final TextEditingController _controller = TextEditingController();
  final List<Map<String, String>> _chat = []; // {'sender': 'student' or 'bot', 'message': ''}

  // Handle send
  void _sendMessage() {
    final message = _controller.text.trim();
    if (message.isEmpty) return;

    // Add student message to chat
    setState(() {
      _chat.add({'sender': 'student', 'message': message});
    });

    _controller.clear();

    // Bot replies instantly
    _replyFromBot(message);
  }

  // Simple keyword-based bot logic
  void _replyFromBot(String input) {
    String reply;

    input = input.toLowerCase();

    if (input.contains('help')) {
      reply = "Sure! What do you need help with? You can ask about classes, tutors, or courses.";
    } else if (input.contains('book') || input.contains('tutor')) {
      reply = "To book a tutor, go to the 'Find Tutor' section in your dashboard.";
    } else if (input.contains('class') || input.contains('timing')) {
      reply = "Classes are available Monday to Saturday from 9 AM to 6 PM.";
    } else if (input.contains('fees') || input.contains('price')) {
      reply = "Fees depend on the course. Visit the 'Pricing' section to know more.";
    } else {
      reply = "I'm not sure about that. Let me connect you to a human tutor for better help.";
    }

    setState(() {
      _chat.add({'sender': 'bot', 'message': reply});
    });
  }

  // Chat bubble UI
  Widget _buildChatBubble(String sender, String message) {
    final isStudent = sender == 'student';

    return Align(
      alignment: isStudent ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 10),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isStudent ? Colors.black : Colors.grey[300],
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text(
          message,
          style: TextStyle(color: isStudent ? Colors.white : Colors.black87),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Student Help ChatBot'),
        backgroundColor: AppColors.primaryColor,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(8),
              itemCount: _chat.length,
              itemBuilder: (context, index) {
                final msg = _chat[index];
                return _buildChatBubble(msg['sender']!, msg['message']!);
              },
            ),
          ),
          Divider(height: 1),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 60),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: const InputDecoration(
                      hintText: 'Type your question...',
                      border: OutlineInputBorder(),
                    ),
                    onSubmitted: (_) => _sendMessage(),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.send, color: AppColors.primaryColor),
                  onPressed: _sendMessage,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
