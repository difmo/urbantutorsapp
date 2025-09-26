import 'package:flutter/material.dart';
import 'package:urbantutorsapp/theme/theme_constants.dart';

class TutorChatScreen extends StatelessWidget {
  const TutorChatScreen({super.key});
  final ss = false;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: ss == false
          ? Center(
              child: Container(
              padding: EdgeInsets.all(16),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Get Pro Membership Now, to Enable Features Like Free Chat with Students / Parents, Top View , Visble Contact Number for One Year.",
                    textAlign: TextAlign.center,
                    style:
                        TextStyle(color: AppColors.primaryColor, fontSize: 25),
                  ),
                  SizedBox(
                    height: 16,
                  ),
                  SizedBox(
                    height: 48,
                    width: 350,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            const Color(0xFF27AE60), // a distinct color
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      icon: const Icon(
                        Icons.workspace_premium,
                        size: 24,
                      ),
                      label: const Text(
                        'Get Pro Membership Now ',
                        style: TextStyle(fontSize: 24),
                      ),
                      onPressed: () => {},
                    ),
                  ),
                ],
              ),
            ))
          : Column(
              children: [
                // _buildAppBar(context),
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.all(12),
                    children: [
                      _chatBubble(
                        message: "Hello Tutor, I need help with math.",
                        isSender: false,
                        time: "5 min ago",
                      ),
                      _chatBubble(
                        message: "Sure! Let me help you with that.",
                        isSender: true,
                        time: "4 min ago",
                      ),
                      _chatBubble(
                        message: "Can we solve algebra equations?",
                        isSender: false,
                        time: "2 min ago",
                      ),
                    ],
                  ),
                ),
                SafeArea(
                  minimum: const EdgeInsets.only(bottom: 8),
                  child: _messageInputField(),
                ),
              ],
            ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return Container(
      color: AppColors.primaryColor,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 35),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: const Icon(Icons.arrow_back, color: Colors.white),
          ),
          const SizedBox(width: 16),
          const Text(
            "Chat with Student",
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _chatBubble({
    required String message,
    required bool isSender,
    required String time,
  }) {
    return Align(
      alignment: isSender ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 6),
        padding: const EdgeInsets.all(12),
        constraints: const BoxConstraints(maxWidth: 280),
        decoration: BoxDecoration(
          color: isSender ? AppColors.primaryColor : const Color(0xFFF1F1F1),
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: Radius.circular(isSender ? 16 : 0),
            bottomRight: Radius.circular(isSender ? 0 : 16),
          ),
        ),
        child: Column(
          crossAxisAlignment:
              isSender ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            Text(
              message,
              style: TextStyle(
                color: isSender ? Colors.white : Colors.black87,
                fontSize: 15,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              time,
              style: TextStyle(
                color:
                    isSender ? Colors.white.withOpacity(0.7) : Colors.black54,
                fontSize: 10,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _messageInputField() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(30),
                border:
                    Border.all(color: AppColors.primaryColor.withOpacity(0.3)),
              ),
              child: TextField(
                style: const TextStyle(color: Colors.black87),
                decoration: InputDecoration(
                  hintText: "Enter your message",
                  hintStyle: TextStyle(color: Colors.black.withOpacity(0.6)),
                  border: InputBorder.none,
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Container(
            decoration: BoxDecoration(
              color: AppColors.primaryColor,
              shape: BoxShape.circle,
            ),
            child: IconButton(
              onPressed: () {
                // TODO: send message
              },
              icon: const Icon(Icons.send, color: Colors.white),
            ),
          )
        ],
      ),
    );
  }
}
