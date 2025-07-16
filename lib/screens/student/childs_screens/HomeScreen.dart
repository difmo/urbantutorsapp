import 'package:flutter/material.dart';
import 'package:urbantutorsapp/theme/theme_constants.dart';

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final primaryColor = AppColors.primaryColor;
    final accentColor = AppColors.accentColor;

    return SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: Column(
        children: [
          Row(
            children: [
              _featureTile(context, 'Notes', Icons.note, primaryColor),
              SizedBox(width: 16),
              _featureTile(context, 'PYQ\'s', Icons.assignment_turned_in, primaryColor),
            ],
          ),
          SizedBox(height: 16),
          _fullWidthTile('Courses (PDF)', Icons.picture_as_pdf, accentColor),
          SizedBox(height: 16),
          _fullWidthTile('Search a Private Tutor Now', Icons.search, primaryColor),
        ],
      ),
    );
  }

  static Widget _featureTile(BuildContext context, String label, IconData icon, Color iconColor) {
    return Expanded(
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: Column(
          children: [
            Icon(icon, size: 32, color: iconColor),
            SizedBox(height: 8),
            Text(label, style: TextStyle(fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }

  static Widget _fullWidthTile(String label, IconData icon, Color iconColor) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(vertical: 18, horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Row(
        children: [
          Icon(icon, size: 30, color: iconColor),
          SizedBox(width: 16),
          Expanded(
            child: Text(
              label,
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
          Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
        ],
      ),
    );
  }
}
