import 'package:flutter/material.dart';
import 'package:urbantutors_app/screens/splash_screen.dart';
import '../../theme/theme_constants.dart';
import 'package:urbantutors_app/screens/welcome/welcome_screen.dart';
import 'package:urbantutors_app/screens/admin/history_screen.dart';
// Adjust this import path if needed

class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final primaryColor = AppColors.primaryColor;
    final accentColor = AppColors.accentColor;

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        drawer: Drawer(
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              DrawerHeader(
                decoration: BoxDecoration(color: primaryColor),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    CircleAvatar(
                      child: Icon(Icons.admin_panel_settings, size: 32),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Admin Menu',
                      style: TextStyle(color: Colors.white, fontSize: 18),
                    ),
                  ],
                ),
              ),
              ListTile(
                leading: const Icon(Icons.dashboard),
                title: const Text('Dashboard'),
                onTap: () {
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: const Icon(Icons.logout),
                title: const Text('Logout'),
                onTap: () {
                  Navigator.pop(context); // Close drawer
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const WelcomeScreen(),
                    ),
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
                child: Text('A', style: TextStyle(color: primaryColor)),
              ),
              const SizedBox(width: 12),
              const Text(
                'Admin Dashboard',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const Spacer(),
              Row(
                children: const [
                  Icon(Icons.monetization_on_outlined, size: 20),
                  SizedBox(width: 4),
                  Text('Coins'),
                  SizedBox(width: 12),
                ],
              ),
            ],
          ),
          bottom: const TabBar(
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
          shape: const CircularNotchedRectangle(),
          notchMargin: 8.0,
          color: Colors.grey.shade100,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: <Widget>[
              IconButton(
                icon: Icon(Icons.home, color: primaryColor),
                onPressed: () {},
              ),
              const SizedBox(width: 40), // space for FAB
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const AdminHistoryPage(),
                    ),
                  );
                },
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
          child: const Icon(Icons.add, color: Colors.white),
        ),
      ),
    );
  }

  Widget _buildLeadList(String type) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _leadCard("Lead 1 • $type"),
        const SizedBox(height: 12),
        _leadCard("Lead 2 • $type"),
        const SizedBox(height: 12),
        _leadCard("Lead 3 • $type"),
        const SizedBox(height: 24),
        const Center(child: Icon(Icons.arrow_downward, color: Colors.grey)),
      ],
    );
  }

  Widget _leadCard(String title) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Row(
        children: [
          Icon(Icons.leaderboard, color: AppColors.primaryColor),
          const SizedBox(width: 12),
          Expanded(child: Text(title, style: const TextStyle(fontSize: 16))),
          const Icon(Icons.chevron_right),
        ],
      ),
    );
  }
}
