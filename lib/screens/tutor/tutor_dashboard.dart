import 'package:flutter/material.dart';
import '../../theme/theme_constants.dart'; // AppColors with primary & accent colors

class TutorDashboardScreen extends StatelessWidget {
  const TutorDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final primaryColor = AppColors.primaryColor;
    final accentColor = AppColors.accentColor;

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: primaryColor,
          elevation: 0,
          title: Row(
            children: [
              CircleAvatar(
                backgroundColor: Colors.white,
                child: Text('T', style: TextStyle(color: primaryColor)),
              ),
              SizedBox(width: 12),
              Text('Urban Tutors',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              Spacer(),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text('Coins',
                      style: TextStyle(fontSize: 12, color: Colors.white)),
                  Text('(Upgrade)',
                      style: TextStyle(fontSize: 10, color: Colors.white70)),
                ],
              ),
              SizedBox(width: 8),
              Icon(Icons.menu),
            ],
          ),
          bottom: TabBar(
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white70,
            indicatorColor: Colors.white,
            tabs: [
              Tab(text: "Nearby"),
              Tab(text: "Enquiry"),
              Tab(text: "Contacted"),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildLeadsList("Nearby Leads"),
            _buildLeadsList("Enquiry Leads"),
            _buildLeadsList("Contacted Leads"),
          ],
        ),
        bottomNavigationBar: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          selectedItemColor: primaryColor,
          unselectedItemColor: Colors.grey,
          showUnselectedLabels: true,
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.note), label: 'Notes'),
            BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
            BottomNavigationBarItem(icon: Icon(Icons.book), label: 'Courses'),
            BottomNavigationBarItem(icon: Icon(Icons.chat_bubble_outline), label: 'Chat'),
            BottomNavigationBarItem(icon: Icon(Icons.support_agent), label: 'Support'),
          ],
        ),
      ),
    );
  }

  Widget _buildLeadsList(String type) {
    return ListView(
      padding: EdgeInsets.all(16),
      children: [
        _leadCard("Math Tuition in Delhi", type),
        SizedBox(height: 12),
        _leadCard("Physics Class for Class 12", type),
        SizedBox(height: 12),
        _leadCard("Home Tutor for Grade 5", type),
        SizedBox(height: 24),
        Center(child: Icon(Icons.arrow_downward, color: Colors.grey)),
      ],
    );
  }

  Widget _leadCard(String title, String category) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Row(
        children: [
          Icon(Icons.school, color: AppColors.primaryColor),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style:
                        TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                SizedBox(height: 4),
                Text(category,
                    style: TextStyle(fontSize: 12, color: Colors.grey[600])),
              ],
            ),
          ),
          Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
        ],
      ),
    );
  }
}
