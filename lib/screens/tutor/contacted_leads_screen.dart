import 'package:flutter/material.dart';
import 'package:urbantutors_app/theme/theme_constants.dart';

class SimpleTutorChatBot extends StatefulWidget {
  const SimpleTutorChatBot({super.key});

  @override
  State<SimpleTutorChatBot> createState() => _SimpleTutorChatBotState();
}

class _SimpleTutorChatBotState extends State<SimpleTutorChatBot> {
  final TextEditingController _controller = TextEditingController();
  final List<Map<String, String>> _chat = []; // {'sender': 'user'/'bot', 'message': ''}

  void _sendMessage() {
    String message = _controller.text.trim();
    if (message.isEmpty) return;

    setState(() {
      _chat.add({'sender': 'user', 'message': message});
    });
    _controller.clear();

    _botReply(message);
  }

  void _botReply(String userMsg) {
    String reply;

    if (userMsg.toLowerCase().contains("hello") || userMsg.toLowerCase().contains("hi")) {
      reply = "Hi! How can I help you today?";
    } else if (userMsg.toLowerCase().contains("book")) {
      reply = "You can book a tutor from the 'Find Tutor' section.";
    } else if (userMsg.toLowerCase().contains("timing")) {
      reply = "Our tutors are available from 9 AM to 6 PM.";
    } else {
      reply = "I'm not sure. Please wait while I connect you to a tutor.";
    }

    setState(() {
      _chat.add({'sender': 'bot', 'message': reply});
    });
  }

  Widget _buildChatBubble(String sender, String message) {
    bool isUser = sender == 'user';
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 4, horizontal: 10),
        padding: EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: isUser ? Colors.blue[200] : Colors.grey[300],
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(message),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.all(8),
              itemCount: _chat.length,
              itemBuilder: (context, index) {
                final chat = _chat[index];
                return _buildChatBubble(chat['sender']!, chat['message']!);
              },
            ),
          ),
          Divider(height: 1),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 8),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: InputDecoration(hintText: 'Type your message...'),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.send, color: AppColors.primaryColor),
                  onPressed: _sendMessage,
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}
