import 'package:flutter/material.dart';
import 'package:urbantutorsapp/theme/theme_constants.dart';

class FeedbackScreen extends StatelessWidget {
  const FeedbackScreen({super.key});

  void _onDeletePressed(BuildContext context) {
    // You can show a confirmation dialog or perform delete logic here
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Delete action triggered')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Feedback'),
      ),
      body: const Center(
        child: Text(
          '',
          style: TextStyle(fontSize: 16),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _onDeletePressed(context),
        backgroundColor: AppColors.primaryColor,
        child: const Icon(Icons.delete,
        color: Colors.white,),
      ),
    );
  }
}
