import 'package:flutter/material.dart';
import '../../theme/theme_constants.dart'; // Ensure this contains AppColors

class TutorProfileScreen extends StatelessWidget {
  const TutorProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final primaryColor = AppColors.primaryColor;
    final accentColor = AppColors.accentColor;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: primaryColor,
        title: const Text('Profile'),
        actions: [
          TextButton(
            onPressed: () {
              // TODO: Implement edit logic
            },
            child: const Text('Edit', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const CircleAvatar(
              radius: 48,
              backgroundImage: AssetImage('assets/icons/app_icon.png'), // Replace with real profile image
            ),
            const SizedBox(height: 16),
            _buildReadOnlyField("First name", "Christian"),
            _buildReadOnlyField("Last name", "Joseph"),
            _buildReadOnlyField("Phone number", "+91 987654321"),
            _buildReadOnlyField("Email ID", "josephc@hotmail.com"),
            _buildReadOnlyField("School", "Halton District School Board"),
            const SizedBox(height: 12),
            _buildDropdownField("Program", ["M.B.A", "B.Ed", "PhD"], "M.B.A"),
            const SizedBox(height: 12),
            _buildDropdownField("Subject", ["Math", "Physics", "Biology"], "Math"),
            const SizedBox(height: 24),
            Text(
              "Looking to change password?",
              style: TextStyle(color: accentColor, fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReadOnlyField(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
        const SizedBox(height: 4),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: Text(value, style: const TextStyle(fontSize: 14)),
        ),
        const SizedBox(height: 12),
      ],
    );
  }

  Widget _buildDropdownField(String label, List<String> items, String selectedItem) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
        const SizedBox(height: 4),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: DropdownButtonFormField<String>(
            value: selectedItem,
            isExpanded: true,
            decoration: const InputDecoration(border: InputBorder.none),
            items: items
                .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                .toList(),
            onChanged: (val) {
              // TODO: Handle dropdown change
            },
          ),
        ),
      ],
    );
  }
}
