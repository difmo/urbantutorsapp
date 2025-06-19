import 'package:flutter/material.dart';
import '../../theme/theme_constants.dart'; // Ensure AppColors is available here

class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({super.key});

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
                child: Text('A', style: TextStyle(color: primaryColor)),
              ),
              SizedBox(width: 12),
              Text('Admin Dashboard',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              Spacer(),
              Row(
                children: [
                  Icon(Icons.monetization_on_outlined, size: 20),
                  SizedBox(width: 4),
                  Text('Coins'),
                  SizedBox(width: 12),
                  Icon(Icons.menu),
                ],
              ),
            ],
          ),
          bottom: TabBar(
            labelColor: Colors.white,
            indicatorColor: Colors.white,
            unselectedLabelColor: Colors.white70,
            tabs: [
              Tab(text: "All Posted"),
              Tab(text: "Grabbed"),
              Tab(text: "Declined"),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildLeadList("All Posted Leads"),
            _buildLeadList("Grabbed Leads"),
            _buildLeadList("Declined Leads"),
          ],
        ),
        bottomNavigationBar: BottomAppBar(
          shape: CircularNotchedRectangle(),
          notchMargin: 8.0,
          color: Colors.grey.shade100,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: <Widget>[
              IconButton(icon: Icon(Icons.home, color: primaryColor), onPressed: () {}),
              SizedBox(width: 40), // space for FAB
              TextButton(
                onPressed: () {},
                child: Text("History", style: TextStyle(color: primaryColor)),
              ),
            ],
          ),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
        floatingActionButton: FloatingActionButton(
          backgroundColor: accentColor,
          onPressed: () {
            // TODO: Post new lead
          },
          child: Icon(Icons.add, color: Colors.white),
        ),
      ),
    );
  }

  Widget _buildLeadList(String type) {
    return ListView(
      padding: EdgeInsets.all(16),
      children: [
        _leadCard("Lead 1 • $type"),
        SizedBox(height: 12),
        _leadCard("Lead 2 • $type"),
        SizedBox(height: 12),
        _leadCard("Lead 3 • $type"),
        SizedBox(height: 24),
        Center(child: Icon(Icons.arrow_downward, color: Colors.grey)),
      ],
    );
  }

  Widget _leadCard(String title) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Row(
        children: [
          Icon(Icons.leaderboard, color: AppColors.primaryColor),
          SizedBox(width: 12),
          Expanded(
            child: Text(
              title,
              style: TextStyle(fontSize: 16),
            ),
          ),
          Icon(Icons.chevron_right),
        ],
      ),
    );
  }
}
