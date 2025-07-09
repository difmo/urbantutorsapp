import 'package:flutter/material.dart';
import 'package:urbantutors_app/theme/theme_constants.dart';

class StudentSupportScreen extends StatelessWidget {
  const StudentSupportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primaryColor = theme.primaryColor;
    final secondaryColor = AppColors.primaryColor;
    return Scaffold(
      appBar: AppBar(
        title: const Text("Support & Help"),
        backgroundColor: primaryColor,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Row(
            children: [
              CircleAvatar(
                backgroundColor: secondaryColor,
                child: const Icon(Icons.headset_mic, color: Colors.white),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text('Need Help?', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  Text('We are here to assist you anytime.')
                ],
              ),
            ],
          ),
          const SizedBox(height: 24),

          _supportTile(
            icon: Icons.book,
            title: "Using Courses",
            subtitle: "How to access and download course materials",
          ),
          _supportTile(
            icon: Icons.chat_bubble_outline,
            title: "Chat Support",
            subtitle: "Need help from a tutor or support staff?",
          ),
          _supportTile(
            icon: Icons.search,
            title: "Find Tutors",
            subtitle: "Search and filter best tutors near you",
          ),
          _supportTile(
            icon: Icons.upgrade,
            title: "Upgrade Account",
            subtitle: "Learn about subscription & coins",
          ),

          const SizedBox(height: 24),

          const Text("Contact Us", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),

          Card(
            child: ListTile(
              leading: const Icon(Icons.phone, color: Colors.green),
              title: const Text('+91 98765 43210'),
              onTap: () {},
            ),
          ),
          const SizedBox(height: 8),
          Card(
            child: ListTile(
              leading: const Icon(Icons.email, color: AppColors.primaryColor),
              title: const Text('support@urbantutors.pro'),
              onTap: () {},
            ),
          ),

          const SizedBox(height: 24),

          Card(
            color: Colors.orange.withOpacity(0.1),
            child: const Padding(
              padding: EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Icon(Icons.favorite, color: AppColors.primaryColor, size: 40),
                  SizedBox(height: 12),
                  Text('Thank you for being with us!',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  SizedBox(height: 8),
                  Text(
                    'Your learning journey is important to us. Reach out if you need anything.',
                    textAlign: TextAlign.center,
                  )
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _supportTile({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Card(
      child: ListTile(
        leading: Icon(icon, color: AppColors.primaryColor),
        title: Text(title),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: () {},
      ),
    );
  }
} 
