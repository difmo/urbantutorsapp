import 'package:flutter/material.dart';
import 'package:urbantutors_app/screens/welcome/welcome_screen.dart';
import '../../theme/theme_constants.dart';
import 'package:urbantutors_app/screens/student/support_screen.dart';
import 'package:urbantutors_app/screens/student/history_screen.dart';
import 'package:urbantutors_app/screens/student/chat_screen.dart';
import 'package:urbantutors_app/screens/student/upgrade_screen.dart'; // Make sure AppColors is defined
// OPTIONAL: for logout navigation

class StudentDashboardScreen extends StatelessWidget {
  int _selectedIndex = 0;

  void _onItemTapped(int index, BuildContext context) {
    if (index == 4) {
      // Index of 'Support'
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const StudentSupportScreen()),
      );
    }
    else if (index == 3) {
      // Index of 'History'
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const StudentHistoryScreen()),
      );
    }
    else if (index == 1) {
      // Index of 'Chat'
      Navigator.push(
        context,
         MaterialPageRoute(builder: (context) => const
          StudentChatBotScreen()),
      );
    }
    else if (index == 2){
      // Index of 'Upgrade'
      Navigator.push(
        context, 
        MaterialPageRoute(builder: (context) => const
          StudentUpgradeScreen()),
      );
    }
     else {
      _selectedIndex = index;
      // Handle other navigation logic if needed
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Selected index: $index')),
      );
    }
  }
      StudentDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final primaryColor = AppColors.primaryColor;
    final accentColor = AppColors.accentColor;

    return Scaffold(
      backgroundColor: Colors.white,
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(color: primaryColor),
              child: const Text(
                'Student Menu',
                style: TextStyle(color: Colors.white, fontSize: 18),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.home),
              title: const Text('Home'),
              onTap: () {
                Navigator.pop(context); // Close drawer
              },
            ),
            ListTile(
              leading: const Icon(Icons.school),
              title: const Text('Courses'),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('Logout'),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => const WelcomeScreen()),
                );
              },
            ),
          ],
        ),
      ),
      appBar: AppBar(
        backgroundColor: primaryColor,
        elevation: 0,
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
        title: Row(
          children: [
            CircleAvatar(
              backgroundColor: Colors.white,
              child: Text('S', style: TextStyle(color: primaryColor)),
            ),
            const SizedBox(width: 12),
            const Text(
              'Urban Tutors',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const Spacer(),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: const [
                Text(
                  'Upgrade',
                  style: TextStyle(fontSize: 12, color: Colors.white),
                ),
                Text(
                  '(Coins)',
                  style: TextStyle(fontSize: 10, color: Colors.white70),
                ),
              ],
            ),
            const SizedBox(width: 8),
          ],
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                _featureTile(context, 'Notes', Icons.note, primaryColor),
                const SizedBox(width: 16),
                _featureTile(
                  context,
                  'PYQ\'s',
                  Icons.assignment_turned_in,
                  primaryColor,
                ),
              ],
            ),
            const SizedBox(height: 16),
            _fullWidthTile('Courses (PDF)', Icons.picture_as_pdf, primaryColor),
            const SizedBox(height: 16),
            _fullWidthTile(
              'Search a Private Tutor Now',
              Icons.search,
              primaryColor,
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) => _onItemTapped(index, context),
        type: BottomNavigationBarType.fixed,
        selectedItemColor: primaryColor,
        unselectedItemColor: Colors.grey,
        showUnselectedLabels: true,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(
            icon: Icon(Icons.chat_bubble_outline),
            label: 'Chat',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.monetization_on),
            label: 'Upgrade',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.history), label: 'History'),
          BottomNavigationBarItem(
            icon: Icon(Icons.support_agent),
            label: 'Support',
          ),
        ],
      ),
    );
  }

  Widget _featureTile(
    BuildContext context,
    String label,
    IconData icon,
    Color iconColor,
  ) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: Column(
          children: [
            Icon(icon, size: 32, color: iconColor),
            const SizedBox(height: 8),
            Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }

  Widget _fullWidthTile(String label, IconData icon, Color iconColor) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Row(
        children: [
          Icon(icon, size: 30, color: iconColor),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
          const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
        ],
      ),
    );
  }
}
