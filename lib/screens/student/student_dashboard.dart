import 'package:flutter/material.dart';
import '../../theme/theme_constants.dart'; // Make sure AppColors is defined

class StudentDashboardScreen extends StatelessWidget {
  const StudentDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final primaryColor = AppColors.primaryColor;
    final accentColor = AppColors.accentColor;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: primaryColor,
        elevation: 0,
        title: Row(
          children: [
            CircleAvatar(
              backgroundColor: Colors.white,
              child: Text('S', style: TextStyle(color: primaryColor)),
            ),
            SizedBox(width: 12),
            Text('Urban Tutors', style: TextStyle(fontWeight: FontWeight.bold)),
            Spacer(),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text('Upgrade', style: TextStyle(fontSize: 12, color: Colors.white)),
                Text('(Coins)', style: TextStyle(fontSize: 10, color: Colors.white70)),
              ],
            ),
            SizedBox(width: 8),
            Icon(Icons.menu),
          ],
        ),
      ),
      body: SingleChildScrollView(
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
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        selectedItemColor: primaryColor,
        unselectedItemColor: Colors.grey,
        showUnselectedLabels: true,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.chat_bubble_outline), label: 'Chat'),
          BottomNavigationBarItem(icon: Icon(Icons.monetization_on), label: 'Upgrade'),
          BottomNavigationBarItem(icon: Icon(Icons.history), label: 'History'),
          BottomNavigationBarItem(icon: Icon(Icons.support_agent), label: 'Support'),
        ],
      ),
    );
  }

  Widget _featureTile(BuildContext context, String label, IconData icon, Color iconColor) {
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

  Widget _fullWidthTile(String label, IconData icon, Color iconColor) {
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
